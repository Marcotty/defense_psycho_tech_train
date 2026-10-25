import 'package:flutter/material.dart';

abstract final class AppTheme {
  static const _navy = Color(0xFF18324B);
  static const _amber = Color(0xFFF2B84B);

  static ThemeData light() => _create(Brightness.light);
  static ThemeData dark() => _create(Brightness.dark);

  static ThemeData _create(Brightness brightness) {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: _navy,
      secondary: _amber,
      brightness: brightness,
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      brightness: brightness,
    );
  }
}
