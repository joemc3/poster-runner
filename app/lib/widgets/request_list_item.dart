import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/poster_request.dart';
import '../theme/app_theme.dart';
import 'status_badge.dart';

/// Request List Item Widget
/// Displays a single poster request in a list
///
/// Design specs from project-theme.md:
/// - Height: 88dp minimum (allows multi-line content with comfortable spacing)
/// - Padding: 16dp horizontal, 16dp vertical
/// - Divider: 1dp solid, color: Divider (light gray)
/// - Elevation: 0dp at rest, 2dp on press (tactile feedback)
///
/// Content Hierarchy:
/// 1. Primary: Request number (titleLarge, SemiBold) - Top left
/// 2. Secondary: Customer name / Booth number (bodyLarge) - Below primary
/// 3. Metadata: Timestamp (bodySmall, Neutral color) - Bottom left
/// 4. Status: Badge (labelLarge, status color) - Right side, vertically centered

class RequestListItem extends StatelessWidget {
  final PosterRequest request;
  final VoidCallback? onTap;
  final Widget? trailing; // Optional trailing widget (e.g., action button)

  const RequestListItem({
    required this.request,
    this.onTap,
    this.trailing,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    // Format timestamp
    final timeFormat = DateFormat('h:mm a');
    final displayTime = timeFormat.format(request.timestampSent);

    // Apply fulfilled background tint if fulfilled
    final backgroundColor = request.isFulfilled
        ? colorScheme.fulfilledTint
        : colorScheme.surface;

    return Material(
      color: backgroundColor,
      child: InkWell(
        onTap: onTap,
        child: Container(
          constraints: const BoxConstraints(minHeight: 88),
          padding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 16,
          ),
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(
                color: colorScheme.divider,
                width: 1,
              ),
            ),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Left content: Poster number and timestamp
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Poster number (primary)
                    Text(
                      request.posterNumber,
                      style: textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w600, // SemiBold for scanability
                      ),
                    ),
                    const SizedBox(height: 4),
                    // Timestamp (metadata)
                    Text(
                      displayTime,
                      style: textTheme.bodySmall?.copyWith(
                        color: colorScheme.neutral,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              // Right content: Status badge or custom trailing widget
              trailing ?? StatusBadge(status: request.status),
            ],
          ),
        ),
      ),
    );
  }
}
