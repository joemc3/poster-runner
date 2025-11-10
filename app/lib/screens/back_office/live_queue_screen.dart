import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../models/poster_request.dart';
import '../../models/mock_data.dart';
import '../../theme/app_theme.dart';
import '../../main.dart';

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
/// TODO: Connect to BLE service for real-time request sync
/// TODO: Implement actual fulfillment action and status update

class LiveQueueScreen extends StatefulWidget {
  /// Callback when a request is fulfilled
  /// TODO: Replace with actual BLE service call
  final Function(PosterRequest request)? onFulfillRequest;

  /// List of pending requests
  /// TODO: Replace with actual data from BLE sync
  final List<PosterRequest>? pendingRequests;

  const LiveQueueScreen({
    this.onFulfillRequest,
    this.pendingRequests,
    super.key,
  });

  @override
  State<LiveQueueScreen> createState() => _LiveQueueScreenState();
}

class _LiveQueueScreenState extends State<LiveQueueScreen> {
  // TODO: Replace with actual state management
  late List<PosterRequest> _activeQueue;

  @override
  void initState() {
    super.initState();
    _initializePlaceholderData();
  }

  /// Initialize with placeholder data from MockPosterRequests
  /// TODO: Remove when connected to actual data source
  void _initializePlaceholderData() {
    // Use centralized mock data (already sorted by timestampSent, oldest first)
    _activeQueue = widget.pendingRequests ?? MockPosterRequests.liveQueue;
  }

  /// Handle pull button press
  ///
  /// This method:
  /// 1. Creates a fulfilled version of the request with timestampPulled
  /// 2. Saves it to persistent storage (Hive)
  /// 3. Removes it from the active queue
  /// 4. Shows a confirmation message
  ///
  /// TODO: Integrate with actual BLE service to sync with Front Desk
  Future<void> _handlePull(PosterRequest request) async {
    try {
      // Create fulfilled version of the request
      final fulfilledRequest = request.copyWith(
        status: RequestStatus.fulfilled,
        timestampPulled: DateTime.now(),
        isSynced: false, // Not yet synced via BLE
      );

      // Save to persistent storage (write-immediately pattern)
      await persistenceService.saveFulfilledRequest(fulfilledRequest);

      // TODO: Transmit to Front Desk via BLE Queue Status Characteristic (B)
      // final bleMessage = fulfilledRequest.toQueueStatusJson();
      // await bleService.sendQueueStatusUpdate(bleMessage);

      // Call callback if provided (for future use with state management)
      widget.onFulfillRequest?.call(fulfilledRequest);

      // Remove from active queue
      setState(() {
        _activeQueue.removeWhere((r) => r.uniqueId == request.uniqueId);
      });

      // Show confirmation
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${request.posterNumber} marked as pulled'),
            backgroundColor: Theme.of(context).colorScheme.success,
            duration: const Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      // Show error message if save fails
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error saving request: $e'),
            backgroundColor: Theme.of(context).colorScheme.error,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      backgroundColor: colorScheme.surface, // Pure white (light) / Near black (dark) - per spec
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Header with pending count
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
                      '${_activeQueue.length} Pending',
                      style: textTheme.labelMedium?.copyWith(
                        color: colorScheme.onWarning, // Use theme color for proper contrast
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const Divider(height: 1),

            // Queue list
            Expanded(
              child: _activeQueue.isEmpty
                  ? _buildEmptyState(textTheme, colorScheme)
                  : ListView.builder(
                      itemCount: _activeQueue.length,
                      itemBuilder: (context, index) {
                        final request = _activeQueue[index];
                        final isNext = index == 0;
                        return _buildQueueItem(
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
  }

  /// Build individual queue item with pull button
  Widget _buildQueueItem(
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
                  onPressed: () => _handlePull(request),
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
