import 'package:flutter/foundation.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../models/poster_request.dart';
import '../models/mock_data.dart';
import '../services/persistence_service.dart';

/// Back Office Data Provider
///
/// Manages all data and operations for the Back Office role:
/// - Active pending queue (requests to be fulfilled)
/// - Fulfilled log (completed requests)
/// - Request fulfillment and status tracking
///
/// Phase 3 Status: IMPLEMENTED - Full state management for Back Office operations
/// Phase 4 TODO: Integrate with BLE service for actual data synchronization
///
/// Data Flow:
/// 1. [Phase 4] Provider receives requests via BLE Request Characteristic (A)
/// 2. Provider adds requests to active queue
/// 3. User pulls request via Live Queue screen
/// 4. Provider marks as fulfilled and saves to Hive (fulfilled_requests box)
/// 5. [Phase 4] Provider transmits status update via BLE Queue Status Characteristic (B)
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

  BackOfficeProvider(this._persistenceService) {
    _initializeListeners();
    _loadInitialQueue();
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

  /// Initialize Hive box listeners for real-time updates
  void _initializeListeners() {
    // Listen to fulfilled_requests box changes
    Hive.box<PosterRequest>('fulfilled_requests').listenable().addListener(() {
      notifyListeners();
    });
  }

  /// Load initial queue data
  ///
  /// Phase 3: Uses mock data for testing
  /// Phase 4 TODO: Load from BLE sync or persistent queue storage
  void _loadInitialQueue() {
    // Use mock data for Phase 3 testing
    // This simulates requests received from Front Desk via BLE
    _activeQueue = List.from(MockPosterRequests.liveQueue);
    _isInitialized = true;
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
  ///
  /// Phase 4 TODO: Transmit via BLE Queue Status Characteristic (B)
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

      // TODO Phase 4: Transmit to Front Desk via BLE Queue Status Characteristic (B)
      // if (bleConnectionProvider.isConnected) {
      //   final bleMessage = fulfilledRequest.toQueueStatusJson();
      //   await bleService.sendQueueStatusUpdate(bleMessage);
      //   // Mark as synced after successful transmission
      //   await _markFulfilledAsSynced(fulfilledRequest.uniqueId);
      // }

      // Remove from active queue
      _activeQueue.removeWhere((r) => r.uniqueId == request.uniqueId);

      notifyListeners();
      return true;
    } catch (e) {
      debugPrint('Error fulfilling request: $e');
      return false;
    }
  }

  /// Mark a fulfilled request as synced
  ///
  /// Called after successful BLE transmission
  /// Phase 4 TODO: Wire up to BLE service confirmation
  Future<void> _markFulfilledAsSynced(String uniqueId) async {
    final request = _persistenceService.getFulfilledRequest(uniqueId);
    if (request != null) {
      final syncedRequest = request.copyWith(isSynced: true);
      await _persistenceService.saveFulfilledRequest(syncedRequest);
    }
  }

  /// Get all unsynced fulfilled requests
  ///
  /// Used during BLE reconnection handshake (step 2)
  /// Phase 4 TODO: Wire up to reconnection logic
  List<PosterRequest> getUnsyncedFulfilledRequests() {
    final allFulfilled = _persistenceService.getAllFulfilledRequests();
    return allFulfilled.where((r) => !r.isSynced).toList();
  }

  /// Sync all unsynced fulfilled requests via BLE
  ///
  /// Called during reconnection handshake (step 2)
  /// Phase 4 TODO: Implement with BLE service
  Future<void> syncUnsyncedFulfilledRequests() async {
    final unsyncedRequests = getUnsyncedFulfilledRequests();

    // TODO Phase 4: Transmit each unsynced status update via BLE
    // for (final request in unsyncedRequests) {
    //   final bleMessage = request.toQueueStatusJson();
    //   await bleService.sendQueueStatusUpdate(bleMessage);
    //   await _markFulfilledAsSynced(request.uniqueId);
    // }
  }

  /// Provide full queue state via BLE
  ///
  /// Called when Front Desk reads Full Queue Sync Characteristic (C)
  /// during reconnection handshake (step 3)
  ///
  /// Phase 4 TODO: Implement with BLE Full Queue Sync Characteristic (C)
  List<Map<String, dynamic>> getFullQueueState() {
    // Combine active queue and fulfilled log
    final allRequests = [
      ..._activeQueue,
      ...getFulfilledRequests(),
    ];

    return allRequests.map((r) => r.toJson()).toList();
  }

  /// Clear all fulfilled requests from persistent storage
  ///
  /// Used by Fulfilled Log screen's "Clear All" function
  Future<bool> clearAllFulfilledRequests() async {
    try {
      await _persistenceService.clearAllFulfilledRequests();
      notifyListeners();
      return true;
    } catch (e) {
      debugPrint('Error clearing fulfilled requests: $e');
      return false;
    }
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
    notifyListeners();
  }

  /// Remove a request from the queue manually (for testing)
  ///
  /// This is a development/testing method
  void removeRequestFromQueue(String uniqueId) {
    _activeQueue.removeWhere((r) => r.uniqueId == uniqueId);
    notifyListeners();
  }

  @override
  void dispose() {
    // Clean up listeners if needed
    super.dispose();
  }
}
