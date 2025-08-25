import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

/// StateProvider to store dark mode on/off
final themeProvider = StateProvider<bool>((ref) => false);

/// AppTheme provider
final themeModeProvider = Provider<ThemeMode>((ref) {
  final isDark = ref.watch(themeProvider);
  return isDark ? ThemeMode.dark : ThemeMode.light;
});

/// Light Theme
final ThemeData lightTheme = ThemeData.light().copyWith(
  primaryColor: Colors.deepPurple,
  scaffoldBackgroundColor: Colors.grey[100],
  cardColor: Colors.white,
  appBarTheme: const AppBarTheme(
    color: Colors.deepPurple,
    foregroundColor: Colors.white,
  ),
  floatingActionButtonTheme: const FloatingActionButtonThemeData(
    backgroundColor: Colors.deepPurple,
  ),
  switchTheme: SwitchThemeData(
    thumbColor: WidgetStateProperty.all(Colors.deepPurple),
    trackColor: WidgetStateProperty.all(Colors.deepPurple.shade200),
  ),
);

/// Dark Theme
final ThemeData darkTheme = ThemeData.dark().copyWith(
  primaryColor: Colors.deepPurple,
  scaffoldBackgroundColor: Colors.black,
  cardColor: Colors.grey[900],
  appBarTheme: const AppBarTheme(
    color: Colors.deepPurple,
    foregroundColor: Colors.white,
  ),
  floatingActionButtonTheme: const FloatingActionButtonThemeData(
    backgroundColor: Colors.deepPurple,
  ),
  switchTheme: SwitchThemeData(
    thumbColor: WidgetStateProperty.all(Colors.deepPurple),
    trackColor: WidgetStateProperty.all(Colors.deepPurple.shade400),
  ),
);
