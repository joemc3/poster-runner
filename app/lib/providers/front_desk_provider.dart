import 'package:flutter/foundation.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:uuid/uuid.dart';
import '../models/poster_request.dart';
import '../services/persistence_service.dart';

/// Front Desk Data Provider
///
/// Manages all data and operations for the Front Desk role:
/// - Submitted poster requests (requests sent to Back Office)
/// - Delivered audit (fulfilled requests received from Back Office)
/// - Request submission and status tracking
///
/// Phase 3 Status: IMPLEMENTED - Full state management for Front Desk operations
/// Phase 4 TODO: Integrate with BLE service for actual data synchronization
///
/// Data Flow:
/// 1. User submits request via Request Entry screen
/// 2. Provider creates PosterRequest with isSynced: false
/// 3. Provider saves to Hive (submitted_requests box)
/// 4. [Phase 4] Provider transmits via BLE Request Characteristic (A)
/// 5. [Phase 4] Provider receives status updates via BLE Queue Status Characteristic (B)
/// 6. [Phase 4] Provider updates delivered_audit box with fulfilled requests
///
/// Usage:
/// ```dart
/// final frontDeskProvider = Provider.of<FrontDeskProvider>(context);
/// await frontDeskProvider.submitRequest('A457');
/// ```
class FrontDeskProvider extends ChangeNotifier {
  final PersistenceService _persistenceService;
  final _uuid = const Uuid();

  // Last submission tracking for UI feedback
  String? _lastSubmittedPoster;
  RequestStatus? _lastSubmissionStatus;
  DateTime? _lastSubmissionTime;
  bool _isSubmitting = false;
  String? _submissionError;

  FrontDeskProvider(this._persistenceService) {
    _initializeListeners();
  }

  // Getters
  String? get lastSubmittedPoster => _lastSubmittedPoster;
  RequestStatus? get lastSubmissionStatus => _lastSubmissionStatus;
  DateTime? get lastSubmissionTime => _lastSubmissionTime;
  bool get isSubmitting => _isSubmitting;
  String? get submissionError => _submissionError;

  /// Initialize Hive box listeners for real-time updates
  void _initializeListeners() {
    // Listen to submitted_requests box changes
    Hive.box<PosterRequest>('submitted_requests').listenable().addListener(() {
      notifyListeners();
    });

    // Listen to delivered_audit box changes
    Hive.box<PosterRequest>('delivered_audit').listenable().addListener(() {
      notifyListeners();
    });
  }

  /// Get all submitted requests from Hive
  List<PosterRequest> getSubmittedRequests() {
    return _persistenceService.getAllSubmittedRequests();
  }

  /// Get all delivered audit entries from Hive
  List<PosterRequest> getDeliveredAudit() {
    return _persistenceService.getAllDeliveredAudit();
  }

  /// Get count of unsynced submitted requests
  ///
  /// Used to determine if sync is needed when BLE connection is established
  int getUnsyncedCount() {
    final unsynced = _persistenceService.getUnsyncedSubmittedRequests();
    return unsynced.length;
  }

  /// Get all unsynced submitted requests
  ///
  /// Phase 4 TODO: Used during BLE reconnection handshake (step 1)
  List<PosterRequest> getUnsyncedRequests() {
    return _persistenceService.getUnsyncedSubmittedRequests();
  }

  /// Submit a new poster request
  ///
  /// Creates a new PosterRequest, saves it to Hive, and marks it for BLE sync.
  ///
  /// Phase 4 TODO: Transmit via BLE Request Characteristic (A)
  Future<bool> submitRequest(String posterNumber) async {
    // Validate input
    if (posterNumber.trim().isEmpty) {
      _submissionError = 'Poster number cannot be empty';
      notifyListeners();
      return false;
    }

    _isSubmitting = true;
    _submissionError = null;
    notifyListeners();

    try {
      // Create new request
      final newRequest = PosterRequest(
        uniqueId: _uuid.v4(),
        posterNumber: posterNumber.trim().toUpperCase(),
        status: RequestStatus.sent,
        timestampSent: DateTime.now(),
        timestampPulled: null,
        isSynced: false, // Will be set to true after BLE transmission
      );

      // Save to Hive database (write-immediately pattern)
      await _persistenceService.saveSubmittedRequest(newRequest);

      // TODO Phase 4: Transmit via BLE to Back Office
      // if (bleConnectionProvider.isConnected) {
      //   final bleMessage = newRequest.toRequestCharacteristicJson();
      //   await bleService.sendRequest(bleMessage);
      //   // Mark as synced after successful transmission
      //   await _markRequestAsSynced(newRequest.uniqueId);
      // }

      // Update UI state
      _lastSubmittedPoster = posterNumber.trim().toUpperCase();
      _lastSubmissionStatus = RequestStatus.sent;
      _lastSubmissionTime = newRequest.timestampSent;
      _isSubmitting = false;
      _submissionError = null;
      notifyListeners();

      return true;
    } catch (e) {
      // Handle error
      _lastSubmissionStatus = null;
      _isSubmitting = false;
      _submissionError = e.toString();
      notifyListeners();
      return false;
    }
  }

  /// Mark a submitted request as synced
  ///
  /// Called after successful BLE transmission
  /// Phase 4 TODO: Wire up to BLE service confirmation
  Future<void> _markRequestAsSynced(String uniqueId) async {
    final request = _persistenceService.getSubmittedRequest(uniqueId);
    if (request != null) {
      final syncedRequest = request.copyWith(isSynced: true);
      await _persistenceService.saveSubmittedRequest(syncedRequest);
    }
  }

  /// Clear last submission feedback
  ///
  /// Used to reset UI state after user acknowledges submission
  void clearLastSubmission() {
    _lastSubmittedPoster = null;
    _lastSubmissionStatus = null;
    _lastSubmissionTime = null;
    _submissionError = null;
    notifyListeners();
  }

  /// Handle incoming status update from BLE
  ///
  /// Called when Back Office sends Queue Status Characteristic (B) update
  /// indicating a request has been fulfilled.
  ///
  /// Phase 4 TODO: Wire up to BLE service Queue Status Characteristic (B)
  Future<void> handleStatusUpdate(Map<String, dynamic> bleMessage) async {
    try {
      // Parse BLE message
      final uniqueId = bleMessage['uniqueId'] as String;
      final status = RequestStatus.values.firstWhere(
        (s) => s.name == bleMessage['status'],
      );
      final timestampPulled = DateTime.parse(bleMessage['timestampPulled'] as String);

      // Find the original request in submitted_requests
      final originalRequest = _persistenceService.getSubmittedRequest(uniqueId);
      if (originalRequest == null) {
        debugPrint('Warning: Received status update for unknown request: $uniqueId');
        return;
      }

      // Create fulfilled version
      final fulfilledRequest = originalRequest.copyWith(
        status: status,
        timestampPulled: timestampPulled,
        isSynced: true, // Received via BLE, so it's synced
      );

      // Save to delivered_audit box
      await _persistenceService.saveToDeliveredAudit(fulfilledRequest);

      // Optionally remove from submitted_requests (or mark as delivered)
      // For now, we'll keep it in submitted_requests to track all submissions
      // await _persistenceService.deleteSubmittedRequest(uniqueId);

      notifyListeners();
    } catch (e) {
      debugPrint('Error handling status update: $e');
    }
  }

  /// Sync all unsynced requests via BLE
  ///
  /// Called during reconnection handshake (step 1)
  /// Phase 4 TODO: Implement with BLE service
  Future<void> syncUnsyncedRequests() async {
    final unsyncedRequests = getUnsyncedRequests();

    // TODO Phase 4: Transmit each unsynced request via BLE
    // for (final request in unsyncedRequests) {
    //   final bleMessage = request.toRequestCharacteristicJson();
    //   await bleService.sendRequest(bleMessage);
    //   await _markRequestAsSynced(request.uniqueId);
    // }
  }

  /// Perform full queue sync via BLE
  ///
  /// Called during reconnection handshake (step 3)
  /// Reads full queue state from Back Office to reconcile any discrepancies
  ///
  /// Phase 4 TODO: Implement with BLE Full Queue Sync Characteristic (C)
  Future<void> performFullQueueSync() async {
    // TODO Phase 4: Read Full Queue Sync Characteristic (C)
    // final fullQueueJson = await bleService.readFullQueue();
    // final allRequests = (fullQueueJson as List)
    //     .map((json) => PosterRequest.fromJson(json))
    //     .toList();
    //
    // // Clear and rebuild delivered_audit box
    // // Note: Need to add clearDeliveredAudit() method to PersistenceService
    // for (final request in allRequests) {
    //   if (request.status == RequestStatus.fulfilled) {
    //     await _persistenceService.saveToDeliveredAudit(request);
    //   }
    // }
    // notifyListeners();
  }

  @override
  void dispose() {
    // Clean up listeners if needed
    super.dispose();
  }
}
