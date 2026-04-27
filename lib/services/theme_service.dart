import 'package:smartkasir/services/preferences_service.dart';
import 'package:smartkasir/constants/app_colors.dart';
import 'package:flutter/material.dart';

class ThemeService extends ChangeNotifier {
  final PreferencesService _preferencesService;

  ThemeMode _themeMode = ThemeMode.system;
  Color _seedColor = AppColors.primary;

  ThemeService(this._preferencesService) {
    _loadPreferences();
  }

  ThemeMode get themeMode => _themeMode;

  Color get seedColor => _seedColor;

  Future<void> _loadPreferences() async {
    final modeIndex = await _preferencesService.get<int>(PrefKey.themeMode);
    if (modeIndex != null && modeIndex >= 0 && modeIndex <ThemeMode.values.length) {
      _themeMode = ThemeMode.values[modeIndex];
    }

    final colorValue = await _preferencesService.get<int>(PrefKey.seedColor);
    if (colorValue != null) {
      _seedColor = Color(colorValue);
    }
    notifyListeners();
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    if (_themeMode == mode) return;
    _themeMode = mode;
    notifyListeners();
    await _preferencesService.set(PrefKey.themeMode, mode.index);
  }

  Future<void> setSeedColor(Color color) async {
    if (_seedColor == color) return;
    _seedColor = color;
    notifyListeners();
    await _preferencesService.set(PrefKey.seedColor, color.value);
  }

  /// Reload settings from preferences (e.g., after import).
  Future<void> loadSettings() async {
    await _loadPreferences();
  }
}