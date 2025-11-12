import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'request_entry_screen.dart';
import 'delivered_audit_screen.dart';
import '../../providers/ble_connection_provider.dart';

/// Front Desk Home Screen
/// Provides bottom navigation between Request Entry and Delivered Audit tabs
///
/// Navigation Structure:
/// - Tab 1: Request Entry (active screen for sending poster requests)
/// - Tab 2: Delivered Audit (view fulfilled posters)

class FrontDeskHome extends StatefulWidget {
  const FrontDeskHome({super.key});

  @override
  State<FrontDeskHome> createState() => _FrontDeskHomeState();
}

class _FrontDeskHomeState extends State<FrontDeskHome> {
  int _currentIndex = 0;

  // Screen list
  final List<Widget> _screens = [
    const RequestEntryScreen(),
    const DeliveredAuditScreen(),
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
            title: const Text('Poster Runner - Front Desk'),
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
                icon: Icon(Icons.edit_note, size: 28),
                label: 'Request',
                tooltip: 'New Request Entry',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.check_circle, size: 28),
                label: 'Delivered',
                tooltip: 'Delivered Posters',
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
