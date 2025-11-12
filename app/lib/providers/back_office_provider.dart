import 'package:flutter/foundation.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../models/poster_request.dart';
import '../services/persistence_service.dart';
import '../services/sync_service.dart';

/// Back Office Data Provider
///
/// Manages all data and operations for the Back Office role:
/// - Active pending queue (requests to be fulfilled)
/// - Fulfilled log (completed requests)
/// - Request fulfillment and status tracking
///
/// Phase 4 Status: INTEGRATED - Connected to BLE services for data synchronization
///
/// Data Flow:
/// 1. Provider receives requests via BLE Request Characteristic (A) from SyncService
/// 2. Provider adds requests to active queue
/// 3. User pulls request via Live Queue screen
/// 4. Provider marks as fulfilled and saves to Hive (fulfilled_requests box)
/// 5. Provider transmits status update via BLE Queue Status Characteristic (B) using SyncService
///
/// Usage:
/// ```dart
/// final backOfficeProvider = Provider.of<BackOfficeProvider>(context);
/// await backOfficeProvider.fulfillRequest(request);
/// ```
class BackOfficeProvider extends ChangeNotifier {
  final PersistenceService _persistenceService;

  // Active queue state
  List<PosterRequest> _activeQueue = [];
  bool _isInitialized = false;

  // Callback to notify BleServerService of queue changes
  Function(List<PosterRequest>)? onQueueChanged;

  // BLE sync service (set when role is selected)
  SyncService? _syncService;

  BackOfficeProvider(this._persistenceService) {
    _initializeListeners();
    _loadInitialQueue();
  }

  /// Set sync service (called after provider initialization when role is selected)
  void setSyncService(SyncService syncService) {
    _syncService = syncService;
  }

  // Getters
  List<PosterRequest> get activeQueue => _activeQueue;
  int get pendingCount => _activeQueue.length;
  bool get isInitialized => _isInitialized;
  bool get hasRequests => _activeQueue.isNotEmpty;

  /// Get fulfilled requests from Hive
  List<PosterRequest> getFulfilledRequests() {
    return _persistenceService.getAllFulfilledRequests();
  }

  /// Get count of fulfilled requests
  int getFulfilledCount() {
    return _persistenceService.getFulfilledCount();
  }

  /// Get count of unsynced fulfilled requests
  ///
  /// Returns the number of fulfilled requests that haven't been transmitted
  /// to Front Desk via BLE yet. Used for offline queue badge indicator.
  int getUnsyncedFulfilledCount() {
    final unsynced = _persistenceService.getUnsyncedFulfilledRequests();
    return unsynced.length;
  }

  /// Initialize Hive box listeners for real-time updates
  void _initializeListeners() {
    // Listen to fulfilled_requests box changes
    Hive.box<PosterRequest>('fulfilled_requests').listenable().addListener(() {
      _notifyQueueChanged();
      notifyListeners();
    });
  }

  /// Load initial queue data
  ///
  /// Phase 4+: Queue is populated via BLE from Front Desk
  /// No mock data - starts empty and receives real requests via BLE
  void _loadInitialQueue() {
    // Start with empty queue
    // Requests will be added via BLE when Front Desk sends them
    _activeQueue = [];
    _isInitialized = true;
    _notifyQueueChanged();
    notifyListeners();
  }

  /// Handle incoming request from BLE
  ///
  /// Called when Front Desk sends Request Characteristic (A) message.
  /// Adds the request to the active queue in chronological order.
  ///
  /// Phase 4 TODO: Wire up to BLE service Request Characteristic (A)
  Future<void> handleIncomingRequest(Map<String, dynamic> bleMessage) async {
    try {
      // Parse BLE message
      final request = PosterRequest.fromJsonSynced(
        bleMessage,
        isSynced: true, // Received via BLE
      );

      // Check for duplicate uniqueId
      final isDuplicate = _activeQueue.any((r) => r.uniqueId == request.uniqueId);
      if (isDuplicate) {
        debugPrint('Warning: Duplicate request received: ${request.uniqueId}');
        return;
      }

      // Add to active queue
      _activeQueue.add(request);

      // Sort by timestampSent (chronological, oldest first)
      _activeQueue.sort((a, b) => a.timestampSent.compareTo(b.timestampSent));

      _notifyQueueChanged();
      notifyListeners();
    } catch (e) {
      debugPrint('Error handling incoming request: $e');
    }
  }

  /// Fulfill a request (mark as pulled)
  ///
  /// Called when Back Office user presses "PULL" button.
  /// Updates request status, saves to fulfilled_requests box,
  /// removes from active queue, and transmits status update via BLE.
  Future<bool> fulfillRequest(PosterRequest request) async {
    try {
      // Create fulfilled version of the request
      final fulfilledRequest = request.copyWith(
        status: RequestStatus.fulfilled,
        timestampPulled: DateTime.now(),
        isSynced: false, // Not yet transmitted via BLE
      );

      // Save to persistent storage (write-immediately pattern)
      await _persistenceService.saveFulfilledRequest(fulfilledRequest);

      // Transmit status update to Front Desk via BLE (if connected)
      if (_syncService != null) {
        final success = await _syncService!.sendStatusUpdate(fulfilledRequest);
        if (!success) {
          debugPrint('[Back Office Provider] BLE transmission failed - status update queued for sync');
          // Status update is already saved with isSynced: false, so it will be synced later
        }
      } else {
        debugPrint('[Back Office Provider] No sync service - offline mode');
      }

      // Remove from active queue
      _activeQueue.removeWhere((r) => r.uniqueId == request.uniqueId);

      _notifyQueueChanged();
      notifyListeners();
      return true;
    } catch (e) {
      debugPrint('Error fulfilling request: $e');
      return false;
    }
  }

  /// Provide full queue state for BLE sync
  ///
  /// Called by SyncService when Front Desk reads Full Queue Sync Characteristic (C)
  /// during reconnection handshake (step 3).
  ///
  /// Returns all requests (active and fulfilled) for reconciliation.
  List<PosterRequest> getFullQueueState() {
    // Combine active queue and fulfilled log
    final allRequests = [
      ..._activeQueue,
      ...getFulfilledRequests(),
    ];

    return allRequests;
  }

  /// Note: syncUnsyncedFulfilledRequests is now handled automatically by
  /// SyncService during the three-step reconnection handshake.
  /// No manual intervention needed from this provider.

  /// Clear all fulfilled requests from persistent storage
  ///
  /// Used by Fulfilled Log screen's "Clear All" function
  Future<bool> clearAllFulfilledRequests() async {
    try {
      await _persistenceService.clearAllFulfilledRequests();
      _notifyQueueChanged();
      notifyListeners();
      return true;
    } catch (e) {
      debugPrint('Error clearing fulfilled requests: $e');
      return false;
    }
  }

  /// Notify BleServerService of queue changes
  void _notifyQueueChanged() {
    onQueueChanged?.call(getFullQueueState());
  }

  /// Refresh active queue
  ///
  /// Called to manually refresh queue state
  /// Phase 4 TODO: May be triggered by BLE events
  void refreshQueue() {
    notifyListeners();
  }

  /// Add a request to the queue manually (for testing)
  ///
  /// This is a development/testing method
  void addRequestToQueue(PosterRequest request) {
    _activeQueue.add(request);
    _activeQueue.sort((a, b) => a.timestampSent.compareTo(b.timestampSent));
    _notifyQueueChanged();
    notifyListeners();
  }

  /// Remove a request from the queue manually (for testing)
  ///
  /// This is a development/testing method
  void removeRequestFromQueue(String uniqueId) {
    _activeQueue.removeWhere((r) => r.uniqueId == uniqueId);
    _notifyQueueChanged();
    notifyListeners();
  }

  @override
  void dispose() {
    // Clean up listeners if needed
    super.dispose();
  }
}
