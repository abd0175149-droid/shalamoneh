import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dark_theme.dart';
import 'light_theme.dart';

/// مفتاح حفظ تفضيل الثيم في التخزين المحلي
const _themeKey = 'theme_mode';

/// Provider لوضع الثيم (dark / light / system)
final themeModeProvider =
    NotifierProvider<ThemeModeNotifier, ThemeMode>(ThemeModeNotifier.new);

/// Provider لـ ThemeData الداكن
final darkThemeProvider = Provider<ThemeData>((ref) => buildDarkTheme());

/// Provider لـ ThemeData الفاتح
final lightThemeProvider = Provider<ThemeData>((ref) => buildLightTheme());

/// يدير تبديل الثيم وحفظ التفضيل محلياً
class ThemeModeNotifier extends Notifier<ThemeMode> {
  @override
  ThemeMode build() {
    _loadSavedTheme();
    return ThemeMode.dark; // الافتراضي: داكن
  }

  /// تحميل الثيم المحفوظ عند فتح التطبيق
  Future<void> _loadSavedTheme() async {
    final prefs = await SharedPreferences.getInstance();
    final savedTheme = prefs.getString(_themeKey);
    if (savedTheme != null) {
      state = ThemeMode.values.firstWhere(
        (mode) => mode.name == savedTheme,
        orElse: () => ThemeMode.dark,
      );
    }
  }

  /// تبديل الثيم وحفظه
  Future<void> setThemeMode(ThemeMode mode) async {
    state = mode;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_themeKey, mode.name);
  }

  /// تبديل سريع بين داكن وفاتح
  Future<void> toggleTheme() async {
    final newMode = state == ThemeMode.dark ? ThemeMode.light : ThemeMode.dark;
    await setThemeMode(newMode);
  }

  /// هل الوضع الحالي داكن؟
  bool get isDark => state == ThemeMode.dark;
}
