import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter_reactive_ble/flutter_reactive_ble.dart';
import '../models/poster_request.dart';
import '../providers/ble_connection_provider.dart';
import '../providers/front_desk_provider.dart';
import '../providers/back_office_provider.dart';
import 'ble_service.dart';
import 'ble_server_service.dart';
import 'persistence_service.dart';

/// Sync Service
///
/// Orchestrates the three-step reconnection handshake between Front Desk
/// and Back Office devices after connection is established or re-established.
///
/// Three-Step Handshake:
/// 1. Front Desk pushes all unsynced requests (Client → Server)
/// 2. Back Office pushes all unsynced status updates (Server → Client)
/// 3. Front Desk reads full queue state for reconciliation (Client reads from Server)
///
/// See: project_standards/Synchronization Protocol and Error Handling.md
class SyncService {
  final BleService? _bleService;
  final BleServerService? _bleServerService;
  final BleConnectionProvider _connectionProvider;
  final PersistenceService _persistenceService;

  // Optional providers (depends on device role)
  final FrontDeskProvider? _frontDeskProvider;
  final BackOfficeProvider? _backOfficeProvider;

  StreamSubscription<DiscoveredDevice>? _scanSubscription;

  // Retry configuration
  static const int maxRetries = 3;
  static const Duration retryDelay = Duration(seconds: 2);

  SyncService({
    BleService? bleService,
    BleServerService? bleServerService,
    required BleConnectionProvider connectionProvider,
    required PersistenceService persistenceService,
    FrontDeskProvider? frontDeskProvider,
    BackOfficeProvider? backOfficeProvider,
  })  : _bleService = bleService,
        _bleServerService = bleServerService,
        _connectionProvider = connectionProvider,
        _persistenceService = persistenceService,
        _frontDeskProvider = frontDeskProvider,
        _backOfficeProvider = backOfficeProvider {
    // Validate role-specific providers
    if (bleService != null && frontDeskProvider == null) {
      throw ArgumentError('Front Desk role requires FrontDeskProvider');
    }
    if (bleServerService != null && backOfficeProvider == null) {
      throw ArgumentError('Back Office role requires BackOfficeProvider');
    }
  }

  /// Start scanning for Back Office devices and connect when found
  void startScan() {
    if (_bleService == null) return; // Only Front Desk scans

    debugPrint('[Sync Service] Starting BLE scan...');
    _scanSubscription?.cancel();
    _scanSubscription = _bleService.startScanning().listen(
      (device) {
        if (device.name == 'PosterRunner-BO') {
          debugPrint('[Sync Service] Found Back Office device: ${device.id}');
          _scanSubscription?.cancel();
          connectToDevice(device.id);
        }
      },
      onError: (error) {
        debugPrint('[Sync Service] Scan error: $error');
      },
    );
  }

  /// Connect to a specific device
  Future<void> connectToDevice(String deviceId) async {
    if (_bleService == null) return;
    debugPrint('[Sync Service] Attempting to connect to $deviceId');
    await _bleService.connect(deviceId);
  }

  /// Execute the complete three-step reconnection handshake
  ///
  /// This method should be called after BLE connection is established.
  ///
  /// Returns true if sync completed successfully, false otherwise.
  Future<bool> executeReconnectionHandshake() async {
    debugPrint('[Sync Service] Starting three-step reconnection handshake');

    try {
      if (_bleService != null) {
        return await _executeFrontDeskHandshake();
      } else {
        return await _executeBackOfficeHandshake();
      }
    } catch (e) {
      debugPrint('[Sync Service] Handshake failed: $e');
      _connectionProvider.setError('Sync failed: $e');
      return false;
    }
  }

  /// Execute Front Desk side of handshake
  Future<bool> _executeFrontDeskHandshake() async {
    debugPrint('[Sync Service] Executing Front Desk handshake');

    // Step 1: Push all unsynced requests to Back Office
    final step1Success = await _pushUnsyncedRequests();
    if (!step1Success) {
      debugPrint('[Sync Service] Step 1 failed: Push unsynced requests');
      return false;
    }

    // Step 2: Wait for Back Office to push unsynced status updates
    // (This happens passively via Queue Status Characteristic subscription)
    debugPrint('[Sync Service] Step 2: Waiting for status updates from Back Office');
    // Give Back Office time to send status updates
    await Future.delayed(const Duration(seconds: 2));

    // Step 3: Read full queue state for reconciliation
    final step3Success = await _readFullQueueSync();
    if (!step3Success) {
      debugPrint('[Sync Service] Step 3 failed: Read full queue sync');
      return false;
    }

    debugPrint('[Sync Service] Front Desk handshake completed successfully');
    _connectionProvider.updateLastSyncTime();
    return true;
  }

  /// Execute Back Office side of handshake
  Future<bool> _executeBackOfficeHandshake() async {
    debugPrint('[Sync Service] Executing Back Office handshake');

    // Step 1: Wait for Front Desk to push unsynced requests
    // (This happens passively via Request Characteristic writes)
    debugPrint('[Sync Service] Step 1: Waiting for requests from Front Desk');
    // Give Front Desk time to send requests
    await Future.delayed(const Duration(seconds: 2));

    // Step 2: Push all unsynced status updates to Front Desk
    final step2Success = await _pushUnsyncedStatusUpdates();
    if (!step2Success) {
      debugPrint('[Sync Service] Step 2 failed: Push unsynced status updates');
      return false;
    }

    // Step 3: Prepare to serve full queue sync when Front Desk reads
    // (This happens passively via Full Queue Sync Characteristic read)
    debugPrint('[Sync Service] Step 3: Ready to serve full queue sync');

    debugPrint('[Sync Service] Back Office handshake completed successfully');
    _connectionProvider.updateLastSyncTime();
    return true;
  }

  // ============================================================================
  // STEP 1: FRONT DESK PUSHES UNSYNCED REQUESTS
  // ============================================================================

  /// Push all unsynced requests from Front Desk to Back Office
  ///
  /// Scans local storage for requests with isSynced: false and status: SENT
  Future<bool> _pushUnsyncedRequests() async {
    if (_frontDeskProvider == null) {
      debugPrint('[Sync Service] No Front Desk provider available');
      return false;
    }

    debugPrint('[Sync Service] Step 1: Pushing unsynced requests');

    // Get all unsynced requests from persistence
    final unsyncedRequests = _persistenceService.getUnsyncedSubmittedRequests();

    if (unsyncedRequests.isEmpty) {
      debugPrint('[Sync Service] No unsynced requests to push');
      return true;
    }

    debugPrint('[Sync Service] Found ${unsyncedRequests.length} unsynced requests');

    // Push each request with retry logic
    for (final request in unsyncedRequests) {
      final success = await _writeRequestWithRetry(request);
      if (!success) {
        debugPrint('[Sync Service] Failed to push request: ${request.uniqueId}');
        return false;
      }

      // Mark as synced in local storage
      final syncedRequest = request.copyWith(isSynced: true);
      await _persistenceService.saveSubmittedRequest(syncedRequest);
      debugPrint('[Sync Service] Request synced: ${request.uniqueId}');
    }

    debugPrint('[Sync Service] All unsynced requests pushed successfully');
    return true;
  }

  /// Write request to Back Office with retry logic
  Future<bool> _writeRequestWithRetry(PosterRequest request) async {
    if (_bleService == null) return false;

    for (int attempt = 1; attempt <= maxRetries; attempt++) {
      try {
        if (attempt == 1) {
          await Future.delayed(const Duration(seconds: 2));
        }
        debugPrint('[Sync Service] Writing request ${request.uniqueId} (attempt $attempt/$maxRetries)');
        await _bleService.writeRequest(request);
        return true;
      } catch (e) {
        debugPrint('[Sync Service] Write failed (attempt $attempt/$maxRetries): $e');

        if (attempt < maxRetries) {
          await Future.delayed(retryDelay);
        }
      }
    }

    debugPrint('[Sync Service] All retry attempts exhausted for request ${request.uniqueId}');
    return false;
  }

  // ============================================================================
  // STEP 2: BACK OFFICE PUSHES UNSYNCED STATUS UPDATES
  // ============================================================================

  /// Push all unsynced status updates from Back Office to Front Desk
  ///
  /// Scans local storage for fulfilled requests with isSynced: false
  Future<bool> _pushUnsyncedStatusUpdates() async {
    if (_backOfficeProvider == null) {
      debugPrint('[Sync Service] No Back Office provider available');
      return false;
    }

    debugPrint('[Sync Service] Step 2: Pushing unsynced status updates');

    // Get all fulfilled requests from persistence
    final allFulfilled = _persistenceService.getAllFulfilledRequests();

    // Filter for unsynced
    final unsyncedUpdates = allFulfilled.where((r) => !r.isSynced).toList();

    if (unsyncedUpdates.isEmpty) {
      debugPrint('[Sync Service] No unsynced status updates to push');
      return true;
    }

    debugPrint('[Sync Service] Found ${unsyncedUpdates.length} unsynced status updates');

    // Push each update with retry logic
    for (final request in unsyncedUpdates) {
      final success = await _sendStatusUpdateWithRetry(request);
      if (!success) {
        debugPrint('[Sync Service] Failed to push status update: ${request.uniqueId}');
        return false;
      }

      // Mark as synced in local storage
      final syncedRequest = request.copyWith(isSynced: true);
      await _persistenceService.saveFulfilledRequest(syncedRequest);
      debugPrint('[Sync Service] Status update synced: ${request.uniqueId}');
    }

    debugPrint('[Sync Service] All unsynced status updates pushed successfully');
    return true;
  }

  /// Send status update to Front Desk with retry logic
  Future<bool> _sendStatusUpdateWithRetry(PosterRequest request) async {
    for (int attempt = 1; attempt <= maxRetries; attempt++) {
      try {
        debugPrint('[Sync Service] Sending status update ${request.uniqueId} (attempt $attempt/$maxRetries)');
        if (_bleService != null) {
          await _bleService.sendStatusUpdate(request);
        } else if (_bleServerService != null) {
          await _bleServerService.sendStatusUpdate(request);
        } else {
          return false; // No service available
        }
        return true;
      } catch (e) {
        debugPrint('[Sync Service] Send failed (attempt $attempt/$maxRetries): $e');

        if (attempt < maxRetries) {
          await Future.delayed(retryDelay);
        }
      }
    }

    debugPrint('[Sync Service] All retry attempts exhausted for status update ${request.uniqueId}');
    return false;
  }

  // ============================================================================
  // STEP 3: FRONT DESK READS FULL QUEUE SYNC
  // ============================================================================

  /// Read full queue state from Back Office and reconcile
  ///
  /// Overwrites local delivered audit with authoritative state from Back Office
  Future<bool> _readFullQueueSync() async {
    if (_frontDeskProvider == null || _bleService == null) {
      debugPrint('[Sync Service] No Front Desk provider or BLE service available');
      return false;
    }

    debugPrint('[Sync Service] Step 3: Reading full queue sync');

    try {
      final allRequests = await _bleService.readFullQueueSync();
      debugPrint('[Sync Service] Received ${allRequests.length} requests from Back Office');

      // Filter for fulfilled requests (these go in Delivered Audit)
      final fulfilledRequests =
          allRequests.where((r) => r.status == RequestStatus.fulfilled).toList();

      debugPrint('[Sync Service] Processing ${fulfilledRequests.length} fulfilled requests');

      // Clear existing delivered audit and replace with authoritative data
      // This ensures complete reconciliation
      for (final request in fulfilledRequests) {
        await _persistenceService.saveToDeliveredAudit(request);
      }

      debugPrint('[Sync Service] Delivered audit reconciled with ${fulfilledRequests.length} requests');
      return true;
    } catch (e) {
      debugPrint('[Sync Service] Failed to read full queue sync: $e');
      return false;
    }
  }

  // ============================================================================
  // REAL-TIME SYNC (DURING NORMAL OPERATION)
  // ============================================================================

  /// Handle incoming request from Front Desk (Back Office only)
  ///
  /// Called when Back Office receives a new request via Request Characteristic (A)
  Future<void> handleIncomingRequest(PosterRequest request) async {
    if (_backOfficeProvider == null) {
      debugPrint('[Sync Service] No Back Office provider available');
      return;
    }

    debugPrint('[Sync Service] Handling incoming request: ${request.uniqueId}');

    // Check for duplicate uniqueId (per error handling spec)
    final existing = _persistenceService.getFulfilledRequest(request.uniqueId);
    if (existing != null) {
      debugPrint('[Sync Service] Duplicate request ignored: ${request.uniqueId}');
      return;
    }

    // Convert to BLE message format and add to Back Office queue via provider
    final bleMessage = request.toRequestCharacteristicJson();
    await _backOfficeProvider.handleIncomingRequest(bleMessage);
    debugPrint('[Sync Service] Request added to queue: ${request.uniqueId}');
  }

  /// Handle incoming status update from Back Office (Front Desk only)
  ///
  /// Called when Front Desk receives status update via Queue Status Characteristic (B)
  Future<void> handleIncomingStatusUpdate(Map<String, dynamic> payload) async {
    if (_frontDeskProvider == null) {
      debugPrint('[Sync Service] No Front Desk provider available');
      return;
    }

    debugPrint('[Sync Service] Handling incoming status update: $payload');

    try {
      // Update Front Desk provider with the payload directly
      await _frontDeskProvider.handleStatusUpdate(payload);
      debugPrint('[Sync Service] Status updated: ${payload['uniqueId']}');
    } catch (e) {
      debugPrint('[Sync Service] Failed to handle status update: $e');
    }
  }

  /// Send new request from Front Desk to Back Office (Front Desk only)
  ///
  /// Called when user submits a new request via Front Desk UI
  Future<bool> sendNewRequest(PosterRequest request) async {
    if (_frontDeskProvider == null || _bleService == null) {
      debugPrint('[Sync Service] No Front Desk provider or BLE service available');
      return false;
    }

    if (!_bleService.isConnected) {
      debugPrint('[Sync Service] Not connected - request will be queued');
      // Request is already saved with isSynced: false by FrontDeskProvider
      return true; // Return true because we successfully queued it
    }

    debugPrint('[Sync Service] Sending new request: ${request.uniqueId}');

    // Try to send with retry logic
    final success = await _writeRequestWithRetry(request);

    if (success) {
      // Mark as synced
      final syncedRequest = request.copyWith(isSynced: true);
      await _persistenceService.saveSubmittedRequest(syncedRequest);
      debugPrint('[Sync Service] Request sent and marked as synced');
    } else {
      debugPrint('[Sync Service] Request send failed - marked as unsynced for later');
      // Already saved with isSynced: false
    }

    return success;
  }

  /// Send status update from Back Office to Front Desk (Back Office only)
  ///
  /// Called when Back Office marks a request as fulfilled
  Future<bool> sendStatusUpdate(PosterRequest request) async {
    if (_backOfficeProvider == null) {
      debugPrint('[Sync Service] No Back Office provider available');
      return false;
    }

    // Check connection based on service type
    bool isConnected = false;
    if (_bleServerService != null) {
      // For Back Office, check if client is connected to server
      isConnected = _bleServerService.isClientConnected;
    } else if (_bleService != null) {
      // For Front Desk, check if connected to server
      isConnected = _bleService.isConnected;
    }

    if (!isConnected) {
      debugPrint('[Sync Service] Not connected - status update will be queued');
      // Update is already saved with isSynced: false by BackOfficeProvider
      return true; // Return true because we successfully queued it
    }

    debugPrint('[Sync Service] Sending status update: ${request.uniqueId}');

    // Try to send with retry logic
    final success = await _sendStatusUpdateWithRetry(request);

    if (success) {
      // Mark as synced
      final syncedRequest = request.copyWith(isSynced: true);
      await _persistenceService.saveFulfilledRequest(syncedRequest);
      debugPrint('[Sync Service] Status update sent and marked as synced');
    } else {
      debugPrint('[Sync Service] Status update send failed - marked as unsynced for later');
      // Already saved with isSynced: false
    }

    return success;
  }
}
