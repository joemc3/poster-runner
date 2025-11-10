import 'package:flutter/material.dart';
import '../models/poster_request.dart';
import '../theme/app_theme.dart';

/// Status Badge Widget
/// Displays the status of a poster request with color coding and icons
///
/// Design specs from project-theme.md:
/// - Shape: Rounded rectangle (16dp radius for pill effect)
/// - Height: 32dp
/// - Horizontal Padding: 12dp
/// - Typography: labelLarge (14sp), Medium weight (500), ALL CAPS
/// - Color: Status-specific (Info, Warning, Success)
/// - Accessibility: Color + Icon + Text (not relying on color alone)

class StatusBadge extends StatelessWidget {
  final RequestStatus status;

  const StatusBadge({
    required this.status,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    // Determine color based on status
    final Color backgroundColor = _getBackgroundColor(colorScheme);
    final Color textColor = _getTextColor(colorScheme);

    return Container(
      height: 32,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(16), // Pill shape
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Status icon for accessibility
          Text(
            status.icon,
            style: Theme.of(context).textTheme.labelLarge?.copyWith(
              color: textColor,
            ),
          ),
          const SizedBox(width: 6),
          // Status label in ALL CAPS
          Text(
            status.label,
            style: Theme.of(context).textTheme.labelLarge?.copyWith(
                  color: textColor,
                  fontWeight: FontWeight.w500,
                ),
          ),
        ],
      ),
    );
  }

  /// Get background color based on status and theme brightness
  Color _getBackgroundColor(ColorScheme colorScheme) {
    switch (status) {
      case RequestStatus.sent:
        return colorScheme.info; // Light Blue
      case RequestStatus.pending:
        return colorScheme.warning; // Amber
      case RequestStatus.fulfilled:
        return colorScheme.success; // Green
    }
  }

  /// Get text color based on status and theme brightness
  /// CRITICAL: Uses theme-defined "on" colors for proper contrast
  /// - Light theme: WHITE text on DARK status backgrounds
  /// - Dark theme: BLACK text on BRIGHT status backgrounds
  Color _getTextColor(ColorScheme colorScheme) {
    switch (status) {
      case RequestStatus.sent:
        return colorScheme.onInfo; // White on dark blue (light) / Black on bright cyan (dark)
      case RequestStatus.pending:
        return colorScheme.onWarning; // White on dark orange (light) / Black on bright orange (dark)
      case RequestStatus.fulfilled:
        return colorScheme.onSuccess; // White on dark green (light) / Black on bright green (dark)
    }
  }
}
