import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:permission_handler/permission_handler.dart';

/// Permission Service
///
/// Handles runtime permission requests for Bluetooth functionality.
/// Required for Android 12+ (API 31+) and iOS.
///
/// Usage:
/// ```dart
/// final permissionService = PermissionService();
/// final granted = await permissionService.requestBluetoothPermissions();
/// ```
class PermissionService {
  /// Request all Bluetooth permissions required for the app
  ///
  /// For Android 12+ (API 31+):
  /// - BLUETOOTH_SCAN (for scanning devices)
  /// - BLUETOOTH_CONNECT (for connecting to devices)
  /// - BLUETOOTH_ADVERTISE (for advertising as peripheral)
  ///
  /// For iOS:
  /// - Bluetooth permission (automatic prompt)
  ///
  /// Returns true if all permissions are granted, false otherwise.
  Future<bool> requestBluetoothPermissions() async {
    debugPrint('[Permission Service] Requesting Bluetooth permissions...');

    try {
      if (Platform.isAndroid) {
        return await _requestAndroidBluetoothPermissions();
      } else if (Platform.isIOS) {
        return await _requestIosBluetoothPermissions();
      } else if (Platform.isMacOS) {
        // macOS doesn't require runtime permission requests
        // Permissions are handled via Info.plist and entitlements
        debugPrint('[Permission Service] macOS - no runtime permissions needed');
        return true;
      } else {
        debugPrint('[Permission Service] Unsupported platform: ${Platform.operatingSystem}');
        return false;
      }
    } catch (e) {
      debugPrint('[Permission Service] Error requesting permissions: $e');
      return false;
    }
  }

  /// Request Android Bluetooth permissions (API 31+)
  Future<bool> _requestAndroidBluetoothPermissions() async {
    debugPrint('[Permission Service] Requesting Android Bluetooth permissions...');

    // Request all required Bluetooth permissions for Android 12+
    final Map<Permission, PermissionStatus> statuses = await [
      Permission.bluetoothScan,
      Permission.bluetoothConnect,
      Permission.bluetoothAdvertise,
    ].request();

    // Check if all permissions are granted
    final allGranted = statuses.values.every((status) => status.isGranted);

    if (allGranted) {
      debugPrint('[Permission Service] All Bluetooth permissions granted');
      return true;
    } else {
      // Log which permissions were denied
      statuses.forEach((permission, status) {
        if (!status.isGranted) {
          debugPrint('[Permission Service] Permission denied: ${permission.toString()} - Status: ${status.toString()}');
        }
      });

      // Check if any permissions are permanently denied
      final anyPermanentlyDenied = statuses.values.any((status) => status.isPermanentlyDenied);
      if (anyPermanentlyDenied) {
        debugPrint('[Permission Service] Some permissions are permanently denied. User must enable them in system settings.');
      }

      return false;
    }
  }

  /// Request iOS Bluetooth permissions
  Future<bool> _requestIosBluetoothPermissions() async {
    debugPrint('[Permission Service] Requesting iOS Bluetooth permissions...');

    final status = await Permission.bluetooth.request();

    if (status.isGranted) {
      debugPrint('[Permission Service] iOS Bluetooth permission granted');
      return true;
    } else {
      debugPrint('[Permission Service] iOS Bluetooth permission denied: ${status.toString()}');
      return false;
    }
  }

  /// Check if Bluetooth permissions are already granted
  ///
  /// Returns true if all required permissions are granted, false otherwise.
  Future<bool> checkBluetoothPermissions() async {
    try {
      if (Platform.isAndroid) {
        final statuses = await [
          Permission.bluetoothScan,
          Permission.bluetoothConnect,
          Permission.bluetoothAdvertise,
        ].request();

        return statuses.values.every((status) => status.isGranted);
      } else if (Platform.isIOS) {
        final status = await Permission.bluetooth.status;
        return status.isGranted;
      } else if (Platform.isMacOS) {
        return true; // macOS doesn't require runtime checks
      } else {
        return false;
      }
    } catch (e) {
      debugPrint('[Permission Service] Error checking permissions: $e');
      return false;
    }
  }

  /// Open app settings so user can manually grant permissions
  ///
  /// Useful when permissions are permanently denied.
  Future<bool> openSettings() async {
    debugPrint('[Permission Service] Opening app settings...');
    return await openAppSettings();
  }
}
