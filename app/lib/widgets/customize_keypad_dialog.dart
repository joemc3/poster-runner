import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../providers/keypad_customization_provider.dart';

/// Customize Keypad Dialog
///
/// Modal dialog for customizing the A, B, C, D button labels on the
/// Front Desk poster entry keypad.
///
/// Features:
/// - Four text fields for A, B, C, D customization
/// - 0-3 character limit per button
/// - Case preservation (no automatic uppercasing)
/// - Empty values allowed (button shows default letter when empty)
/// - Input validation and whitespace trimming
/// - Save/Cancel actions
/// - Immediate keypad update on save
class CustomizeKeypadDialog extends StatefulWidget {
  const CustomizeKeypadDialog({super.key});

  @override
  State<CustomizeKeypadDialog> createState() => _CustomizeKeypadDialogState();
}

class _CustomizeKeypadDialogState extends State<CustomizeKeypadDialog> {
  late TextEditingController _buttonAController;
  late TextEditingController _buttonBController;
  late TextEditingController _buttonCController;
  late TextEditingController _buttonDController;
  late String _selectedSeparator;

  // Separator options
  final List<String> _separatorOptions = ['None', ':', '-', 'Blank Space'];

  @override
  void initState() {
    super.initState();

    // Initialize controllers with current button values
    final customization = context.read<KeypadCustomizationProvider>();
    _buttonAController = TextEditingController(text: customization.buttonA);
    _buttonBController = TextEditingController(text: customization.buttonB);
    _buttonCController = TextEditingController(text: customization.buttonC);
    _buttonDController = TextEditingController(text: customization.buttonD);
    _selectedSeparator = customization.separator;
  }

  @override
  void dispose() {
    _buttonAController.dispose();
    _buttonBController.dispose();
    _buttonCController.dispose();
    _buttonDController.dispose();
    super.dispose();
  }

  /// Save button values and separator to provider and close dialog
  Future<void> _saveChanges() async {
    final customization = context.read<KeypadCustomizationProvider>();

    await customization.updateAllButtons(
      buttonA: _buttonAController.text,
      buttonB: _buttonBController.text,
      buttonC: _buttonCController.text,
      buttonD: _buttonDController.text,
      separator: _selectedSeparator,
    );

    if (mounted) {
      Navigator.of(context).pop();
    }
  }

  /// Cancel and close dialog without saving
  void _cancel() {
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return AlertDialog(
      title: Text(
        'Customize Letter Buttons',
        style: textTheme.titleLarge?.copyWith(
          fontWeight: FontWeight.w600,
        ),
      ),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Instructions
            Text(
              'Customize the labels for the letter buttons on the keypad.',
              style: textTheme.bodyMedium?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 24),

            // Button A field
            _buildTextField(
              label: 'Button A',
              controller: _buttonAController,
              colorScheme: colorScheme,
              textTheme: textTheme,
            ),
            const SizedBox(height: 16),

            // Button B field
            _buildTextField(
              label: 'Button B',
              controller: _buttonBController,
              colorScheme: colorScheme,
              textTheme: textTheme,
            ),
            const SizedBox(height: 16),

            // Button C field
            _buildTextField(
              label: 'Button C',
              controller: _buttonCController,
              colorScheme: colorScheme,
              textTheme: textTheme,
            ),
            const SizedBox(height: 16),

            // Button D field
            _buildTextField(
              label: 'Button D',
              controller: _buttonDController,
              colorScheme: colorScheme,
              textTheme: textTheme,
            ),
            const SizedBox(height: 16),

            // Character limit hint
            Text(
              'Maximum 3 characters per button',
              style: textTheme.bodySmall?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 16),

            // Separator dropdown
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Letter Button Separator:',
                  style: textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 8),
                InputDecorator(
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: _selectedSeparator,
                      isDense: true,
                      isExpanded: true,
                      items: _separatorOptions.map((String option) {
                        return DropdownMenuItem<String>(
                          value: option,
                          child: Text(option),
                        );
                      }).toList(),
                      onChanged: (String? newValue) {
                        if (newValue != null) {
                          setState(() {
                            _selectedSeparator = newValue;
                          });
                        }
                      },
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
      actions: [
        // Cancel button
        TextButton(
          onPressed: _cancel,
          child: const Text('CANCEL'),
        ),

        // Save button
        FilledButton(
          onPressed: _saveChanges,
          child: const Text('SAVE'),
        ),
      ],
    );
  }

  /// Build a text field for button customization
  Widget _buildTextField({
    required String label,
    required TextEditingController controller,
    required ColorScheme colorScheme,
    required TextTheme textTheme,
  }) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
        counterText: '', // Hide character counter
      ),
      maxLength: 3,
      inputFormatters: [
        LengthLimitingTextInputFormatter(3),
      ],
    );
  }
}
