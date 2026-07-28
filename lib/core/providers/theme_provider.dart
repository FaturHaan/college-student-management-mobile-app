import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';

const String settingsBoxName = 'settingsBox';
const String darkModeKey = 'isDarkMode';

class ThemeNotifier extends StateNotifier<bool> {
  ThemeNotifier() : super(false) {
    _loadTheme();
  }

  void _loadTheme() {
    final box = Hive.box(settingsBoxName);
    final isDark = box.get(darkModeKey, defaultValue: false);
    state = isDark;
  }

  Future<void> toggleTheme() async {
    final box = Hive.box(settingsBoxName);
    final newThemeState = !state;
    await box.put(darkModeKey, newThemeState);
    state = newThemeState;
  }

  Future<void> setDarkMode(bool isDark) async {
    final box = Hive.box(settingsBoxName);
    await box.put(darkModeKey, isDark);
    state = isDark;
  }
}

final themeProvider = StateNotifierProvider<ThemeNotifier, bool>((ref) {
  return ThemeNotifier();
});
