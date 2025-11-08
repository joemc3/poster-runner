import 'package:flutter/material.dart';
import 'theme/app_theme.dart';
import 'screens/role_selection_screen.dart';

void main() {
  runApp(const PosterRunnerApp());
}

/// Poster Runner Application
///
/// A cross-platform mobile/tablet application for managing poster pull requests
/// in event and trade show environments using Bluetooth Low Energy (BLE).
///
/// Features:
/// - Front Desk role: Submit poster requests and view delivery status
/// - Back Office role: Process requests in chronological order
/// - Offline-first architecture with BLE synchronization
/// - Light and dark theme support
///
/// TODO: Integrate BLE service layer for actual request communication
/// TODO: Implement data persistence layer
/// TODO: Add error handling and retry logic
/// TODO: Implement state management solution (Provider, Riverpod, or BLoC)

class PosterRunnerApp extends StatelessWidget {
  const PosterRunnerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Poster Runner',
      debugShowCheckedModeBanner: false,

      // Theme configuration based on project-theme.md
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.system, // Respect system preference

      // Start with role selection screen
      home: const RoleSelectionScreen(),
    );
  }
}
