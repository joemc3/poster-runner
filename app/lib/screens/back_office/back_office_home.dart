import 'package:flutter/material.dart';
import 'live_queue_screen.dart';
import 'fulfilled_log_screen.dart';

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Poster Runner - Back Office'),
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
  }
}
