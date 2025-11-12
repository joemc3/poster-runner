import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../models/poster_request.dart';
import '../../theme/app_theme.dart';
import '../../providers/front_desk_provider.dart';
import '../../widgets/poster_entry_keypad.dart';
import '../../widgets/sync_badge.dart';

/// Front Desk - Request Entry Screen (Tab 1)
///
/// Purpose: Fast poster number entry and submission
///
/// Key Features:
/// - Large input field for poster number entry (becomes read-only during submission)
/// - Custom keypad with ENTER button for submission
/// - Keyboard Enter key also triggers submission
/// - Status feedback area showing last submission result
/// - Auto-clear input on successful submission
///
/// Phase 3 Status: IMPLEMENTED - Uses FrontDeskProvider for state management
/// Phase 5 Status: COMPLETE - Connected to BLE service for transmission to Back Office

class RequestEntryScreen extends StatefulWidget {
  const RequestEntryScreen({super.key});

  @override
  State<RequestEntryScreen> createState() => _RequestEntryScreenState();
}

class _RequestEntryScreenState extends State<RequestEntryScreen> {
  final TextEditingController _posterNumberController = TextEditingController();

  @override
  void dispose() {
    _posterNumberController.dispose();
    super.dispose();
  }

  /// Handle keypad character press
  ///
  /// Appends the character to the text field if not currently submitting.
  void _handleCharacterPressed(String character) {
    final frontDeskProvider = Provider.of<FrontDeskProvider>(context, listen: false);

    // Prevent input during submission
    if (!frontDeskProvider.isSubmitting) {
      _posterNumberController.text += character;
    }
  }

  /// Handle submit button press
  ///
  /// Uses FrontDeskProvider to create and save the request.
  Future<void> _handleSubmit() async {
    final posterNumber = _posterNumberController.text.trim().toUpperCase();

    if (posterNumber.isEmpty) {
      _showError('Please enter a poster number');
      return;
    }

    // Get the provider
    final frontDeskProvider = Provider.of<FrontDeskProvider>(context, listen: false);

    // Submit request via provider
    final success = await frontDeskProvider.submitRequest(posterNumber);

    if (success) {
      // Clear input field
      _posterNumberController.clear();

      // Show success message
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Request saved: $posterNumber'),
            backgroundColor: Theme.of(context).colorScheme.success,
            duration: const Duration(seconds: 2),
          ),
        );
      }
    } else {
      // Show error from provider
      if (mounted) {
        final error = frontDeskProvider.submissionError ?? 'Failed to save request';
        _showError(error);
      }
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Theme.of(context).colorScheme.error,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Consumer<FrontDeskProvider>(
      builder: (context, frontDeskProvider, child) {
        return Scaffold(
          backgroundColor: colorScheme.surface, // Pure white (light) / Near black (dark) - per spec
          body: SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Section header with sync badge
                    Row(
                      children: [
                        Text(
                          'NEW REQUEST',
                          style: textTheme.headlineSmall,
                        ),
                        const SizedBox(width: 12),
                        SyncBadge(
                          count: frontDeskProvider.getUnsyncedCount(),
                          label: 'pending',
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),

                    // Large input field for poster number
                    Card(
                      elevation: 2,
                      child: Padding(
                        padding: const EdgeInsets.all(24.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            TextField(
                              controller: _posterNumberController,
                              readOnly: frontDeskProvider.isSubmitting, // Prevent input during submission
                              textAlign: TextAlign.center,
                              style: textTheme.displaySmall?.copyWith(
                                fontWeight: FontWeight.w600,
                                letterSpacing: 4,
                              ),
                              decoration: InputDecoration(
                                hintText: 'A457',
                                hintStyle: textTheme.displaySmall?.copyWith(
                                  color: colorScheme.neutral.withValues(alpha: 0.3),
                                  letterSpacing: 4,
                                ),
                                border: InputBorder.none,
                                enabledBorder: InputBorder.none,
                                focusedBorder: InputBorder.none,
                              ),
                              textCapitalization: TextCapitalization.characters,
                              onSubmitted: (_) => _handleSubmit(),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Custom keypad
                    PosterEntryKeypad(
                      onCharacterPressed: _handleCharacterPressed,
                      onEnterPressed: _handleSubmit,
                    ),
                    const SizedBox(height: 32),

                    // Status feedback area
                    if (frontDeskProvider.lastSubmissionStatus != null &&
                        frontDeskProvider.lastSubmittedPoster != null)
                      _buildStatusFeedback(
                        colorScheme,
                        textTheme,
                        frontDeskProvider,
                      ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  /// Build status feedback widget
  Widget _buildStatusFeedback(
    ColorScheme colorScheme,
    TextTheme textTheme,
    FrontDeskProvider provider,
  ) {
    final Color statusColor = provider.lastSubmissionStatus == RequestStatus.sent
        ? colorScheme.success
        : colorScheme.error;

    final String statusText =
        provider.lastSubmissionStatus == RequestStatus.sent ? 'SENT' : 'FAILED';

    final timeFormat = DateFormat('h:mm a');
    final displayTime = timeFormat.format(provider.lastSubmissionTime!);

    return Card(
      color: statusColor.withValues(alpha: 0.1),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  provider.lastSubmissionStatus == RequestStatus.sent
                      ? Icons.check_circle
                      : Icons.error,
                  color: statusColor,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  'Status: $statusText',
                  style: textTheme.titleMedium?.copyWith(
                    color: statusColor,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const Spacer(),
                Text(
                  displayTime,
                  style: textTheme.bodySmall?.copyWith(
                    color: colorScheme.onSurface, // True Black (light) / Pure White (dark) for proper contrast on tinted background
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              'Last: ${provider.lastSubmittedPoster} - Success.',
              style: textTheme.bodyMedium?.copyWith(
                color: colorScheme.onSurface, // True Black (light) / Pure White (dark) for proper contrast on tinted background
              ),
            ),
          ],
        ),
      ),
    );
  }
}
