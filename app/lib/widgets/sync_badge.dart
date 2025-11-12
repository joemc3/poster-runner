import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

/// Sync Badge Widget
///
/// Displays a small badge indicator showing the count of unsynced items
/// waiting for BLE transmission. Used in screen headers to provide
/// visibility into offline queue status.
///
/// **Visual Design:**
/// - Small circular badge with count number
/// - Amber/warning color when items are pending sync
/// - Neutral/gray color when no items pending
/// - High contrast text for readability
///
/// **Usage:**
/// ```dart
/// SyncBadge(
///   count: frontDeskProvider.getUnsyncedCount(),
///   label: 'Pending Sync',
/// )
/// ```
class SyncBadge extends StatelessWidget {
  /// Number of unsynced items
  final int count;

  /// Optional label text to display alongside badge
  final String? label;

  const SyncBadge({
    super.key,
    required this.count,
    this.label,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    // Don't show badge if count is 0
    if (count == 0) {
      return const SizedBox.shrink();
    }

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 10,
        vertical: 4,
      ),
      decoration: BoxDecoration(
        color: colorScheme.warning,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.sync,
            size: 14,
            color: colorScheme.onWarning,
          ),
          const SizedBox(width: 4),
          Text(
            count.toString(),
            style: textTheme.labelSmall?.copyWith(
              color: colorScheme.onWarning,
              fontWeight: FontWeight.w700,
              fontSize: 12,
            ),
          ),
          if (label != null) ...[
            const SizedBox(width: 4),
            Text(
              label!,
              style: textTheme.labelSmall?.copyWith(
                color: colorScheme.onWarning,
                fontWeight: FontWeight.w600,
                fontSize: 11,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
