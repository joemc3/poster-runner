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
/// See: docs/specs/BLE GATT Architecture Design.md
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

  // Buffer for reassembling fragmented write requests
  final Map<String, List<int>> _writeBuffers = {};
  final Map<String, Timer> _writeTimers = {};

  // Full queue data provider (called when Front Desk reads Characteristic C)
  set fullQueueProvider(List<PosterRequest> queue) {
    _cachedQueue = queue;
  }

  List<PosterRequest> _cachedQueue = [];

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
      debugPrint('[BLE Server] Clearing existing services...');
      await BlePeripheral.clearServices();

      // Add delay to allow cleanup to complete (especially on macOS)
      await Future.delayed(const Duration(seconds: 1));

      // Add Poster Runner Service with 3 characteristics
      debugPrint('[BLE Server] Creating GATT service...');
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
                    // Note: CCCD descriptor is automatically added by ble_peripheral when notify property is set
                    BleCharacteristic(
                      uuid: queueStatusCharacteristicUuid,
                      properties: [
                        CharacteristicProperties.notify.index,
                        CharacteristicProperties.read.index, // Allow reading current value
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
                    ),        ],
      );

      // Add service with extended timeout for macOS
      debugPrint('[BLE Server] Adding service to BLE stack (this may take 10-15 seconds on macOS)...');
      debugPrint('[BLE Server] Service configuration:');
      debugPrint('  - Characteristic A (Request): $requestCharacteristicUuid');
      debugPrint('  - Characteristic B (Queue Status): $queueStatusCharacteristicUuid with CCCD');
      debugPrint('  - Characteristic C (Full Queue): $fullQueueSyncCharacteristicUuid');

      await BlePeripheral.addService(service).timeout(
        const Duration(seconds: 20),
        onTimeout: () {
          throw TimeoutException(
            'Service addition timed out after 20 seconds. '
            'macOS has known limitations with BLE peripheral mode. '
            'Please try testing on iOS or Android devices for full functionality. '
            'See README.md troubleshooting section for details.',
          );
        },
      );
      debugPrint('[BLE Server] Service added successfully');

      // Start advertising with device name
      // Note: Keep name short to fit in BLE advertising packet (31 byte limit)
      debugPrint('[BLE Server] Starting BLE advertising...');
      await BlePeripheral.startAdvertising(
        services: [serviceUuid],
        localName: 'PosterRunner-BO', // Shortened to fit BLE 31-byte limit
      );
      debugPrint('[BLE Server] Advertising started successfully');
    } catch (e) {
      debugPrint('[BLE Server] Failed to start advertising: $e');
      if (e is TimeoutException) {
        debugPrint('[BLE Server] TIMEOUT DETAILS: ${e.message}');
      }
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
    debugPrint('');
    debugPrint('═══════════════════════════════════════════════════════════');
    debugPrint('[BLE Server] 🔔 CONNECTION STATE CHANGE');
    debugPrint('[BLE Server] Device ID: $deviceId');
    debugPrint('[BLE Server] Connected: $connected');
    debugPrint('[BLE Server] Time: ${DateTime.now()}');
    debugPrint('═══════════════════════════════════════════════════════════');
    debugPrint('');

    _isClientConnected = connected;
    onClientConnectionChanged?.call(connected);

    if (connected) {
      debugPrint('[BLE Server] ✅ Client successfully connected!');
      debugPrint('[BLE Server] Ready to receive requests from Front Desk');
    } else {
      debugPrint('[BLE Server] ❌ Client disconnected');
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
    if (characteristicId.toLowerCase() == fullQueueSyncCharacteristicUuid.toLowerCase()) {
      try {
        final jsonString = jsonEncode(_cachedQueue.map((r) => r.toJson()).toList());
        final data = Uint8List.fromList(utf8.encode(jsonString));

        debugPrint('[BLE Server] Full queue sync read - returning ${_cachedQueue.length} items');

        return ReadRequestResult(
          value: data,
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
    if (characteristicId.toLowerCase() == requestCharacteristicUuid.toLowerCase()) {
      // Append incoming data to the buffer for this device
      final currentBuffer = _writeBuffers[deviceId] ?? [];
      _writeBuffers[deviceId] = currentBuffer..addAll(value);

      debugPrint('[BLE Server] Buffered ${value.length} bytes, total buffer size: ${_writeBuffers[deviceId]!.length} bytes');

      // Cancel the existing timer and start a new one
      // Wait 1 second after last write to ensure all fragments are received
      _writeTimers[deviceId]?.cancel();
      _writeTimers[deviceId] = Timer(const Duration(seconds: 1), () {
        _processWriteBuffer(deviceId);
      });

      return WriteRequestResult(
        status: 0, // Success
      );
    }

    // Unknown characteristic
    debugPrint('[BLE Server] Unknown write request for characteristic: $characteristicId');
    return WriteRequestResult(
      status: 1, // Error
    );
  }

  /// Process the write buffer for a device
  void _processWriteBuffer(String deviceId) {
    final bufferedBytes = _writeBuffers.remove(deviceId);
    _writeTimers.remove(deviceId);

    if (bufferedBytes == null) {
      return;
    }

    try {
      final jsonString = utf8.decode(bufferedBytes);
      debugPrint('[BLE Server] Received complete request: $jsonString');

      final json = jsonDecode(jsonString) as Map<String, dynamic>;
      final posterRequest = PosterRequest.fromJsonSynced(json, isSynced: true);

      debugPrint('[BLE Server] Parsed request: ${posterRequest.uniqueId} - ${posterRequest.posterNumber}');

      // Notify callback
      onRequestReceived?.call(posterRequest);
    } catch (e) {
      debugPrint('[BLE Server] Failed to handle write request: $e');
    }
  }

  /// Dispose of resources
  Future<void> dispose() async {
    await stopAdvertising();
    await BlePeripheral.clearServices();
    _writeTimers.forEach((_, timer) => timer.cancel());
  }
}
