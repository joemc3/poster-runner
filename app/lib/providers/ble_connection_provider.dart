import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter_reactive_ble/flutter_reactive_ble.dart';
import '../services/ble_service.dart';
import '../services/sync_service.dart';

/// BLE Connection State
///
/// Represents the current state of the Bluetooth Low Energy connection
/// between Front Desk (client) and Back Office (server).
enum BleConnectionStatus {
  /// Not connected, not attempting to connect
  disconnected,

  /// Actively scanning for available devices
  scanning,

  /// Connection attempt in progress
  connecting,

  /// Successfully connected and ready for data transfer
  connected,

  /// Connection error occurred
  error,
}

/// BLE Connection Provider
///
/// Manages the state of the Bluetooth Low Energy connection between devices.
/// This provider tracks connection status, device information, signal strength,
/// and last sync time.
///
/// Integrates with BleService for low-level BLE operations and SyncService
/// for data synchronization.
///
/// Usage:
/// ```dart
/// final connectionProvider = Provider.of<BleConnectionProvider>(context);
/// if (connectionProvider.isConnected) {
///   // Show connected UI
/// }
/// ```
class BleConnectionProvider extends ChangeNotifier {
  final BleService? _bleService;
  SyncService? _syncService;

  BleConnectionStatus _status = BleConnectionStatus.disconnected;
  String? _connectedDeviceName;
  String? _connectedDeviceId;
  int? _signalStrength; // RSSI value in dBm
  DateTime? _lastSyncTime;
  String? _errorMessage;

  // Scan subscription
  StreamSubscription<DiscoveredDevice>? _scanSubscription;
  List<DiscoveredDevice> _discoveredDevices = [];

  BleConnectionProvider({BleService? bleService}) : _bleService = bleService {
    if (_bleService != null) {
      // Set up connection state change callback
      _bleService.onConnectionStateChanged = handleConnectionStateChange;
    }
  }

  /// Set sync service (called after provider initialization)
  void setSyncService(SyncService syncService) {
    _syncService = syncService;
  }

  // Getters
  BleConnectionStatus get status => _status;
  String? get connectedDeviceName => _connectedDeviceName;
  String? get connectedDeviceId => _connectedDeviceId;
  int? get signalStrength => _signalStrength;
  DateTime? get lastSyncTime => _lastSyncTime;
  String? get errorMessage => _errorMessage;
  List<DiscoveredDevice> get discoveredDevices => List.unmodifiable(_discoveredDevices);

  // Convenience getters
  bool get isConnected => _status == BleConnectionStatus.connected;
  bool get isDisconnected => _status == BleConnectionStatus.disconnected;
  bool get isScanning => _status == BleConnectionStatus.scanning;
  bool get isConnecting => _status == BleConnectionStatus.connecting;
  bool get hasError => _status == BleConnectionStatus.error;

  /// Get connection status display text
  String get statusText {
    switch (_status) {
      case BleConnectionStatus.disconnected:
        return 'Disconnected';
      case BleConnectionStatus.scanning:
        return 'Scanning...';
      case BleConnectionStatus.connecting:
        return 'Connecting...';
      case BleConnectionStatus.connected:
        return 'Connected';
      case BleConnectionStatus.error:
        return 'Error';
    }
  }

  /// Start scanning for BLE devices (Front Desk only)
  Future<void> startScanning() async {
    if (_bleService == null) {
      setError('BLE service not initialized');
      return;
    }

    if (_bleService.role != DeviceRole.frontDesk) {
      setError('Only Front Desk can scan for devices');
      return;
    }

    _status = BleConnectionStatus.scanning;
    _errorMessage = null;
    _discoveredDevices.clear();
    notifyListeners();

    debugPrint('[BLE Connection Provider] Starting scan');

    try {
      await _scanSubscription?.cancel();
      _scanSubscription = _bleService.startScanning().listen(
        (device) {
          debugPrint('[BLE Connection Provider] Discovered: ${device.name} (${device.id})');

          // Add or update device in list
          final index = _discoveredDevices.indexWhere((d) => d.id == device.id);
          if (index >= 0) {
            _discoveredDevices[index] = device;
          } else {
            _discoveredDevices.add(device);
          }
          notifyListeners();
        },
        onError: (error) {
          debugPrint('[BLE Connection Provider] Scan error: $error');
          setError('Scan error: $error');
        },
      );
    } catch (e) {
      debugPrint('[BLE Connection Provider] Failed to start scanning: $e');
      setError('Failed to start scanning: $e');
    }
  }

  /// Stop scanning for BLE devices
  Future<void> stopScanning() async {
    if (_bleService == null) return;

    debugPrint('[BLE Connection Provider] Stopping scan');

    await _scanSubscription?.cancel();
    _scanSubscription = null;

    if (_status == BleConnectionStatus.scanning) {
      _status = BleConnectionStatus.disconnected;
      notifyListeners();
    }

    await _bleService.stopScanning();
  }

  /// Connect to a specific BLE device (Front Desk only)
  Future<void> connect(String deviceId, String deviceName) async {
    if (_bleService == null) {
      setError('BLE service not initialized');
      return;
    }

    if (_bleService.role != DeviceRole.frontDesk) {
      setError('Only Front Desk can connect to devices');
      return;
    }

    debugPrint('[BLE Connection Provider] Connecting to $deviceName ($deviceId)');

    _status = BleConnectionStatus.connecting;
    _errorMessage = null;
    _connectedDeviceId = deviceId;
    _connectedDeviceName = deviceName;
    notifyListeners();

    try {
      // Stop scanning
      await stopScanning();

      // Initiate connection
      await _bleService.connect(deviceId);

      // Connection state changes will be handled by handleConnectionStateChange callback
    } catch (e) {
      debugPrint('[BLE Connection Provider] Connection failed: $e');
      setError('Connection failed: $e');
    }
  }

  /// Disconnect from current BLE device
  Future<void> disconnect() async {
    if (_bleService == null) return;

    debugPrint('[BLE Connection Provider] Disconnecting');

    await _bleService.disconnect();

    _status = BleConnectionStatus.disconnected;
    _connectedDeviceName = null;
    _connectedDeviceId = null;
    _signalStrength = null;
    _errorMessage = null;
    notifyListeners();
  }

  /// Handle connection state changes from BLE service
  ///
  /// This is called by BLE services when connection state changes
  /// (e.g., connecting, connected, disconnected)
  void handleConnectionStateChange(ConnectionStateUpdate update) {
    debugPrint('[BLE Connection Provider] Connection state: ${update.connectionState}');

    switch (update.connectionState) {
      case DeviceConnectionState.connecting:
        _status = BleConnectionStatus.connecting;
        break;

      case DeviceConnectionState.connected:
        _status = BleConnectionStatus.connected;
        debugPrint('[BLE Connection Provider] Connected successfully');

        // Execute three-step reconnection handshake
        if (_syncService != null) {
          _syncService!.executeReconnectionHandshake().then((success) {
            if (success) {
              debugPrint('[BLE Connection Provider] Sync handshake completed');
              updateLastSyncTime();
            } else {
              setError('Sync handshake failed');
            }
          });
        }
        break;

      case DeviceConnectionState.disconnecting:
        _status = BleConnectionStatus.disconnected;
        break;

      case DeviceConnectionState.disconnected:
        _status = BleConnectionStatus.disconnected;
        _connectedDeviceId = null;
        debugPrint('[BLE Connection Provider] Disconnected');

        // Show warning banner if this was unexpected
        if (_errorMessage == null) {
          _errorMessage = 'Connection lost';
        }
        break;
    }

    notifyListeners();
  }

  /// Update signal strength (RSSI)
  ///
  /// Called by BLE service when signal strength changes
  void updateSignalStrength(int rssi) {
    _signalStrength = rssi;
    notifyListeners();
  }

  /// Update last sync time
  ///
  /// Called after successful data synchronization
  void updateLastSyncTime() {
    _lastSyncTime = DateTime.now();
    notifyListeners();
  }

  /// Handle connection error
  ///
  /// Phase 4 TODO: Wire up to actual BLE error handling
  void setError(String message) {
    _status = BleConnectionStatus.error;
    _errorMessage = message;
    notifyListeners();
  }

  /// Clear error state
  void clearError() {
    if (_status == BleConnectionStatus.error) {
      _status = BleConnectionStatus.disconnected;
      _errorMessage = null;
      notifyListeners();
    }
  }

  /// Set status to connected (used by Back Office when advertising starts)
  void setConnectedStatus() {
    _status = BleConnectionStatus.connected;
    _errorMessage = null;
    notifyListeners();
  }

  /// Attempt to reconnect after disconnection
  Future<void> reconnect() async {
    if (_connectedDeviceId != null && _connectedDeviceName != null) {
      debugPrint('[BLE Connection Provider] Attempting reconnect');
      await connect(_connectedDeviceId!, _connectedDeviceName!);
    }
  }

  /// Start advertising as Back Office (GATT Server)
  Future<void> startAdvertising() async {
    if (_bleService == null) {
      setError('BLE service not initialized');
      return;
    }

    if (_bleService.role != DeviceRole.backOffice) {
      setError('Only Back Office can advertise');
      return;
    }

    debugPrint('[BLE Connection Provider] Starting advertising');

    try {
      await _bleService.startAdvertising();
      _status = BleConnectionStatus.connected; // Server is ready
      notifyListeners();
    } catch (e) {
      debugPrint('[BLE Connection Provider] Advertising failed: $e');
      setError('Advertising failed: $e');
    }
  }

  /// Stop advertising as Back Office
  Future<void> stopAdvertising() async {
    if (_bleService == null) return;

    debugPrint('[BLE Connection Provider] Stopping advertising');

    try {
      await _bleService.stopAdvertising();
      _status = BleConnectionStatus.disconnected;
      notifyListeners();
    } catch (e) {
      debugPrint('[BLE Connection Provider] Stop advertising failed: $e');
    }
  }

  @override
  void dispose() {
    _scanSubscription?.cancel();
    _bleService?.dispose();
    super.dispose();
  }
}
