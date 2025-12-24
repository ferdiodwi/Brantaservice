import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../constants/app_constants.dart';

/// Provider for Theme Settings
final themeProvider = StateNotifierProvider<ThemeNotifier, ThemeMode>((ref) {
  return ThemeNotifier();
});

class ThemeNotifier extends StateNotifier<ThemeMode> {
  static const String _themeKey = 'theme_mode';
  final _box = Hive.box(AppConstants.settingsBox);

  ThemeNotifier() : super(ThemeMode.light) {
    _loadTheme();
  }

  void _loadTheme() {
    final themeString = _box.get(_themeKey) as String?;
    if (themeString != null) {
      state = _parseThemeMode(themeString);
    }
  }

  Future<void> setTheme(ThemeMode mode) async {
    state = mode;
    await _box.put(_themeKey, mode.toString());
  }

  void toggleTheme() {
    state = state == ThemeMode.light ? ThemeMode.dark : ThemeMode.light;
    _box.put(_themeKey, state.toString());
  }
  
  ThemeMode _parseThemeMode(String value) {
    if (value == ThemeMode.dark.toString()) return ThemeMode.dark;
    if (value == ThemeMode.light.toString()) return ThemeMode.light;
    return ThemeMode.system;
  }
}
