import 'package:flutter/foundation.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:uuid/uuid.dart';
import '../models/poster_request.dart';
import '../services/persistence_service.dart';
import '../services/sync_service.dart';

/// Front Desk Data Provider
///
/// Manages all data and operations for the Front Desk role:
/// - Submitted poster requests (requests sent to Back Office)
/// - Delivered audit (fulfilled requests received from Back Office)
/// - Request submission and status tracking
///
/// Phase 4 Status: INTEGRATED - Connected to BLE services for data synchronization
///
/// Data Flow:
/// 1. User submits request via Request Entry screen
/// 2. Provider creates PosterRequest with isSynced: false
/// 3. Provider saves to Hive (submitted_requests box)
/// 4. Provider transmits via BLE Request Characteristic (A) using SyncService
/// 5. Provider receives status updates via BLE Queue Status Characteristic (B)
/// 6. Provider updates delivered_audit box with fulfilled requests
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

  // BLE sync service (set when role is selected)
  SyncService? _syncService;

  FrontDeskProvider(this._persistenceService) {
    _initializeListeners();
  }

  /// Set sync service (called after provider initialization when role is selected)
  void setSyncService(SyncService syncService) {
    _syncService = syncService;
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

      // Transmit via BLE to Back Office (if connected)
      if (_syncService != null) {
        final success = await _syncService!.sendNewRequest(newRequest);
        if (!success) {
          debugPrint('[Front Desk Provider] BLE transmission failed - request queued for sync');
          // Request is already saved with isSynced: false, so it will be synced later
        }
      } else {
        debugPrint('[Front Desk Provider] No sync service - offline mode');
      }

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
  /// Called by SyncService when Back Office sends Queue Status Characteristic (B) update
  /// indicating a request has been fulfilled.
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

  /// Clear all delivered audit entries
  ///
  /// Called from settings menu when user wants to clear the delivered audit history.
  /// Returns true if successful, false if an error occurred.
  Future<bool> clearAllDeliveredAudit() async {
    try {
      await _persistenceService.clearAllDeliveredAudit();
      notifyListeners();
      return true;
    } catch (e) {
      debugPrint('Error clearing delivered audit: $e');
      return false;
    }
  }

  /// Get count of delivered audit entries
  ///
  /// Used to show user how many entries will be cleared
  int getDeliveredAuditCount() {
    return _persistenceService.getDeliveredAuditCount();
  }

  /// Note: syncUnsyncedRequests and performFullQueueSync are now handled
  /// automatically by SyncService during the three-step reconnection handshake.
  /// No manual intervention needed from this provider.

  @override
  void dispose() {
    // Clean up listeners if needed
    super.dispose();
  }
}
