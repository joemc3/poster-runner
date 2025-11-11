import 'package:flutter/foundation.dart';
import 'package:provider/provider.dart';
import 'ble_service.dart';
import 'ble_server_service.dart';
import 'sync_service.dart';
import 'permission_service.dart';
import '../providers/ble_connection_provider.dart';
import '../providers/front_desk_provider.dart';
import '../providers/back_office_provider.dart';
import 'persistence_service.dart';

/// BLE Initializer
///
/// Helper service to initialize BLE services based on device role.
/// This is called when the user selects their role (Front Desk or Back Office).
///
/// Front Desk Role:
/// - Creates BleService (GATT Client)
/// - Creates SyncService with FrontDeskProvider
/// - Injects into BleConnectionProvider and FrontDeskProvider
///
/// Back Office Role:
/// - Creates BleServerService (GATT Server)
/// - Creates SyncService with BackOfficeProvider
/// - Injects into BleConnectionProvider and BackOfficeProvider
///
/// Usage:
/// ```dart
/// await BleInitializer.initializeForFrontDesk(context);
/// // or
/// await BleInitializer.initializeForBackOffice(context);
/// ```
class BleInitializer {
  /// Initialize BLE services for Front Desk role
  ///
  /// Creates GATT Client services and wires up FrontDeskProvider
  static Future<void> initializeForFrontDesk(dynamic context) async {
    debugPrint('[BLE Initializer] Initializing for Front Desk');

    try {
      // Request Bluetooth permissions first (Android 12+, iOS)
      final permissionService = PermissionService();
      final permissionsGranted = await permissionService.requestBluetoothPermissions();

      if (!permissionsGranted) {
        throw Exception(
          'Bluetooth permissions not granted. '
          'Please enable Bluetooth permissions in system settings.',
        );
      }

      // Get providers
      final bleConnectionProvider =
          Provider.of<BleConnectionProvider>(context, listen: false);
      final frontDeskProvider =
          Provider.of<FrontDeskProvider>(context, listen: false);
      final persistenceService =
          Provider.of<PersistenceService>(context, listen: false);

      // Create BLE service (GATT Client)
      final bleService = BleService(role: DeviceRole.frontDesk);

      // Create sync service
      final syncService = SyncService(
        bleService: bleService,
        connectionProvider: bleConnectionProvider,
        persistenceService: persistenceService,
        frontDeskProvider: frontDeskProvider,
      );

      // Set up BLE service callbacks
      bleService.onStatusUpdateReceived = syncService.handleIncomingStatusUpdate;

      // Wire up providers
      bleConnectionProvider.setSyncService(syncService);
      frontDeskProvider.setSyncService(syncService);

      // Start scanning for Back Office
      debugPrint('[BLE Initializer] Starting BLE scan for Back Office...');
      syncService.startScan();

      debugPrint('[BLE Initializer] Front Desk initialization complete');
    } catch (e) {
      debugPrint('[BLE Initializer] Failed to initialize Front Desk: $e');
      rethrow;
    }
  }

  /// Initialize BLE services for Back Office role
  ///
  /// Creates GATT Server services and wires up BackOfficeProvider
  static Future<void> initializeForBackOffice(dynamic context) async {
    debugPrint('[BLE Initializer] Initializing for Back Office');

    try {
      // Request Bluetooth permissions first (Android 12+, iOS)
      final permissionService = PermissionService();
      final permissionsGranted = await permissionService.requestBluetoothPermissions();

      if (!permissionsGranted) {
        throw Exception(
          'Bluetooth permissions not granted. '
          'Please enable Bluetooth permissions in system settings.',
        );
      }

      // Get providers
      final bleConnectionProvider =
          Provider.of<BleConnectionProvider>(context, listen: false);
      final backOfficeProvider =
          Provider.of<BackOfficeProvider>(context, listen: false);
      final persistenceService =
          Provider.of<PersistenceService>(context, listen: false);

      // Create BLE server service (GATT Server)
      final bleServerService = BleServerService();
      await bleServerService.initialize();

      // Create sync service
      final syncService = SyncService(
        bleServerService: bleServerService,
        connectionProvider: bleConnectionProvider,
        persistenceService: persistenceService,
        backOfficeProvider: backOfficeProvider,
      );

      // Set up BLE server callbacks
      bleServerService.onRequestReceived = syncService.handleIncomingRequest;
      backOfficeProvider.onQueueChanged = (queue) {
        bleServerService.fullQueueProvider = queue;
      };

      // Wire up providers
      bleConnectionProvider.setSyncService(syncService);
      backOfficeProvider.setSyncService(syncService);

      // Start advertising
      await bleServerService.startAdvertising();
      debugPrint('[BLE Initializer] Back Office advertising started');

      debugPrint('[BLE Initializer] Back Office initialization complete');
    } catch (e) {
      debugPrint('[BLE Initializer] Failed to initialize Back Office: $e');
      rethrow;
    }
  }
}
