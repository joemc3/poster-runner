import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'theme/app_theme.dart';
import 'screens/role_selection_screen.dart';
import 'services/persistence_service.dart';

/// Global instance of the persistence service
///
/// This is accessible throughout the app for storing and retrieving
/// fulfilled poster requests.
late PersistenceService persistenceService;

void main() async {
  // Ensure Flutter is initialized
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Hive
  await Hive.initFlutter();

  // Initialize persistence service
  persistenceService = PersistenceService();
  await persistenceService.initialize();

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
