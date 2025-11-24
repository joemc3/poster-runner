import 'dart:async';
import 'dart:convert';
import 'package:flutter_reactive_ble/flutter_reactive_ble.dart';
import 'package:flutter/foundation.dart';
import '../models/poster_request.dart';

/// BLE Service UUIDs
///
/// Custom UUIDs defined in BLE GATT Architecture Design.md
class BleUuids {
  /// Poster Runner Service UUID
  static final Uuid serviceUuid = Uuid.parse('0000A000-0000-1000-8000-00805F9B34FB');

  /// Request Characteristic (A): Front Desk → Back Office
  /// Write With Response for reliability
  static final Uuid requestCharacteristicUuid =
      Uuid.parse('0000A001-0000-1000-8000-00805F9B34FB');

  /// Queue Status Characteristic (B): Back Office → Front Desk
  /// Indicate (with acknowledgment) for status updates
  static final Uuid queueStatusCharacteristicUuid =
      Uuid.parse('0000A002-0000-1000-8000-00805F9B34FB');

  /// Full Queue Sync Characteristic (C): Back Office ↔ Front Desk
  /// Read operation for full state synchronization
  static final Uuid fullQueueSyncCharacteristicUuid =
      Uuid.parse('0000A003-0000-1000-8000-00805F9B34FB');
}

/// Device Role (determines GATT role)
enum DeviceRole {
  /// Back Office device acts as GATT Server
  backOffice,

  /// Front Desk device acts as GATT Client
  frontDesk,
}

/// BLE Service
///
/// Handles Bluetooth Low Energy communication between Front Desk (GATT Client)
/// and Back Office (GATT Server) devices.
///
/// Architecture:
/// - Back Office: GATT Server (advertises, accepts connections)
/// - Front Desk: GATT Client (scans, initiates connections)
///
/// Three Characteristics:
/// - Request Characteristic (A): Front Desk writes new requests to Back Office
/// - Queue Status Characteristic (B): Back Office indicates status updates to Front Desk
/// - Full Queue Sync Characteristic (C): Front Desk reads full queue from Back Office
///
/// See: docs/specs/BLE GATT Architecture Design.md
class BleService {
  final FlutterReactiveBle _ble;
  final DeviceRole _role;

  // Connection state
  StreamSubscription<ConnectionStateUpdate>? _connectionSubscription;
  StreamSubscription<DiscoveredDevice>? _scanSubscription;
  String? _connectedDeviceId;

  // Server-side streams (Back Office only)
  StreamSubscription<List<int>>? _requestCharacteristicSubscription;

  // Client-side streams (Front Desk only)
  StreamSubscription<List<int>>? _queueStatusSubscription;

  // Callbacks for data handling
  Function(PosterRequest)? onRequestReceived; // Back Office receives new request
  Function(Map<String, dynamic>)? onStatusUpdateReceived; // Front Desk receives status update
  Function(ConnectionStateUpdate)? onConnectionStateChanged;

  BleService({required DeviceRole role})
      : _ble = FlutterReactiveBle(),
        _role = role;

  /// Current connected device ID
  String? get connectedDeviceId => _connectedDeviceId;

  /// Is device currently connected
  bool get isConnected => _connectedDeviceId != null;

  /// Device role (determines GATT behavior)
  DeviceRole get role => _role;

  // ============================================================================
  // BACK OFFICE (GATT SERVER) METHODS
  // ============================================================================

  /// Start advertising as Back Office (GATT Server)
  ///
  /// Note: flutter_reactive_ble does NOT support peripheral mode (advertising)
  /// on most platforms. This is a known limitation.
  ///
  /// Alternative approaches:
  /// 1. Use platform-specific code (CoreBluetooth on iOS, Android BLE API)
  /// 2. Use a different package that supports peripheral mode
  /// 3. Reverse the roles: Front Desk advertises, Back Office scans
  ///
  /// TODO: Implement peripheral mode using platform channels or alternative package
  Future<void> startAdvertising() async {
    if (_role != DeviceRole.backOffice) {
      throw StateError('Only Back Office can advertise');
    }

    // TODO: Implement GATT Server advertising
    // This requires platform-specific implementation as flutter_reactive_ble
    // does not support peripheral mode out of the box.
    //
    // Recommended approach:
    // 1. Create platform channels for iOS (CoreBluetooth CBPeripheralManager)
    // 2. Create platform channels for Android (BluetoothLeAdvertiser)
    // 3. Implement characteristic read/write handlers
    debugPrint('[BLE Service] Back Office advertising not yet implemented');
    throw UnimplementedError(
        'GATT Server mode requires platform-specific implementation');
  }

  /// Stop advertising
  Future<void> stopAdvertising() async {
    if (_role != DeviceRole.backOffice) {
      throw StateError('Only Back Office can stop advertising');
    }

    // TODO: Implement stop advertising
    debugPrint('[BLE Service] Stop advertising not yet implemented');
  }

  /// Send status update to connected Front Desk client
  ///
  /// Uses Queue Status Characteristic (B) with Indicate property
  ///
  /// Payload: {uniqueId, status, timestampPulled}
  Future<void> sendStatusUpdate(PosterRequest request) async {
    if (_role != DeviceRole.backOffice) {
      throw StateError('Only Back Office can send status updates');
    }

    if (_connectedDeviceId == null) {
      throw StateError('No device connected');
    }

    // TODO: Implement Indicate operation on Queue Status Characteristic (B)
    // This requires GATT Server implementation
    final payload = request.toQueueStatusJson();
    final jsonString = jsonEncode(payload);
    debugPrint('[BLE Service] Would send status update: $jsonString');
    throw UnimplementedError('GATT Server Indicate not yet implemented');
  }

  /// Provide full queue data for sync
  ///
  /// Used when Front Desk reads Full Queue Sync Characteristic (C)
  ///
  /// Returns: List of all PosterRequest objects
  Future<List<int>> provideFullQueueSync(List<PosterRequest> allRequests) async {
    if (_role != DeviceRole.backOffice) {
      throw StateError('Only Back Office can provide full queue sync');
    }

    // Convert all requests to JSON array
    final jsonArray = allRequests.map((r) => r.toJson()).toList();
    final jsonString = jsonEncode(jsonArray);
    final bytes = utf8.encode(jsonString);

    debugPrint(
        '[BLE Service] Providing full queue sync: ${allRequests.length} requests, ${bytes.length} bytes');

    return bytes;
  }

  // ============================================================================
  // FRONT DESK (GATT CLIENT) METHODS
  // ============================================================================

  /// Start scanning for Back Office devices
  ///
  /// Front Desk scans for devices advertising the Poster Runner Service
  Stream<DiscoveredDevice> startScanning() {
    if (_role != DeviceRole.frontDesk) {
      throw StateError('Only Front Desk can scan for devices');
    }

    debugPrint('[BLE Service] Starting scan for Poster Runner Service');
    debugPrint('[BLE Service] DIAGNOSTIC MODE: Scanning for ALL devices (no filter)');

    // TEMPORARY DIAGNOSTIC: Scan for ALL devices (no filter) to see what's discoverable
    return _ble.scanForDevices(
      withServices: [], // DIAGNOSTIC: Empty list = no filter
      scanMode: ScanMode.lowLatency,
    ).map((device) {
      // Log every discovered device for diagnostics
      debugPrint('');
      debugPrint('🔍 [BLE Service] Discovered device:');
      debugPrint('   ID: ${device.id}');
      debugPrint('   Name: "${device.name}"');
      debugPrint('   RSSI: ${device.rssi} dBm');
      debugPrint('   Service UUIDs: ${device.serviceUuids}');
      debugPrint('   Manufacturer Data: ${device.manufacturerData}');

      if (device.name.toLowerCase().contains('poster') || device.name.toLowerCase().contains('runner')) {
        debugPrint('   ⚠️  POSSIBLE MATCH - Name contains "poster" or "runner"');
      }
      if (device.serviceUuids.contains(BleUuids.serviceUuid)) {
        debugPrint('   ✅ HAS OUR SERVICE UUID!');
      }

      return device;
    });
  }

  /// Stop scanning for devices
  Future<void> stopScanning() async {
    if (_role != DeviceRole.frontDesk) {
      throw StateError('Only Front Desk can stop scanning');
    }

    await _scanSubscription?.cancel();
    _scanSubscription = null;
    debugPrint('[BLE Service] Stopped scanning');
  }

  /// Connect to Back Office device
  ///
  /// Front Desk connects to a discovered Back Office device
  Future<void> connect(String deviceId) async {
    if (_role != DeviceRole.frontDesk) {
      throw StateError('Only Front Desk can connect to devices');
    }

    debugPrint('[BLE Service] Connecting to device: $deviceId');

    // Cancel any existing connection
    await disconnect();

    // Establish connection
    _connectionSubscription = _ble.connectToDevice(
      id: deviceId,
      connectionTimeout: const Duration(seconds: 10),
    ).listen(
      (connectionState) {
        debugPrint(
            '[BLE Service] Connection state: ${connectionState.connectionState}');

        if (connectionState.connectionState == DeviceConnectionState.connected) {
          _connectedDeviceId = deviceId;
          // Request larger MTU for larger payloads
          _requestMtu(deviceId);
          // Discover services before subscribing to characteristics
          _discoverServicesAndSubscribe(deviceId);
        } else if (connectionState.connectionState ==
            DeviceConnectionState.disconnected) {
          _handleDisconnection();
        }

        // Notify callback
        onConnectionStateChanged?.call(connectionState);
      },
      onError: (error) {
        debugPrint('[BLE Service] Connection error: $error');
        _handleDisconnection();
      },
    );
  }

  /// Request larger MTU (Maximum Transmission Unit)
  ///
  /// Default BLE MTU is 23 bytes (20 bytes payload), which is too small for our JSON payloads.
  /// Request 512 bytes to send larger messages without fragmentation.
  Future<void> _requestMtu(String deviceId) async {
    try {
      debugPrint('[BLE Service] Requesting MTU of 512 bytes...');
      final mtu = await _ble.requestMtu(deviceId: deviceId, mtu: 512);
      debugPrint('[BLE Service] MTU negotiated: $mtu bytes (payload: ${mtu - 3} bytes)');
    } catch (e) {
      debugPrint('[BLE Service] MTU request failed: $e (will use default 20 byte chunks)');
    }
  }

  /// Discover services and then subscribe to characteristics
  ///
  /// This must be called after connection is established
  Future<void> _discoverServicesAndSubscribe(String deviceId) async {
    try {
      debugPrint('[BLE Service] Discovering services...');

      // Wait longer for service discovery to complete
      // The Android logs show service discovery takes time:
      // 1. discoverServices() is called
      // 2. onSearchComplete() is called when done
      // 3. onServiceChanged() is called after that
      await Future.delayed(const Duration(seconds: 2));

      debugPrint('[BLE Service] Service discovery complete, subscribing to characteristics...');
      await _subscribeToQueueStatusCharacteristic(deviceId);
    } catch (e) {
      debugPrint('[BLE Service] Service discovery error: $e');
      // Retry once after another delay
      debugPrint('[BLE Service] Retrying subscription after 1 second...');
      await Future.delayed(const Duration(seconds: 1));
      try {
        await _subscribeToQueueStatusCharacteristic(deviceId);
      } catch (retryError) {
        debugPrint('[BLE Service] Retry failed: $retryError');
      }
    }
  }

  /// Subscribe to Queue Status Characteristic (B)
  ///
  /// Front Desk subscribes to receive status updates from Back Office
  Future<void> _subscribeToQueueStatusCharacteristic(String deviceId) async {
    debugPrint('[BLE Service] Subscribing to Queue Status Characteristic');

    final characteristic = QualifiedCharacteristic(
      serviceId: BleUuids.serviceUuid,
      characteristicId: BleUuids.queueStatusCharacteristicUuid,
      deviceId: deviceId,
    );

    _queueStatusSubscription = _ble.subscribeToCharacteristic(characteristic).listen(
      (data) {
        debugPrint('[BLE Service] Received status update: ${data.length} bytes');
        _handleQueueStatusUpdate(data);
      },
      onError: (error) {
        debugPrint('[BLE Service] Queue status subscription error: $error');
      },
    );
  }

  /// Handle incoming queue status update from Back Office
  void _handleQueueStatusUpdate(List<int> data) {
    try {
      final jsonString = utf8.decode(data);
      final payload = jsonDecode(jsonString) as Map<String, dynamic>;

      debugPrint('[BLE Service] Parsed status update: $payload');

      // Notify callback
      onStatusUpdateReceived?.call(payload);
    } catch (e) {
      debugPrint('[BLE Service] Failed to parse status update: $e');
    }
  }

  /// Write new request to Back Office
  ///
  /// Uses Request Characteristic (A) with Write With Response for reliability
  ///
  /// Payload: {uniqueId, posterNumber, timestampSent}
  Future<void> writeRequest(PosterRequest request) async {
    if (_role != DeviceRole.frontDesk) {
      throw StateError('Only Front Desk can write requests');
    }

    if (_connectedDeviceId == null) {
      throw StateError('No device connected');
    }

    debugPrint('[BLE Service] Writing request: ${request.uniqueId}');

    final characteristic = QualifiedCharacteristic(
      serviceId: BleUuids.serviceUuid,
      characteristicId: BleUuids.requestCharacteristicUuid,
      deviceId: _connectedDeviceId!,
    );

    final payload = request.toRequestCharacteristicJson();
    final jsonString = jsonEncode(payload);
    final bytes = utf8.encode(jsonString);

    debugPrint('[BLE Service] Request payload: $jsonString (${bytes.length} bytes)');

    try {
      await _ble.writeCharacteristicWithoutResponse(characteristic, value: bytes);
      debugPrint('[BLE Service] Request written successfully');
    } catch (e) {
      debugPrint('[BLE Service] Failed to write request: $e');
      rethrow;
    }
  }

  /// Read full queue state from Back Office
  ///
  /// Uses Full Queue Sync Characteristic (C) for reconciliation
  ///
  /// Returns: List of all PosterRequest objects from Back Office
  Future<List<PosterRequest>> readFullQueueSync() async {
    if (_role != DeviceRole.frontDesk) {
      throw StateError('Only Front Desk can read full queue sync');
    }

    if (_connectedDeviceId == null) {
      throw StateError('No device connected');
    }

    debugPrint('[BLE Service] Reading full queue sync');

    final characteristic = QualifiedCharacteristic(
      serviceId: BleUuids.serviceUuid,
      characteristicId: BleUuids.fullQueueSyncCharacteristicUuid,
      deviceId: _connectedDeviceId!,
    );

    try {
      final data = await _ble.readCharacteristic(characteristic);
      final jsonString = utf8.decode(data);
      final jsonArray = jsonDecode(jsonString) as List<dynamic>;

      final requests = jsonArray
          .map((json) => PosterRequest.fromJsonSynced(
                json as Map<String, dynamic>,
                isSynced: true,
              ))
          .toList();

      debugPrint('[BLE Service] Read full queue sync: ${requests.length} requests');

      return requests;
    } catch (e) {
      debugPrint('[BLE Service] Failed to read full queue sync: $e');
      rethrow;
    }
  }

  // ============================================================================
  // CONNECTION MANAGEMENT
  // ============================================================================

  /// Disconnect from current device
  Future<void> disconnect() async {
    debugPrint('[BLE Service] Disconnecting');

    await _connectionSubscription?.cancel();
    await _scanSubscription?.cancel();
    await _requestCharacteristicSubscription?.cancel();
    await _queueStatusSubscription?.cancel();

    _connectionSubscription = null;
    _scanSubscription = null;
    _requestCharacteristicSubscription = null;
    _queueStatusSubscription = null;
    _connectedDeviceId = null;
  }

  /// Handle disconnection event
  void _handleDisconnection() {
    debugPrint('[BLE Service] Handling disconnection');
    _connectedDeviceId = null;
    _requestCharacteristicSubscription?.cancel();
    _queueStatusSubscription?.cancel();
  }

  /// Stream of BLE status changes
  Stream<BleStatus> get statusStream => _ble.statusStream;

  /// Dispose of resources
  void dispose() {
    disconnect();
  }
}
