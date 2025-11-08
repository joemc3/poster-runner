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
/// **Box Structure:**
/// - Box name: 'fulfilled_requests'
/// - Key: PosterRequest.uniqueId (String)
/// - Value: PosterRequest object
class PersistenceService {
  static const String _fulfilledBoxName = 'fulfilled_requests';

  Box<PosterRequest>? _fulfilledBox;

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

    // Open boxes
    _fulfilledBox = await Hive.openBox<PosterRequest>(_fulfilledBoxName);
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
  }

  /// Check if service is initialized
  bool get isInitialized => _fulfilledBox != null;
}
