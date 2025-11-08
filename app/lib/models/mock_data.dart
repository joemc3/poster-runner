/// Mock data generator for development and testing
///
/// This file provides sample PosterRequest objects for UI development
/// and testing without requiring a live BLE connection or persistence layer.
///
/// **Usage in UI screens:**
/// ```dart
/// import 'package:app/models/mock_data.dart';
///
/// // Use in stateful widget
/// List<PosterRequest> requests = MockPosterRequests.all;
/// ```
library;

import 'poster_request.dart';

/// Mock data provider for PosterRequest objects
///
/// Contains realistic sample data across all request statuses
/// with varied timestamps and poster numbers for comprehensive testing.
class MockPosterRequests {
  MockPosterRequests._(); // Private constructor to prevent instantiation

  /// Base timestamp for consistent relative time generation
  static final DateTime _now = DateTime.now();

  /// All sample requests (mixed statuses)
  ///
  /// Use this for screens that display multiple statuses
  static final List<PosterRequest> all = [
    ..._sentRequests,
    ..._pendingRequests,
    ..._fulfilledRequests,
  ];

  /// Requests with SENT status
  ///
  /// Created by Front Desk, awaiting Back Office acknowledgment
  static final List<PosterRequest> _sentRequests = [
    PosterRequest(
      uniqueId: 'sent-001',
      posterNumber: 'A123',
      timestampSent: _now.subtract(const Duration(minutes: 2)),
      status: RequestStatus.sent,
      isSynced: false, // Not yet acknowledged
    ),
    PosterRequest(
      uniqueId: 'sent-002',
      posterNumber: 'B456',
      timestampSent: _now.subtract(const Duration(minutes: 1)),
      status: RequestStatus.sent,
      isSynced: false,
    ),
    PosterRequest(
      uniqueId: 'sent-003',
      posterNumber: 'C789',
      timestampSent: _now.subtract(const Duration(seconds: 30)),
      status: RequestStatus.sent,
      isSynced: false,
    ),
  ];

  /// Requests with PENDING status
  ///
  /// Acknowledged by Back Office, currently being fulfilled
  static final List<PosterRequest> _pendingRequests = [
    PosterRequest(
      uniqueId: 'pending-001',
      posterNumber: 'A457',
      timestampSent: _now.subtract(const Duration(minutes: 15)),
      status: RequestStatus.pending,
      isSynced: true, // Acknowledged and synced
    ),
    PosterRequest(
      uniqueId: 'pending-002',
      posterNumber: 'B211',
      timestampSent: _now.subtract(const Duration(minutes: 12)),
      status: RequestStatus.pending,
      isSynced: true,
    ),
    PosterRequest(
      uniqueId: 'pending-003',
      posterNumber: 'C003',
      timestampSent: _now.subtract(const Duration(minutes: 10)),
      status: RequestStatus.pending,
      isSynced: true,
    ),
    PosterRequest(
      uniqueId: 'pending-004',
      posterNumber: 'D112',
      timestampSent: _now.subtract(const Duration(minutes: 8)),
      status: RequestStatus.pending,
      isSynced: true,
    ),
    PosterRequest(
      uniqueId: 'pending-005',
      posterNumber: 'E333',
      timestampSent: _now.subtract(const Duration(minutes: 5)),
      status: RequestStatus.pending,
      isSynced: true,
    ),
  ];

  /// Requests with FULFILLED status
  ///
  /// Completed by Back Office, visible in audit logs
  static final List<PosterRequest> _fulfilledRequests = [
    PosterRequest(
      uniqueId: 'fulfilled-001',
      posterNumber: 'A001',
      timestampSent: _now.subtract(const Duration(hours: 2, minutes: 30)),
      timestampPulled: _now.subtract(const Duration(hours: 2, minutes: 15)),
      status: RequestStatus.fulfilled,
      isSynced: true,
    ),
    PosterRequest(
      uniqueId: 'fulfilled-002',
      posterNumber: 'A002',
      timestampSent: _now.subtract(const Duration(hours: 2, minutes: 20)),
      timestampPulled: _now.subtract(const Duration(hours: 2, minutes: 10)),
      status: RequestStatus.fulfilled,
      isSynced: true,
    ),
    PosterRequest(
      uniqueId: 'fulfilled-003',
      posterNumber: 'B100',
      timestampSent: _now.subtract(const Duration(hours: 2)),
      timestampPulled: _now.subtract(const Duration(hours: 1, minutes: 50)),
      status: RequestStatus.fulfilled,
      isSynced: true,
    ),
    PosterRequest(
      uniqueId: 'fulfilled-004',
      posterNumber: 'B101',
      timestampSent: _now.subtract(const Duration(hours: 1, minutes: 45)),
      timestampPulled: _now.subtract(const Duration(hours: 1, minutes: 30)),
      status: RequestStatus.fulfilled,
      isSynced: true,
    ),
    PosterRequest(
      uniqueId: 'fulfilled-005',
      posterNumber: 'C050',
      timestampSent: _now.subtract(const Duration(hours: 1, minutes: 30)),
      timestampPulled: _now.subtract(const Duration(hours: 1, minutes: 20)),
      status: RequestStatus.fulfilled,
      isSynced: true,
    ),
    PosterRequest(
      uniqueId: 'fulfilled-006',
      posterNumber: 'D200',
      timestampSent: _now.subtract(const Duration(hours: 1, minutes: 15)),
      timestampPulled: _now.subtract(const Duration(hours: 1)),
      status: RequestStatus.fulfilled,
      isSynced: true,
    ),
    PosterRequest(
      uniqueId: 'fulfilled-007',
      posterNumber: 'E500',
      timestampSent: _now.subtract(const Duration(minutes: 50)),
      timestampPulled: _now.subtract(const Duration(minutes: 40)),
      status: RequestStatus.fulfilled,
      isSynced: true,
    ),
  ];

  /// Requests filtered by SENT status only
  static List<PosterRequest> get sentRequests =>
      all.where((r) => r.status == RequestStatus.sent).toList();

  /// Requests filtered by PENDING status only
  static List<PosterRequest> get pendingRequests =>
      all.where((r) => r.status == RequestStatus.pending).toList();

  /// Requests filtered by FULFILLED status only
  static List<PosterRequest> get fulfilledRequests =>
      all.where((r) => r.status == RequestStatus.fulfilled).toList();

  /// Requests that need to be synced (isSynced: false)
  ///
  /// Useful for testing offline scenarios and sync logic
  static List<PosterRequest> get unsyncedRequests =>
      all.where((r) => !r.isSynced).toList();

  /// Live Queue view (for Back Office)
  ///
  /// Returns PENDING requests sorted by timestampSent (chronological, oldest first)
  /// This matches the sorting requirement for the Back Office Live Queue screen
  static List<PosterRequest> get liveQueue {
    final pending = all.where((r) => r.status == RequestStatus.pending).toList();
    pending.sort((a, b) => a.timestampSent.compareTo(b.timestampSent));
    return pending;
  }

  /// Delivered Audit view (for Front Desk)
  ///
  /// Returns FULFILLED requests sorted by posterNumber (alphanumeric ascending)
  /// This matches the sorting requirement for the Front Desk Delivered Audit screen
  static List<PosterRequest> get deliveredAudit {
    final fulfilled =
        all.where((r) => r.status == RequestStatus.fulfilled).toList();
    fulfilled.sort((a, b) => a.posterNumber.compareTo(b.posterNumber));
    return fulfilled;
  }

  /// Fulfilled Log view (for Back Office)
  ///
  /// Returns FULFILLED requests sorted by timestampPulled (most recent first)
  /// This matches the sorting requirement for the Back Office Fulfilled Log screen
  static List<PosterRequest> get fulfilledLog {
    final fulfilled =
        all.where((r) => r.status == RequestStatus.fulfilled).toList();
    fulfilled.sort((a, b) {
      if (a.timestampPulled == null && b.timestampPulled == null) return 0;
      if (a.timestampPulled == null) return 1;
      if (b.timestampPulled == null) return -1;
      return b.timestampPulled!.compareTo(a.timestampPulled!);
    });
    return fulfilled;
  }

  /// Creates a new mock request with realistic data
  ///
  /// Useful for simulating new request creation during development
  ///
  /// **Example:**
  /// ```dart
  /// final newRequest = MockPosterRequests.createMockRequest(
  ///   posterNumber: 'Z999',
  ///   status: RequestStatus.sent,
  /// );
  /// ```
  static PosterRequest createMockRequest({
    String? uniqueId,
    required String posterNumber,
    DateTime? timestampSent,
    DateTime? timestampPulled,
    RequestStatus status = RequestStatus.sent,
    bool isSynced = false,
  }) {
    return PosterRequest(
      uniqueId: uniqueId ?? 'mock-${DateTime.now().millisecondsSinceEpoch}',
      posterNumber: posterNumber,
      timestampSent: timestampSent ?? DateTime.now(),
      timestampPulled: timestampPulled,
      status: status,
      isSynced: isSynced,
    );
  }

  /// Simulates a batch of requests for stress testing
  ///
  /// Generates [count] requests with sequential poster numbers
  static List<PosterRequest> generateBatch({
    int count = 10,
    RequestStatus status = RequestStatus.pending,
    String prefix = 'X',
  }) {
    return List.generate(
      count,
      (index) => PosterRequest(
        uniqueId: 'batch-$prefix-$index',
        posterNumber: '$prefix${(index + 1).toString().padLeft(3, '0')}',
        timestampSent: _now.subtract(Duration(minutes: count - index)),
        timestampPulled: status == RequestStatus.fulfilled
            ? _now.subtract(Duration(minutes: count - index - 5))
            : null,
        status: status,
        isSynced: true,
      ),
    );
  }

  /// Sample data for offline scenario testing
  ///
  /// Mix of synced and unsynced requests to test reconnection logic
  static List<PosterRequest> get offlineScenario => [
        // Recently created, not yet synced
        PosterRequest(
          uniqueId: 'offline-001',
          posterNumber: 'X100',
          timestampSent: _now.subtract(const Duration(seconds: 10)),
          status: RequestStatus.sent,
          isSynced: false,
        ),
        // Acknowledged before disconnect, now fulfilled but not synced
        PosterRequest(
          uniqueId: 'offline-002',
          posterNumber: 'X101',
          timestampSent: _now.subtract(const Duration(minutes: 20)),
          timestampPulled: _now.subtract(const Duration(minutes: 5)),
          status: RequestStatus.fulfilled,
          isSynced: false,
        ),
        // Synced requests from before disconnect
        PosterRequest(
          uniqueId: 'offline-003',
          posterNumber: 'X102',
          timestampSent: _now.subtract(const Duration(minutes: 30)),
          status: RequestStatus.pending,
          isSynced: true,
        ),
      ];
}
