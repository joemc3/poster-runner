import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';

/// Keypad Customization Provider
///
/// Manages customization of A, B, C, D button labels on the Front Desk
/// poster entry keypad. Button values are persisted to Hive and restored
/// on app launch.
///
/// Validation:
/// - Each button accepts 0-3 printable characters
/// - Whitespace is trimmed
/// - Case is preserved as entered
/// - Empty values are allowed (button displays default letter when empty)
/// - Duplicates are allowed across buttons
/// - Separator can be: None, :, -, or blank space (appended after button value)
class KeypadCustomizationProvider extends ChangeNotifier {
  static const String _boxName = 'app_preferences';
  static const String _buttonAKey = 'button_a';
  static const String _buttonBKey = 'button_b';
  static const String _buttonCKey = 'button_c';
  static const String _buttonDKey = 'button_d';
  static const String _separatorKey = 'letter_button_separator';

  // Default button values
  static const String _defaultA = 'A';
  static const String _defaultB = 'B';
  static const String _defaultC = 'C';
  static const String _defaultD = 'D';
  static const String _defaultSeparator = 'None';

  String _buttonA = _defaultA;
  String _buttonB = _defaultB;
  String _buttonC = _defaultC;
  String _buttonD = _defaultD;
  String _separator = _defaultSeparator;

  Box? _preferencesBox;

  // Getters for button values
  String get buttonA => _buttonA;
  String get buttonB => _buttonB;
  String get buttonC => _buttonC;
  String get buttonD => _buttonD;
  String get separator => _separator;

  KeypadCustomizationProvider() {
    _loadButtonPreferences();
  }

  /// Load button preferences from Hive
  Future<void> _loadButtonPreferences() async {
    try {
      _preferencesBox = await Hive.openBox(_boxName);

      _buttonA = _preferencesBox?.get(_buttonAKey, defaultValue: _defaultA) ?? _defaultA;
      _buttonB = _preferencesBox?.get(_buttonBKey, defaultValue: _defaultB) ?? _defaultB;
      _buttonC = _preferencesBox?.get(_buttonCKey, defaultValue: _defaultC) ?? _defaultC;
      _buttonD = _preferencesBox?.get(_buttonDKey, defaultValue: _defaultD) ?? _defaultD;
      _separator = _preferencesBox?.get(_separatorKey, defaultValue: _defaultSeparator) ?? _defaultSeparator;

      notifyListeners();
    } catch (e) {
      debugPrint('Error loading button preferences: $e');
    }
  }

  /// Validate button value
  /// - Trim whitespace
  /// - Limit to 3 characters
  /// - Preserve case
  /// - Allow empty values
  String _validateButtonValue(String value, String defaultValue) {
    final trimmed = value.trim();

    // Allow empty values - return empty string
    if (trimmed.isEmpty) {
      return '';
    }

    // Limit to 3 characters, preserve case
    return trimmed.substring(0, trimmed.length > 3 ? 3 : trimmed.length);
  }

  /// Update button A value
  Future<void> updateButtonA(String value) async {
    final validated = _validateButtonValue(value, _defaultA);
    if (_buttonA == validated) return;

    _buttonA = validated;
    notifyListeners();

    try {
      await _preferencesBox?.put(_buttonAKey, _buttonA);
    } catch (e) {
      debugPrint('Error saving button A preference: $e');
    }
  }

  /// Update button B value
  Future<void> updateButtonB(String value) async {
    final validated = _validateButtonValue(value, _defaultB);
    if (_buttonB == validated) return;

    _buttonB = validated;
    notifyListeners();

    try {
      await _preferencesBox?.put(_buttonBKey, _buttonB);
    } catch (e) {
      debugPrint('Error saving button B preference: $e');
    }
  }

  /// Update button C value
  Future<void> updateButtonC(String value) async {
    final validated = _validateButtonValue(value, _defaultC);
    if (_buttonC == validated) return;

    _buttonC = validated;
    notifyListeners();

    try {
      await _preferencesBox?.put(_buttonCKey, _buttonC);
    } catch (e) {
      debugPrint('Error saving button C preference: $e');
    }
  }

  /// Update button D value
  Future<void> updateButtonD(String value) async {
    final validated = _validateButtonValue(value, _defaultD);
    if (_buttonD == validated) return;

    _buttonD = validated;
    notifyListeners();

    try {
      await _preferencesBox?.put(_buttonDKey, _buttonD);
    } catch (e) {
      debugPrint('Error saving button D preference: $e');
    }
  }

  /// Update separator value
  Future<void> updateSeparator(String value) async {
    if (_separator == value) return;

    _separator = value;
    notifyListeners();

    try {
      await _preferencesBox?.put(_separatorKey, _separator);
    } catch (e) {
      debugPrint('Error saving separator preference: $e');
    }
  }

  /// Update all button values and separator at once
  /// Useful for batch updates from customization dialog
  Future<void> updateAllButtons({
    required String buttonA,
    required String buttonB,
    required String buttonC,
    required String buttonD,
    required String separator,
  }) async {
    final validatedA = _validateButtonValue(buttonA, _defaultA);
    final validatedB = _validateButtonValue(buttonB, _defaultB);
    final validatedC = _validateButtonValue(buttonC, _defaultC);
    final validatedD = _validateButtonValue(buttonD, _defaultD);

    _buttonA = validatedA;
    _buttonB = validatedB;
    _buttonC = validatedC;
    _buttonD = validatedD;
    _separator = separator;

    notifyListeners();

    try {
      await _preferencesBox?.put(_buttonAKey, _buttonA);
      await _preferencesBox?.put(_buttonBKey, _buttonB);
      await _preferencesBox?.put(_buttonCKey, _buttonC);
      await _preferencesBox?.put(_buttonDKey, _buttonD);
      await _preferencesBox?.put(_separatorKey, _separator);
    } catch (e) {
      debugPrint('Error saving button preferences: $e');
    }
  }

  /// Get the actual separator character to append
  /// Converts the display name to the actual character
  String getSeparatorCharacter() {
    switch (_separator) {
      case 'None':
        return '';
      case ':':
        return ':';
      case '-':
        return '-';
      case 'Blank Space':
        return ' ';
      default:
        return '';
    }
  }

  /// Get button value by index (0-3)
  /// Useful for programmatic access
  String getButtonValue(int index) {
    switch (index) {
      case 0:
        return _buttonA;
      case 1:
        return _buttonB;
      case 2:
        return _buttonC;
      case 3:
        return _buttonD;
      default:
        throw ArgumentError('Button index must be 0-3');
    }
  }

  /// Check if any button has been customized from defaults
  bool get hasCustomizations {
    return _buttonA != _defaultA ||
        _buttonB != _defaultB ||
        _buttonC != _defaultC ||
        _buttonD != _defaultD;
  }
}
