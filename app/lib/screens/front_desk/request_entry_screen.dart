import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../models/poster_request.dart';
import '../../theme/app_theme.dart';

/// Front Desk - Request Entry Screen (Tab 1)
///
/// Purpose: Fast poster number entry and submission
///
/// Key Features:
/// - Large input field for poster number entry
/// - Large, accessible submit button (56dp height)
/// - Status feedback area showing last submission result
/// - Auto-clear input on successful submission
///
/// TODO: Connect to BLE service for actual request submission
/// TODO: Implement actual status tracking and error handling

class RequestEntryScreen extends StatefulWidget {
  /// Callback when a new request is submitted
  /// TODO: Replace with actual BLE service call
  final Function(String posterNumber)? onSubmitRequest;

  const RequestEntryScreen({
    this.onSubmitRequest,
    super.key,
  });

  @override
  State<RequestEntryScreen> createState() => _RequestEntryScreenState();
}

class _RequestEntryScreenState extends State<RequestEntryScreen> {
  final TextEditingController _posterNumberController = TextEditingController();

  // TODO: Replace with actual state management
  String? _lastSubmittedPoster;
  RequestStatus? _lastStatus;
  DateTime? _lastSubmissionTime;
  bool _isSubmitting = false;

  @override
  void dispose() {
    _posterNumberController.dispose();
    super.dispose();
  }

  /// Handle submit button press
  /// TODO: Integrate with actual BLE service
  Future<void> _handleSubmit() async {
    final posterNumber = _posterNumberController.text.trim().toUpperCase();

    if (posterNumber.isEmpty) {
      _showError('Please enter a poster number');
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    // TODO: Replace with actual BLE transmission
    // Simulate submission delay
    await Future.delayed(const Duration(milliseconds: 300));

    // TODO: Replace with actual status from BLE service
    // For now, simulate success
    setState(() {
      _lastSubmittedPoster = posterNumber;
      _lastStatus = RequestStatus.sent;
      _lastSubmissionTime = DateTime.now();
      _isSubmitting = false;
      _posterNumberController.clear();
    });

    // Call callback if provided
    widget.onSubmitRequest?.call(posterNumber);
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

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5), // Light gray background
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Section header
              Text(
                '📝 NEW REQUEST',
                style: textTheme.headlineSmall,
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
                        autofocus: true,
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

              // Submit button
              ElevatedButton(
                onPressed: _isSubmitting ? null : _handleSubmit,
                child: _isSubmitting
                    ? const SizedBox(
                        height: 24,
                        width: 24,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      )
                    : Text(
                        'SUBMIT',
                        style: textTheme.labelLarge?.copyWith(
                          fontSize: 18,
                        ),
                      ),
              ),
              const SizedBox(height: 32),

              // Status feedback area
              if (_lastStatus != null && _lastSubmittedPoster != null)
                _buildStatusFeedback(colorScheme, textTheme),

              const Spacer(),
            ],
          ),
        ),
      ),
    );
  }

  /// Build status feedback widget
  Widget _buildStatusFeedback(ColorScheme colorScheme, TextTheme textTheme) {
    final Color statusColor = _lastStatus == RequestStatus.sent
        ? colorScheme.success
        : colorScheme.error;

    final String statusIcon = _lastStatus == RequestStatus.sent ? '🟢' : '🔴';
    final String statusText = _lastStatus == RequestStatus.sent ? 'SENT' : 'FAILED';

    final timeFormat = DateFormat('h:mm a');
    final displayTime = timeFormat.format(_lastSubmissionTime!);

    return Card(
      color: statusColor.withValues(alpha: 0.1),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(statusIcon, style: const TextStyle(fontSize: 20)),
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
                    color: colorScheme.neutral,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              'Last: $_lastSubmittedPoster - Success.',
              style: textTheme.bodyMedium,
            ),
          ],
        ),
      ),
    );
  }
}
