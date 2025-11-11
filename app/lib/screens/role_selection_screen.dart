import 'package:flutter/material.dart';
import 'front_desk/front_desk_home.dart';
import 'back_office/back_office_home.dart';
import '../theme/app_theme.dart';
import '../services/ble_initializer.dart';

/// Role Selection Screen
/// Allows user to choose between Front Desk and Back Office roles
///
/// This is a temporary screen for development and testing.
/// TODO: In production, role might be determined by:
/// - Device assignment (specific devices for specific roles)
/// - User login/authentication
/// - Configuration/settings

class RoleSelectionScreen extends StatefulWidget {
  const RoleSelectionScreen({super.key});

  @override
  State<RoleSelectionScreen> createState() => _RoleSelectionScreenState();
}

class _RoleSelectionScreenState extends State<RoleSelectionScreen> {
  bool _isInitializing = false;
  String? _initializationError;

  /// Initialize BLE services for Front Desk role
  Future<void> _initializeFrontDesk() async {
    setState(() {
      _isInitializing = true;
      _initializationError = null;
    });

    try {
      await BleInitializer.initializeForFrontDesk(context);

      if (!mounted) return;

      // Navigate to Front Desk home
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (context) => const FrontDeskHome(),
        ),
      );
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _initializationError = 'Failed to initialize BLE: $e';
        _isInitializing = false;
      });
    }
  }

  /// Initialize BLE services for Back Office role
  Future<void> _initializeBackOffice() async {
    setState(() {
      _isInitializing = true;
      _initializationError = null;
    });

    try {
      await BleInitializer.initializeForBackOffice(context);

      if (!mounted) return;

      // Navigate to Back Office home
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (context) => const BackOfficeHome(),
        ),
      );
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _initializationError = 'Failed to initialize BLE: $e';
        _isInitializing = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      backgroundColor: colorScheme.surface, // Pure white (light) / Near black (dark) - per spec
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 40), // Add top padding when scrollable
              // Show loading indicator if initializing
              if (_isInitializing)
                const Column(
                  children: [
                    CircularProgressIndicator(),
                    SizedBox(height: 16),
                    Text('Initializing Bluetooth...'),
                  ],
                ),

              // Show error message if initialization failed
              if (_initializationError != null)
                Padding(
                  padding: const EdgeInsets.only(bottom: 24.0),
                  child: Container(
                    padding: const EdgeInsets.all(16.0),
                    decoration: BoxDecoration(
                      color: colorScheme.error.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: colorScheme.error),
                    ),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            Icon(Icons.error_outline, color: colorScheme.error),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                _initializationError!,
                                style: textTheme.bodyMedium?.copyWith(
                                  color: colorScheme.error,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        TextButton(
                          onPressed: () {
                            setState(() {
                              _initializationError = null;
                            });
                          },
                          child: const Text('Dismiss'),
                        ),
                      ],
                    ),
                  ),
                ),
              // App title and icon
              Icon(
                Icons.receipt_long,
                size: 80,
                color: colorScheme.primary,
              ),
              const SizedBox(height: 24),
              Text(
                'Poster Runner',
                style: textTheme.displaySmall?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: colorScheme.primary,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                'Select Your Role',
                style: textTheme.titleLarge?.copyWith(
                  color: colorScheme.neutral,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 64),

              // Front Desk button
              _RoleCard(
                icon: Icons.edit_note,
                title: 'Front Desk',
                description: 'Submit poster requests and check delivery status',
                color: colorScheme.primary,
                onTap: _isInitializing ? null : _initializeFrontDesk,
              ),
              const SizedBox(height: 24),

              // Back Office button
              _RoleCard(
                icon: Icons.playlist_play,
                title: 'Back Office',
                description: 'Process poster requests and manage fulfillment queue',
                color: colorScheme.secondary,
                onTap: _isInitializing ? null : _initializeBackOffice,
              ),
              const SizedBox(height: 40), // Add bottom padding when scrollable
            ],
          ),
        ),
        ),
      ),
    );
  }
}

/// Role Card Widget
/// Displays a selectable card for each role option
class _RoleCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;
  final Color color;
  final VoidCallback? onTap;

  const _RoleCard({
    required this.icon,
    required this.title,
    required this.description,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Card(
      elevation: 2,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Row(
            children: [
              // Icon
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  icon,
                  size: 36,
                  color: color,
                ),
              ),
              const SizedBox(width: 20),
              // Text content
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: textTheme.headlineSmall?.copyWith(
                        color: color,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      description,
                      style: textTheme.bodyMedium?.copyWith(
                        color: Theme.of(context).colorScheme.neutral,
                      ),
                    ),
                  ],
                ),
              ),
              // Arrow icon
              Icon(
                Icons.arrow_forward_ios,
                color: color,
                size: 20,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
