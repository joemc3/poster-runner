import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../models/poster_request.dart';
import '../../theme/app_theme.dart';
import '../../providers/back_office_provider.dart';
import '../../widgets/sync_badge.dart';

/// Back Office - Live Request Queue Screen (Tab 1)
///
/// Purpose: Real-time chronological monitoring and immediate fulfillment of requests
///
/// Key Features:
/// - Chronologically ordered list (oldest first)
/// - Large, accessible "PULL" buttons for each item
/// - Clear visual hierarchy for next task
/// - Shows pending count in header
///
/// Phase 3 Status: IMPLEMENTED - Uses BackOfficeProvider for state management
/// Phase 4 TODO: Connect to BLE service for real-time request sync

class LiveQueueScreen extends StatelessWidget {
  const LiveQueueScreen({super.key});

  /// Handle pull button press
  ///
  /// Uses BackOfficeProvider to fulfill the request and update state.
  Future<void> _handlePull(BuildContext context, PosterRequest request) async {
    final backOfficeProvider = Provider.of<BackOfficeProvider>(context, listen: false);

    final success = await backOfficeProvider.fulfillRequest(request);

    if (!context.mounted) return;

    if (success) {
      // Show confirmation
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${request.posterNumber} marked as pulled'),
          backgroundColor: Theme.of(context).colorScheme.success,
          duration: const Duration(seconds: 2),
        ),
      );
    } else {
      // Show error message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Error fulfilling request'),
          backgroundColor: Theme.of(context).colorScheme.error,
          duration: const Duration(seconds: 3),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Consumer<BackOfficeProvider>(
      builder: (context, backOfficeProvider, child) {
        final activeQueue = backOfficeProvider.activeQueue;

        return Scaffold(
          backgroundColor: colorScheme.surface, // Pure white (light) / Near black (dark) - per spec
          body: SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Header with pending count and sync badge
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    children: [
                      Text(
                        'ACTIVE QUEUE',
                        style: textTheme.headlineSmall,
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: colorScheme.warning,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Text(
                          '${activeQueue.length} Pending',
                          style: textTheme.labelMedium?.copyWith(
                            color: colorScheme.onWarning, // Use theme color for proper contrast
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      SyncBadge(
                        count: backOfficeProvider.getUnsyncedFulfilledCount(),
                        label: 'unsynced',
                      ),
                    ],
                  ),
                ),

                const Divider(height: 1),

                // Queue list
                Expanded(
                  child: activeQueue.isEmpty
                      ? _buildEmptyState(textTheme, colorScheme)
                      : ListView.builder(
                          itemCount: activeQueue.length,
                          itemBuilder: (context, index) {
                            final request = activeQueue[index];
                            final isNext = index == 0;
                            return _buildQueueItem(
                              context,
                              request,
                              index + 1,
                              isNext,
                              textTheme,
                              colorScheme,
                            );
                          },
                        ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  /// Build individual queue item with pull button
  Widget _buildQueueItem(
    BuildContext context,
    PosterRequest request,
    int rank,
    bool isNext,
    TextTheme textTheme,
    ColorScheme colorScheme,
  ) {
    final timeFormat = DateFormat('h:mm a');
    final receivedTime = timeFormat.format(request.timestampSent);

    return Container(
      decoration: BoxDecoration(
        color: isNext ? colorScheme.primary.withValues(alpha: 0.05) : colorScheme.surface,
        border: Border(
          bottom: BorderSide(
            color: Theme.of(context).dividerTheme.color ?? Colors.grey[300]!,
            width: 1,
          ),
          left: isNext
              ? BorderSide(
                  color: colorScheme.primary,
                  width: 4,
                )
              : BorderSide.none,
        ),
      ),
      child: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: isNext ? 12.0 : 16.0, // Account for left border
          vertical: 16.0,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Rank and poster number
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          // Rank number
                          Container(
                            width: 32,
                            height: 32,
                            decoration: BoxDecoration(
                              color: isNext ? colorScheme.primary : colorScheme.neutral,
                              shape: BoxShape.circle,
                            ),
                            child: Center(
                              child: Text(
                                '$rank',
                                style: textTheme.titleSmall?.copyWith(
                                  color: isNext ? colorScheme.onPrimary : colorScheme.onSurface,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          // Poster number
                          Text(
                            request.posterNumber,
                            style: textTheme.displaySmall?.copyWith(
                              fontWeight: FontWeight.w600,
                              fontSize: 32,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      // Received time
                      Padding(
                        padding: const EdgeInsets.only(left: 44.0),
                        child: Text(
                          receivedTime,
                          style: textTheme.bodySmall?.copyWith(
                            color: colorScheme.onSurface, // True Black (light) / Pure White (dark) for proper contrast
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                // PULL button
                ElevatedButton(
                  onPressed: () => _handlePull(context, request),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: colorScheme.success,
                    foregroundColor: colorScheme.onSuccess, // Use theme color for proper contrast
                    minimumSize: const Size(100, 56),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: Text(
                    'PULL',
                    style: textTheme.labelLarge?.copyWith(
                      fontSize: 16,
                      color: colorScheme.onSuccess, // Use theme color (white in light, black in dark)
                    ),
                  ),
                ),
              ],
            ),
            if (isNext)
              Padding(
                padding: const EdgeInsets.only(left: 44.0, top: 8.0),
                child: Text(
                  '(Next to Pull)',
                  style: textTheme.bodySmall?.copyWith(
                    color: colorScheme.primary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  /// Build empty state when queue is clear
  Widget _buildEmptyState(TextTheme textTheme, ColorScheme colorScheme) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.check_circle_outline,
              size: 80,
              color: colorScheme.success.withValues(alpha: 0.5),
            ),
            const SizedBox(height: 16),
            Text(
              'All caught up!',
              style: textTheme.headlineMedium?.copyWith(
                color: colorScheme.neutral,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'No pending requests at this time.',
              style: textTheme.bodyLarge?.copyWith(
                color: colorScheme.neutral,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
