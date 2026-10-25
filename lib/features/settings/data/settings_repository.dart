import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../app/models/cognitive_test_type.dart';

class SettingsRepository {
  const SettingsRepository();

  static const _themeModeKey = 'themeMode';

  Future<ThemeMode> loadThemeMode() async {
    final value = (await SharedPreferences.getInstance()).getString(
      _themeModeKey,
    );
    return switch (value) {
      null || 'system' => ThemeMode.system,
      'light' => ThemeMode.light,
      'dark' => ThemeMode.dark,
      _ => throw FormatException('Unknown saved theme mode "$value".'),
    };
  }

  Future<void> saveThemeMode(ThemeMode mode) async {
    await (await SharedPreferences.getInstance()).setString(
      _themeModeKey,
      mode.name,
    );
  }

  Future<Map<CognitiveTestType, Duration?>> loadTestTimeLimits() async {
    final preferences = await SharedPreferences.getInstance();
    return {
      for (final type in CognitiveTestType.values)
        type: _durationFromSeconds(preferences.getInt(_timeLimitKey(type))),
    };
  }

  Future<void> saveTestTimeLimits(
    Map<CognitiveTestType, Duration?> timeLimits,
  ) async {
    if (timeLimits.keys.toSet().length != CognitiveTestType.values.length ||
        !CognitiveTestType.values.every(timeLimits.containsKey)) {
      throw ArgumentError.value(
        timeLimits,
        'timeLimits',
        'A value is required for every cognitive test type.',
      );
    }
    for (final entry in timeLimits.entries) {
      if (entry.value != null && entry.value!.inSeconds <= 0) {
        throw ArgumentError.value(
          entry.value,
          'timeLimits',
          'Time limits must be at least one second.',
        );
      }
    }

    final preferences = await SharedPreferences.getInstance();
    for (final entry in timeLimits.entries) {
      final key = _timeLimitKey(entry.key);
      final duration = entry.value;
      if (duration == null) {
        await preferences.remove(key);
      } else {
        await preferences.setInt(key, duration.inSeconds);
      }
    }
  }

  String _timeLimitKey(CognitiveTestType type) =>
      'timeLimitSeconds.${type.name}';

  Duration? _durationFromSeconds(int? seconds) {
    if (seconds == null) return null;
    if (seconds <= 0) {
      throw FormatException('A saved test time limit must be positive.');
    }
    return Duration(seconds: seconds);
  }
}
