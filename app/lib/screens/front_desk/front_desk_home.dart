import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'request_entry_screen.dart';
import 'delivered_audit_screen.dart';
import '../../providers/ble_connection_provider.dart';
import '../../providers/theme_provider.dart';
import '../../providers/front_desk_provider.dart';
import '../../widgets/customize_keypad_dialog.dart';
import '../../theme/app_theme.dart';

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

  /// Show customize keypad dialog
  void _showCustomizeKeypadDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return const CustomizeKeypadDialog();
      },
    );
  }

  /// Show confirmation dialog before clearing all delivered audit entries
  void _showClearAllConfirmation(FrontDeskProvider provider) {
    final count = provider.getDeliveredAuditCount();

    if (count == 0) {
      // No entries to clear
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No delivered posters to clear'),
          duration: Duration(seconds: 2),
        ),
      );
      return;
    }

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Clear All Delivered Posters?'),
          content: Text(
            'This will permanently delete all $count delivered poster(s) from the audit log.\n\nThis action cannot be undone.',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close dialog
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () async {
                Navigator.of(context).pop(); // Close dialog
                await _clearAllDeliveredAudit(provider);
              },
              style: TextButton.styleFrom(
                foregroundColor: Theme.of(context).colorScheme.error,
              ),
              child: const Text('Clear All'),
            ),
          ],
        );
      },
    );
  }

  /// Clear all delivered audit entries using provider
  Future<void> _clearAllDeliveredAudit(FrontDeskProvider provider) async {
    final success = await provider.clearAllDeliveredAudit();

    if (!mounted) return;

    if (success) {
      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('All delivered posters cleared successfully'),
          backgroundColor: Theme.of(context).colorScheme.success,
          duration: const Duration(seconds: 2),
        ),
      );
    } else {
      // Show error message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Error clearing delivered posters'),
          backgroundColor: Theme.of(context).colorScheme.error,
          duration: const Duration(seconds: 3),
        ),
      );
    }
  }

  /// Show theme selection dialog
  void _showThemeDialog(ThemeProvider themeProvider) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Choose Theme'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildThemeOption(
                context,
                themeProvider,
                ThemeMode.light,
                Icons.light_mode,
              ),
              _buildThemeOption(
                context,
                themeProvider,
                ThemeMode.dark,
                Icons.dark_mode,
              ),
              _buildThemeOption(
                context,
                themeProvider,
                ThemeMode.system,
                Icons.settings_suggest,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Close'),
            ),
          ],
        );
      },
    );
  }

  /// Build individual theme option radio button
  Widget _buildThemeOption(
    BuildContext context,
    ThemeProvider themeProvider,
    ThemeMode mode,
    IconData icon,
  ) {
    final isSelected = themeProvider.isThemeModeActive(mode);
    final displayName = themeProvider.getThemeDisplayName(mode);

    return RadioListTile<ThemeMode>(
      title: Row(
        children: [
          Icon(icon, size: 20),
          const SizedBox(width: 8),
          Text(displayName),
        ],
      ),
      value: mode,
      groupValue: themeProvider.themeMode,
      onChanged: (ThemeMode? value) {
        if (value != null) {
          themeProvider.setThemeMode(value);
          Navigator.of(context).pop();
        }
      },
      selected: isSelected,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer3<BleConnectionProvider, FrontDeskProvider, ThemeProvider>(
      builder: (context, bleConnectionProvider, frontDeskProvider, themeProvider, child) {
        final status = bleConnectionProvider.status;
        final statusText = bleConnectionProvider.statusText;

        return Scaffold(
          appBar: AppBar(
            title: const Text('Front Desk'),
            actions: [
              // BLE Status Icon (always shown)
              IconButton(
                icon: Icon(_getBluetoothIcon(status)),
                color: _getBluetoothIconColor(context, status),
                tooltip: 'BLE Status: $statusText',
                onPressed: () {
                  // TODO: Open BLE connection settings/diagnostics
                },
              ),
              // Settings Menu (only shown on Delivered tab)
              if (_currentIndex == 1)
                PopupMenuButton<String>(
                  icon: const Icon(Icons.settings),
                  tooltip: 'Settings',
                  onSelected: (String value) {
                    switch (value) {
                      case 'customize':
                        _showCustomizeKeypadDialog();
                        break;
                      case 'clear':
                        _showClearAllConfirmation(frontDeskProvider);
                        break;
                      case 'theme':
                        _showThemeDialog(themeProvider);
                        break;
                    }
                  },
                  itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
                    const PopupMenuItem<String>(
                      value: 'customize',
                      child: Row(
                        children: [
                          Icon(Icons.keyboard),
                          SizedBox(width: 12),
                          Text('Customize Letter Buttons'),
                        ],
                      ),
                    ),
                    const PopupMenuItem<String>(
                      value: 'clear',
                      child: Row(
                        children: [
                          Icon(Icons.delete_sweep),
                          SizedBox(width: 12),
                          Text('Clear All Delivered'),
                        ],
                      ),
                    ),
                    const PopupMenuItem<String>(
                      value: 'theme',
                      child: Row(
                        children: [
                          Icon(Icons.palette),
                          SizedBox(width: 12),
                          Text('Theme'),
                        ],
                      ),
                    ),
                  ],
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
