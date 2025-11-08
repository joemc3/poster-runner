import 'package:flutter/material.dart';
import 'request_entry_screen.dart';
import 'delivered_audit_screen.dart';

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('📢 Poster Runner - Front Desk'),
        actions: [
          // TODO: Add BLE connection status indicator
          IconButton(
            icon: const Icon(Icons.bluetooth),
            onPressed: () {
              // TODO: Open BLE connection settings
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
        selectedItemColor: Theme.of(context).colorScheme.primary,
        unselectedItemColor: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
        showUnselectedLabels: true,
        type: BottomNavigationBarType.fixed,
        elevation: 8,
      ),
    );
  }
}
