import 'package:flutter/material.dart';

/// Custom keypad widget for poster number entry
///
/// Layout:
/// +---+---+---+---+
/// | A | B | C | D |
/// +---+---+---+---+
/// | 7 | 8 | 9 | - |
/// +---+---+---+---+
/// | 4 | 5 | 6 | E |
/// +---+---+---+ N |
/// | 1 | 2 | 3 | T |
/// +---+---+---+ E |
/// |     0     | R |
/// +-----------+---+
///
/// Features:
/// - Large touch targets (56dp minimum per project-theme.md)
/// - Letter buttons (A-D) for alphanumeric poster numbers
/// - Numeric buttons (0-9) for poster numbers
/// - Dash button (-) for poster numbers with separators
/// - ENTER button spans 3 rows, triggers submission
/// - Theme-compliant styling
class PosterEntryKeypad extends StatelessWidget {
  /// Callback invoked when a character button (A-D, 0-9, -) is pressed
  final void Function(String character) onCharacterPressed;

  /// Callback invoked when the ENTER button is pressed
  final VoidCallback onEnterPressed;

  const PosterEntryKeypad({
    super.key,
    required this.onCharacterPressed,
    required this.onEnterPressed,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Container(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Row 1: A B C D
          Row(
            children: [
              _buildKeypadButton(context, 'A', colorScheme, textTheme),
              const SizedBox(width: 8),
              _buildKeypadButton(context, 'B', colorScheme, textTheme),
              const SizedBox(width: 8),
              _buildKeypadButton(context, 'C', colorScheme, textTheme),
              const SizedBox(width: 8),
              _buildKeypadButton(context, 'D', colorScheme, textTheme),
            ],
          ),
          const SizedBox(height: 8),

          // Row 2: 7 8 9 -
          Row(
            children: [
              _buildKeypadButton(context, '7', colorScheme, textTheme),
              const SizedBox(width: 8),
              _buildKeypadButton(context, '8', colorScheme, textTheme),
              const SizedBox(width: 8),
              _buildKeypadButton(context, '9', colorScheme, textTheme),
              const SizedBox(width: 8),
              _buildKeypadButton(context, '-', colorScheme, textTheme),
            ],
          ),
          const SizedBox(height: 8),

          // Rows 3-5: 4-6, 1-3, 0 with ENTER button spanning 3 rows
          IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Left column: 4-6, 1-3, 0
                Expanded(
                  flex: 3,
                  child: Column(
                    children: [
                      // Row 3: 4 5 6
                      Row(
                        children: [
                          _buildKeypadButton(context, '4', colorScheme, textTheme),
                          const SizedBox(width: 8),
                          _buildKeypadButton(context, '5', colorScheme, textTheme),
                          const SizedBox(width: 8),
                          _buildKeypadButton(context, '6', colorScheme, textTheme),
                        ],
                      ),
                      const SizedBox(height: 8),

                      // Row 4: 1 2 3
                      Row(
                        children: [
                          _buildKeypadButton(context, '1', colorScheme, textTheme),
                          const SizedBox(width: 8),
                          _buildKeypadButton(context, '2', colorScheme, textTheme),
                          const SizedBox(width: 8),
                          _buildKeypadButton(context, '3', colorScheme, textTheme),
                        ],
                      ),
                      const SizedBox(height: 8),

                      // Row 5: 0 (wide button)
                      _buildWideKeypadButton(context, '0', colorScheme, textTheme),
                    ],
                  ),
                ),
                const SizedBox(width: 8),

                // Right column: ENTER button (spans 3 rows)
                Expanded(
                  flex: 1,
                  child: _buildEnterButton(context, colorScheme, textTheme),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Build a standard keypad button
  Widget _buildKeypadButton(
    BuildContext context,
    String character,
    ColorScheme colorScheme,
    TextTheme textTheme,
  ) {
    return Expanded(
      child: SizedBox(
        height: 56, // Minimum touch target per project-theme.md
        child: ElevatedButton(
          onPressed: () => onCharacterPressed(character),
          style: ElevatedButton.styleFrom(
            backgroundColor: colorScheme.surfaceContainerHigh,
            foregroundColor: colorScheme.onSurface,
            padding: EdgeInsets.zero,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8), // 8dp border radius per project-theme.md
            ),
          ),
          child: Text(
            character,
            style: textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }

  /// Build a wide keypad button (for '0')
  Widget _buildWideKeypadButton(
    BuildContext context,
    String character,
    ColorScheme colorScheme,
    TextTheme textTheme,
  ) {
    return SizedBox(
      height: 56, // Minimum touch target per project-theme.md
      child: ElevatedButton(
        onPressed: () => onCharacterPressed(character),
        style: ElevatedButton.styleFrom(
          backgroundColor: colorScheme.surfaceContainerHigh,
          foregroundColor: colorScheme.onSurface,
          padding: EdgeInsets.zero,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8), // 8dp border radius per project-theme.md
          ),
        ),
        child: Text(
          character,
          style: textTheme.headlineMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  /// Build the ENTER button (spans 3 rows)
  Widget _buildEnterButton(
    BuildContext context,
    ColorScheme colorScheme,
    TextTheme textTheme,
  ) {
    return ElevatedButton(
      onPressed: onEnterPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: colorScheme.primary,
        foregroundColor: colorScheme.onPrimary,
        padding: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8), // 8dp border radius per project-theme.md
        ),
      ),
      child: Text(
        'ENTER',
        style: textTheme.titleLarge?.copyWith(
          fontWeight: FontWeight.w700,
          color: colorScheme.onPrimary,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }
}
