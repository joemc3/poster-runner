import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:ble_peripheral/ble_peripheral.dart';
import '../models/poster_request.dart';

/// BLE Server Service (Back Office GATT Server)
///
/// Handles Bluetooth Low Energy GATT server functionality for Back Office device.
/// Uses the ble_peripheral package to advertise and serve BLE characteristics.
///
/// Architecture:
/// - Back Office: GATT Server (advertises, accepts connections, serves data)
/// - Provides 3 characteristics: Request (A), Queue Status (B), Full Queue Sync (C)
///
/// See: project_standards/BLE GATT Architecture Design.md
class BleServerService {
  // Service and characteristic UUIDs (same as in ble_service.dart)
  static const String serviceUuid = '0000A000-0000-1000-8000-00805F9B34FB';
  static const String requestCharacteristicUuid = '0000A001-0000-1000-8000-00805F9B34FB';
  static const String queueStatusCharacteristicUuid = '0000A002-0000-1000-8000-00805F9B34FB';
  static const String fullQueueSyncCharacteristicUuid = '0000A003-0000-1000-8000-00805F9B34FB';

  // Callbacks for data handling
  Function(PosterRequest)? onRequestReceived;
  Function(bool connected)? onClientConnectionChanged;

  // Connection state
  bool _isAdvertising = false;
  bool _isClientConnected = false;

  // Full queue data provider (called when Front Desk reads Characteristic C)
  Future<List<PosterRequest>> Function()? fullQueueProvider;

  /// Is currently advertising
  bool get isAdvertising => _isAdvertising;

  /// Is client currently connected
  bool get isClientConnected => _isClientConnected;

  /// Initialize the BLE peripheral
  Future<void> initialize() async {
    debugPrint('[BLE Server] Initializing');

    try {
      await BlePeripheral.initialize();

      // Set up callbacks
      BlePeripheral.setAdvertisingStatusUpdateCallback(_handleAdvertisingStatusUpdate);
      BlePeripheral.setConnectionStateChangeCallback(_handleConnectionStateChange);
      BlePeripheral.setReadRequestCallback(_handleReadRequest);
      BlePeripheral.setWriteRequestCallback(_handleWriteRequest);

      debugPrint('[BLE Server] Initialization complete');
    } catch (e) {
      debugPrint('[BLE Server] Initialization failed: $e');
      rethrow;
    }
  }

  /// Start advertising as Back Office GATT Server
  Future<void> startAdvertising() async {
    debugPrint('[BLE Server] Starting advertising');

    try {
      // Clear any existing services
      await BlePeripheral.clearServices();

      // Add Poster Runner Service with 3 characteristics
      final service = BleService(
        uuid: serviceUuid,
        primary: true,
        characteristics: [
          // Characteristic A: Request (Front Desk writes new requests)
          BleCharacteristic(
            uuid: requestCharacteristicUuid,
            properties: [
              CharacteristicProperties.write.index,
              CharacteristicProperties.writeWithoutResponse.index,
            ],
            permissions: [
              AttributePermissions.writeable.index,
            ],
          ),

          // Characteristic B: Queue Status (Back Office notifies status updates)
          BleCharacteristic(
            uuid: queueStatusCharacteristicUuid,
            properties: [
              CharacteristicProperties.notify.index,
              CharacteristicProperties.indicate.index,
            ],
            permissions: [
              AttributePermissions.readable.index,
            ],
          ),

          // Characteristic C: Full Queue Sync (Front Desk reads full state)
          BleCharacteristic(
            uuid: fullQueueSyncCharacteristicUuid,
            properties: [
              CharacteristicProperties.read.index,
            ],
            permissions: [
              AttributePermissions.readable.index,
            ],
          ),
        ],
      );

      await BlePeripheral.addService(service);
      debugPrint('[BLE Server] Service added successfully');

      // Start advertising with device name
      await BlePeripheral.startAdvertising(
        services: [serviceUuid],
        localName: 'Poster Runner - Back Office',
      );
      debugPrint('[BLE Server] Advertising started successfully');
    } catch (e) {
      debugPrint('[BLE Server] Failed to start advertising: $e');
      rethrow;
    }
  }

  /// Stop advertising
  Future<void> stopAdvertising() async {
    debugPrint('[BLE Server] Stopping advertising');

    try {
      await BlePeripheral.stopAdvertising();
      _isAdvertising = false;
      debugPrint('[BLE Server] Advertising stopped');
    } catch (e) {
      debugPrint('[BLE Server] Failed to stop advertising: $e');
    }
  }

  /// Send status update to connected Front Desk client
  ///
  /// Uses Queue Status Characteristic (B) with Indicate property
  Future<void> sendStatusUpdate(PosterRequest request) async {
    if (!_isAdvertising) {
      throw StateError('Not advertising - cannot send status update');
    }

    if (!_isClientConnected) {
      debugPrint('[BLE Server] No clients connected - status update queued');
      // Status update will be sent when client connects and performs full sync
      return;
    }

    debugPrint('[BLE Server] Sending status update for ${request.uniqueId}');

    try {
      // Convert to Queue Status JSON format
      final payload = request.toQueueStatusJson();
      final jsonString = jsonEncode(payload);
      final data = Uint8List.fromList(utf8.encode(jsonString));

      // Send notification to connected client
      await BlePeripheral.updateCharacteristic(
        characteristicId: queueStatusCharacteristicUuid,
        value: data,
      );
      debugPrint('[BLE Server] Status update sent successfully');
    } catch (e) {
      debugPrint('[BLE Server] Failed to send status update: $e');
      rethrow;
    }
  }

  // ============================================================================
  // CALLBACK HANDLERS
  // ============================================================================

  /// Handle advertising status changes
  void _handleAdvertisingStatusUpdate(bool advertising, String? error) {
    debugPrint('[BLE Server] Advertising status: advertising=$advertising, error=$error');

    _isAdvertising = advertising;

    if (error != null) {
      debugPrint('[BLE Server] Advertising error: $error');
    }
  }

  /// Handle client connection status changes
  void _handleConnectionStateChange(String deviceId, bool connected) {
    debugPrint('[BLE Server] Connection state changed: deviceId=$deviceId, connected=$connected');

    _isClientConnected = connected;
    onClientConnectionChanged?.call(connected);

    if (connected) {
      debugPrint('[BLE Server] Client connected: $deviceId');
    } else {
      debugPrint('[BLE Server] Client disconnected: $deviceId');
    }
  }

  /// Handle read requests from Front Desk
  ///
  /// Used for Full Queue Sync Characteristic (C)
  ///
  /// Note: This callback must be synchronous. For async operations, cache the data beforehand.
  ReadRequestResult? _handleReadRequest(
      String deviceId, String characteristicId, int offset, Uint8List? value) {
    debugPrint('[BLE Server] Read request from $deviceId: char=$characteristicId, offset=$offset');

    // Only handle reads for Full Queue Sync Characteristic (C)
    if (characteristicId == fullQueueSyncCharacteristicUuid) {
      try {
        // TODO: For production, cache the full queue data in a synchronous variable
        // that gets updated whenever the queue changes. For now, return empty array.
        debugPrint('[BLE Server] Full queue sync read - returning cached data');

        // Return empty array for now (this should be cached data in production)
        return ReadRequestResult(
          value: Uint8List.fromList(utf8.encode('[]')),
          status: 0, // Success
        );
      } catch (e) {
        debugPrint('[BLE Server] Failed to handle read request: $e');
        return ReadRequestResult(
          value: Uint8List(0),
          status: 1, // Error
        );
      }
    }

    // Unknown characteristic
    debugPrint('[BLE Server] Unknown read request for characteristic: $characteristicId');
    return ReadRequestResult(
      value: Uint8List(0),
      status: 1, // Error
    );
  }

  /// Handle write requests from Front Desk
  ///
  /// Used for Request Characteristic (A)
  WriteRequestResult? _handleWriteRequest(
      String deviceId, String characteristicId, int offset, Uint8List? value) {
    if (value == null) {
      debugPrint('[BLE Server] Write request with null value');
      return WriteRequestResult(status: 1); // Error
    }

    debugPrint('[BLE Server] Write request from $deviceId: char=$characteristicId, offset=$offset, ${value.length} bytes');

    // Only handle writes for Request Characteristic (A)
    if (characteristicId == requestCharacteristicUuid) {
      try {
        // Parse incoming request
        final jsonString = utf8.decode(value);
        debugPrint('[BLE Server] Received request: $jsonString');

        final json = jsonDecode(jsonString) as Map<String, dynamic>;
        final posterRequest = PosterRequest.fromJsonSynced(json, isSynced: true);

        debugPrint('[BLE Server] Parsed request: ${posterRequest.uniqueId} - ${posterRequest.posterNumber}');

        // Notify callback
        onRequestReceived?.call(posterRequest);

        return WriteRequestResult(
          status: 0, // Success
        );
      } catch (e) {
        debugPrint('[BLE Server] Failed to handle write request: $e');
        return WriteRequestResult(
          status: 1, // Error
        );
      }
    }

    // Unknown characteristic
    debugPrint('[BLE Server] Unknown write request for characteristic: $characteristicId');
    return WriteRequestResult(
      status: 1, // Error
    );
  }

  /// Dispose of resources
  Future<void> dispose() async {
    await stopAdvertising();
    await BlePeripheral.clearServices();
  }
}
