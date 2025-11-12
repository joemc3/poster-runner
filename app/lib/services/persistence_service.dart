/// Hive Persistence Service for Poster Requests
///
/// Handles all local storage operations using Hive NoSQL database.
/// Implements the write-immediately pattern to ensure no data loss
/// during BLE disconnections.
library;

import 'package:hive_flutter/hive_flutter.dart';
import '../models/poster_request.dart';

/// Service for managing persistent storage of poster requests
///
/// **Key Principles:**
/// - Write-immediately pattern: All state changes are persisted BEFORE confirming to user
/// - Single source of truth: Hive box contains all fulfilled requests
/// - Offline-first: No network/BLE required for data operations
///
/// **Box Structure (Back Office):**
/// - Box name: 'fulfilled_requests'
/// - Key: PosterRequest.uniqueId (String)
/// - Value: PosterRequest object
///
/// **Box Structure (Front Desk):**
/// - Box name: 'submitted_requests' - Requests created by Front Desk
/// - Box name: 'delivered_audit' - Fulfilled requests synced from Back Office
/// - Key: PosterRequest.uniqueId (String)
/// - Value: PosterRequest object
class PersistenceService {
  // Back Office boxes
  static const String _fulfilledBoxName = 'fulfilled_requests';

  // Front Desk boxes
  static const String _submittedBoxName = 'submitted_requests';
  static const String _deliveredAuditBoxName = 'delivered_audit';

  Box<PosterRequest>? _fulfilledBox;
  Box<PosterRequest>? _submittedBox;
  Box<PosterRequest>? _deliveredAuditBox;

  /// Initialize Hive and open boxes
  ///
  /// Must be called before any other operations.
  /// Typically called in main() before runApp().
  ///
  /// **Example:**
  /// ```dart
  /// void main() async {
  ///   await Hive.initFlutter();
  ///   final persistenceService = PersistenceService();
  ///   await persistenceService.initialize();
  ///   runApp(MyApp());
  /// }
  /// ```
  Future<void> initialize() async {
    // Register type adapters if not already registered
    if (!Hive.isAdapterRegistered(0)) {
      Hive.registerAdapter(PosterRequestAdapter());
    }
    if (!Hive.isAdapterRegistered(1)) {
      Hive.registerAdapter(RequestStatusAdapter());
    }

    // Open boxes (both Back Office and Front Desk)
    _fulfilledBox = await Hive.openBox<PosterRequest>(_fulfilledBoxName);
    _submittedBox = await Hive.openBox<PosterRequest>(_submittedBoxName);
    _deliveredAuditBox = await Hive.openBox<PosterRequest>(_deliveredAuditBoxName);
  }

  /// Save a fulfilled request to persistent storage
  ///
  /// Uses the request's uniqueId as the key for fast lookups.
  /// Overwrites if a request with the same uniqueId already exists.
  ///
  /// **Write-Immediately Pattern:**
  /// This method completes the write to disk before returning,
  /// ensuring the data is safe even if the app crashes immediately after.
  ///
  /// **Example:**
  /// ```dart
  /// final updatedRequest = request.copyWith(
  ///   status: RequestStatus.fulfilled,
  ///   timestampPulled: DateTime.now(),
  /// );
  /// await persistenceService.saveFulfilledRequest(updatedRequest);
  /// ```
  Future<void> saveFulfilledRequest(PosterRequest request) async {
    if (_fulfilledBox == null) {
      throw StateError('PersistenceService not initialized. Call initialize() first.');
    }

    // Validate request is actually fulfilled
    if (request.status != RequestStatus.fulfilled) {
      throw ArgumentError('Can only save fulfilled requests. Status: ${request.status.name}');
    }

    // Write to Hive (this is atomic and crash-safe)
    await _fulfilledBox!.put(request.uniqueId, request);
  }

  /// Retrieve all fulfilled requests
  ///
  /// Returns a list of all fulfilled requests stored in Hive.
  /// List is unordered - caller should sort as needed.
  ///
  /// **Example:**
  /// ```dart
  /// final allFulfilled = persistenceService.getAllFulfilledRequests();
  /// // Sort alphabetically by poster number
  /// allFulfilled.sort((a, b) => a.posterNumber.compareTo(b.posterNumber));
  /// ```
  List<PosterRequest> getAllFulfilledRequests() {
    if (_fulfilledBox == null) {
      throw StateError('PersistenceService not initialized. Call initialize() first.');
    }

    return _fulfilledBox!.values.toList();
  }

  /// Retrieve a specific fulfilled request by uniqueId
  ///
  /// Returns null if not found.
  ///
  /// **Example:**
  /// ```dart
  /// final request = persistenceService.getFulfilledRequest('uuid-123');
  /// if (request != null) {
  ///   print('Found: ${request.posterNumber}');
  /// }
  /// ```
  PosterRequest? getFulfilledRequest(String uniqueId) {
    if (_fulfilledBox == null) {
      throw StateError('PersistenceService not initialized. Call initialize() first.');
    }

    return _fulfilledBox!.get(uniqueId);
  }

  /// Delete a fulfilled request by uniqueId
  ///
  /// Returns true if the request was found and deleted, false otherwise.
  ///
  /// **Example:**
  /// ```dart
  /// final deleted = await persistenceService.deleteFulfilledRequest('uuid-123');
  /// if (deleted) {
  ///   print('Request deleted');
  /// }
  /// ```
  Future<bool> deleteFulfilledRequest(String uniqueId) async {
    if (_fulfilledBox == null) {
      throw StateError('PersistenceService not initialized. Call initialize() first.');
    }

    if (_fulfilledBox!.containsKey(uniqueId)) {
      await _fulfilledBox!.delete(uniqueId);
      return true;
    }
    return false;
  }

  /// Clear all fulfilled requests
  ///
  /// **WARNING:** This permanently deletes all data.
  /// Use with caution - typically only for testing or admin functions.
  ///
  /// **Example:**
  /// ```dart
  /// await persistenceService.clearAllFulfilledRequests();
  /// ```
  Future<void> clearAllFulfilledRequests() async {
    if (_fulfilledBox == null) {
      throw StateError('PersistenceService not initialized. Call initialize() first.');
    }

    await _fulfilledBox!.clear();
  }

  /// Get count of fulfilled requests
  ///
  /// Efficient way to get the total number without loading all data.
  ///
  /// **Example:**
  /// ```dart
  /// final count = persistenceService.getFulfilledCount();
  /// print('Total fulfilled: $count');
  /// ```
  int getFulfilledCount() {
    if (_fulfilledBox == null) {
      throw StateError('PersistenceService not initialized. Call initialize() first.');
    }

    return _fulfilledBox!.length;
  }

  /// Listen to changes in the fulfilled requests box
  ///
  /// Returns a stream that emits BoxEvent whenever data changes.
  /// Useful for reactive UI updates.
  ///
  /// **Example:**
  /// ```dart
  /// persistenceService.watchFulfilledRequests().listen((event) {
  ///   print('Data changed: ${event.key}');
  ///   // Refresh UI
  /// });
  /// ```
  Stream<BoxEvent> watchFulfilledRequests() {
    if (_fulfilledBox == null) {
      throw StateError('PersistenceService not initialized. Call initialize() first.');
    }

    return _fulfilledBox!.watch();
  }

  /// Close all boxes
  ///
  /// Should be called when the app is shutting down.
  /// Not typically needed as Hive auto-closes on app termination.
  Future<void> dispose() async {
    await _fulfilledBox?.close();
    await _submittedBox?.close();
    await _deliveredAuditBox?.close();
  }

  /// Check if service is initialized
  bool get isInitialized => _fulfilledBox != null && _submittedBox != null && _deliveredAuditBox != null;

  // ============================================================================
  // FRONT DESK METHODS
  // ============================================================================

  /// Save a submitted request to persistent storage (Front Desk)
  ///
  /// Stores requests created by the Front Desk that need to be synced to Back Office.
  /// Uses the request's uniqueId as the key for fast lookups.
  ///
  /// **Write-Immediately Pattern:**
  /// This method completes the write to disk before returning,
  /// ensuring the data is safe even if the app crashes immediately after.
  ///
  /// **Example:**
  /// ```dart
  /// final newRequest = PosterRequest(
  ///   uniqueId: Uuid().v4(),
  ///   posterNumber: 'A457',
  ///   status: RequestStatus.sent,
  ///   timestampSent: DateTime.now(),
  ///   isSynced: false,
  /// );
  /// await persistenceService.saveSubmittedRequest(newRequest);
  /// ```
  Future<void> saveSubmittedRequest(PosterRequest request) async {
    if (_submittedBox == null) {
      throw StateError('PersistenceService not initialized. Call initialize() first.');
    }

    // Validate request is sent status (newly created)
    if (request.status != RequestStatus.sent) {
      throw ArgumentError('Can only save sent requests. Status: ${request.status.name}');
    }

    // Write to Hive (this is atomic and crash-safe)
    await _submittedBox!.put(request.uniqueId, request);
  }

  /// Retrieve all submitted requests (Front Desk)
  ///
  /// Returns a list of all submitted requests stored in Hive.
  /// List is unordered - caller should sort as needed.
  ///
  /// **Example:**
  /// ```dart
  /// final allSubmitted = persistenceService.getAllSubmittedRequests();
  /// // Sort chronologically by timestamp
  /// allSubmitted.sort((a, b) => a.timestampSent.compareTo(b.timestampSent));
  /// ```
  List<PosterRequest> getAllSubmittedRequests() {
    if (_submittedBox == null) {
      throw StateError('PersistenceService not initialized. Call initialize() first.');
    }

    return _submittedBox!.values.toList();
  }

  /// Retrieve a specific submitted request by uniqueId (Front Desk)
  ///
  /// Returns null if not found.
  ///
  /// **Example:**
  /// ```dart
  /// final request = persistenceService.getSubmittedRequest('uuid-123');
  /// if (request != null) {
  ///   print('Found: ${request.posterNumber}');
  /// }
  /// ```
  PosterRequest? getSubmittedRequest(String uniqueId) {
    if (_submittedBox == null) {
      throw StateError('PersistenceService not initialized. Call initialize() first.');
    }

    return _submittedBox!.get(uniqueId);
  }

  /// Update a submitted request's sync status (Front Desk)
  ///
  /// Used to mark a request as synced after successful BLE transmission.
  ///
  /// **Example:**
  /// ```dart
  /// final updatedRequest = request.copyWith(isSynced: true);
  /// await persistenceService.updateSubmittedRequest(updatedRequest);
  /// ```
  Future<void> updateSubmittedRequest(PosterRequest request) async {
    if (_submittedBox == null) {
      throw StateError('PersistenceService not initialized. Call initialize() first.');
    }

    await _submittedBox!.put(request.uniqueId, request);
  }

  /// Delete a submitted request by uniqueId (Front Desk)
  ///
  /// Returns true if the request was found and deleted, false otherwise.
  ///
  /// **Example:**
  /// ```dart
  /// final deleted = await persistenceService.deleteSubmittedRequest('uuid-123');
  /// if (deleted) {
  ///   print('Request deleted');
  /// }
  /// ```
  Future<bool> deleteSubmittedRequest(String uniqueId) async {
    if (_submittedBox == null) {
      throw StateError('PersistenceService not initialized. Call initialize() first.');
    }

    if (_submittedBox!.containsKey(uniqueId)) {
      await _submittedBox!.delete(uniqueId);
      return true;
    }
    return false;
  }

  /// Get count of submitted requests (Front Desk)
  ///
  /// Efficient way to get the total number without loading all data.
  ///
  /// **Example:**
  /// ```dart
  /// final count = persistenceService.getSubmittedCount();
  /// print('Total submitted: $count');
  /// ```
  int getSubmittedCount() {
    if (_submittedBox == null) {
      throw StateError('PersistenceService not initialized. Call initialize() first.');
    }

    return _submittedBox!.length;
  }

  /// Get all unsynced submitted requests (Front Desk)
  ///
  /// Returns only requests where isSynced is false.
  /// Used during reconnection to sync pending requests to Back Office.
  ///
  /// **Example:**
  /// ```dart
  /// final unsynced = persistenceService.getUnsyncedSubmittedRequests();
  /// for (final request in unsynced) {
  ///   // Transmit via BLE
  /// }
  /// ```
  List<PosterRequest> getUnsyncedSubmittedRequests() {
    if (_submittedBox == null) {
      throw StateError('PersistenceService not initialized. Call initialize() first.');
    }

    return _submittedBox!.values.where((request) => !request.isSynced).toList();
  }

  /// Listen to changes in the submitted requests box (Front Desk)
  ///
  /// Returns a stream that emits BoxEvent whenever data changes.
  /// Useful for reactive UI updates.
  ///
  /// **Example:**
  /// ```dart
  /// persistenceService.watchSubmittedRequests().listen((event) {
  ///   print('Data changed: ${event.key}');
  ///   // Refresh UI
  /// });
  /// ```
  Stream<BoxEvent> watchSubmittedRequests() {
    if (_submittedBox == null) {
      throw StateError('PersistenceService not initialized. Call initialize() first.');
    }

    return _submittedBox!.watch();
  }

  /// Save a delivered audit entry to persistent storage (Front Desk)
  ///
  /// Stores fulfilled requests synced from Back Office for the audit trail.
  /// Uses the request's uniqueId as the key for fast lookups.
  ///
  /// **Example:**
  /// ```dart
  /// // Received fulfilled status update via BLE
  /// await persistenceService.saveToDeliveredAudit(fulfilledRequest);
  /// ```
  Future<void> saveToDeliveredAudit(PosterRequest request) async {
    if (_deliveredAuditBox == null) {
      throw StateError('PersistenceService not initialized. Call initialize() first.');
    }

    // Validate request is fulfilled
    if (request.status != RequestStatus.fulfilled) {
      throw ArgumentError('Can only save fulfilled requests to audit. Status: ${request.status.name}');
    }

    // Write to Hive (this is atomic and crash-safe)
    await _deliveredAuditBox!.put(request.uniqueId, request);
  }

  /// Retrieve all delivered audit entries (Front Desk)
  ///
  /// Returns a list of all fulfilled requests in the audit trail.
  /// List is unordered - caller should sort as needed (typically by poster number).
  ///
  /// **Example:**
  /// ```dart
  /// final allDelivered = persistenceService.getAllDeliveredAudit();
  /// // Sort alphabetically by poster number
  /// allDelivered.sort((a, b) => a.posterNumber.compareTo(b.posterNumber));
  /// ```
  List<PosterRequest> getAllDeliveredAudit() {
    if (_deliveredAuditBox == null) {
      throw StateError('PersistenceService not initialized. Call initialize() first.');
    }

    return _deliveredAuditBox!.values.toList();
  }

  /// Retrieve a specific delivered audit entry by uniqueId (Front Desk)
  ///
  /// Returns null if not found.
  ///
  /// **Example:**
  /// ```dart
  /// final request = persistenceService.getDeliveredAuditEntry('uuid-123');
  /// if (request != null) {
  ///   print('Found delivered: ${request.posterNumber}');
  /// }
  /// ```
  PosterRequest? getDeliveredAuditEntry(String uniqueId) {
    if (_deliveredAuditBox == null) {
      throw StateError('PersistenceService not initialized. Call initialize() first.');
    }

    return _deliveredAuditBox!.get(uniqueId);
  }

  /// Delete a delivered audit entry by uniqueId (Front Desk)
  ///
  /// Returns true if the entry was found and deleted, false otherwise.
  ///
  /// **Example:**
  /// ```dart
  /// final deleted = await persistenceService.deleteDeliveredAuditEntry('uuid-123');
  /// if (deleted) {
  ///   print('Audit entry deleted');
  /// }
  /// ```
  Future<bool> deleteDeliveredAuditEntry(String uniqueId) async {
    if (_deliveredAuditBox == null) {
      throw StateError('PersistenceService not initialized. Call initialize() first.');
    }

    if (_deliveredAuditBox!.containsKey(uniqueId)) {
      await _deliveredAuditBox!.delete(uniqueId);
      return true;
    }
    return false;
  }

  /// Get count of delivered audit entries (Front Desk)
  ///
  /// Efficient way to get the total number without loading all data.
  ///
  /// **Example:**
  /// ```dart
  /// final count = persistenceService.getDeliveredAuditCount();
  /// print('Total delivered: $count');
  /// ```
  int getDeliveredAuditCount() {
    if (_deliveredAuditBox == null) {
      throw StateError('PersistenceService not initialized. Call initialize() first.');
    }

    return _deliveredAuditBox!.length;
  }

  /// Listen to changes in the delivered audit box (Front Desk)
  ///
  /// Returns a stream that emits BoxEvent whenever data changes.
  /// Useful for reactive UI updates.
  ///
  /// **Example:**
  /// ```dart
  /// persistenceService.watchDeliveredAudit().listen((event) {
  ///   print('Data changed: ${event.key}');
  ///   // Refresh UI
  /// });
  /// ```
  Stream<BoxEvent> watchDeliveredAudit() {
    if (_deliveredAuditBox == null) {
      throw StateError('PersistenceService not initialized. Call initialize() first.');
    }

    return _deliveredAuditBox!.watch();
  }

  /// Clear all delivered audit entries (Front Desk)
  ///
  /// **WARNING:** This permanently deletes all delivered audit data.
  /// Use with caution - typically only for admin functions or user-requested cleanup.
  ///
  /// **Example:**
  /// ```dart
  /// await persistenceService.clearAllDeliveredAudit();
  /// ```
  Future<void> clearAllDeliveredAudit() async {
    if (_deliveredAuditBox == null) {
      throw StateError('PersistenceService not initialized. Call initialize() first.');
    }

    await _deliveredAuditBox!.clear();
  }

  /// Clear all Front Desk data
  ///
  /// **WARNING:** This permanently deletes all submitted requests and delivered audit data.
  /// Use with caution - typically only for testing or admin functions.
  ///
  /// **Example:**
  /// ```dart
  /// await persistenceService.clearAllFrontDeskData();
  /// ```
  Future<void> clearAllFrontDeskData() async {
    if (_submittedBox == null || _deliveredAuditBox == null) {
      throw StateError('PersistenceService not initialized. Call initialize() first.');
    }

    await _submittedBox!.clear();
    await _deliveredAuditBox!.clear();
  }
}
