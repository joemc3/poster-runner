import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'live_queue_screen.dart';
import 'fulfilled_log_screen.dart';
import '../../providers/ble_connection_provider.dart';
import '../../theme/app_theme.dart';

/// Back Office Home Screen
/// Provides bottom navigation between Live Queue and Fulfilled Log tabs
///
/// Navigation Structure:
/// - Tab 1: Live Queue (active screen for processing pending requests)
/// - Tab 2: Fulfilled Log (view completed requests)

class BackOfficeHome extends StatefulWidget {
  const BackOfficeHome({super.key});

  @override
  State<BackOfficeHome> createState() => _BackOfficeHomeState();
}

class _BackOfficeHomeState extends State<BackOfficeHome> {
  int _currentIndex = 0;

  // Screen list
  final List<Widget> _screens = [
    const LiveQueueScreen(),
    const FulfilledLogScreen(),
  ];

  void _onTabTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  /// Get Bluetooth icon based on connection status
  IconData _getBluetoothIcon(BleConnectionStatus status) {
    switch (status) {
      case BleConnectionStatus.disconnected:
        return Icons.bluetooth_disabled;
      case BleConnectionStatus.scanning:
        return Icons.bluetooth_searching;
      case BleConnectionStatus.connecting:
        return Icons.bluetooth_searching;
      case BleConnectionStatus.connected:
        return Icons.bluetooth_connected;
      case BleConnectionStatus.error:
        return Icons.bluetooth_disabled;
    }
  }

  /// Get color for Bluetooth icon based on connection status
  Color _getBluetoothIconColor(BuildContext context, BleConnectionStatus status) {
    final colorScheme = Theme.of(context).colorScheme;
    switch (status) {
      case BleConnectionStatus.disconnected:
        return colorScheme.neutral;
      case BleConnectionStatus.scanning:
        return colorScheme.warning;
      case BleConnectionStatus.connecting:
        return colorScheme.warning;
      case BleConnectionStatus.connected:
        return colorScheme.success;
      case BleConnectionStatus.error:
        return colorScheme.error;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<BleConnectionProvider>(
      builder: (context, bleConnectionProvider, child) {
        final status = bleConnectionProvider.status;
        final statusText = bleConnectionProvider.statusText;

        return Scaffold(
          appBar: AppBar(
            title: const Text('Poster Runner - Back Office'),
            actions: [
              IconButton(
                icon: Icon(_getBluetoothIcon(status)),
                color: _getBluetoothIconColor(context, status),
                tooltip: 'BLE Status: $statusText',
                onPressed: () {
                  // TODO: Open BLE connection settings/diagnostics
                },
              ),
            ],
          ),
          body: IndexedStack(
            index: _currentIndex,
            children: _screens,
          ),
          bottomNavigationBar: BottomNavigationBar(
            currentIndex: _currentIndex,
            onTap: _onTabTapped,
            items: const [
              BottomNavigationBarItem(
                icon: Icon(Icons.playlist_play, size: 28),
                label: 'Queue',
                tooltip: 'Active Queue',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.check_circle, size: 28),
                label: 'Delivered',
                tooltip: 'Fulfilled Log',
              ),
            ],
            // Colors are now defined in theme - no need to override
            showUnselectedLabels: true,
            type: BottomNavigationBarType.fixed,
            elevation: 8,
          ),
        );
      },
    );
  }
}
