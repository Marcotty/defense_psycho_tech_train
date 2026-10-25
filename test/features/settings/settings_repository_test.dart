import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:defense_psycho_tech_train/app/models/cognitive_test_type.dart';
import 'package:defense_psycho_tech_train/features/settings/data/settings_repository.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUp(() => SharedPreferences.setMockInitialValues({}));

  test('stores the selected theme and per-test time limits', () async {
    const repository = SettingsRepository();

    expect(await repository.loadThemeMode(), ThemeMode.system);
    await repository.saveThemeMode(ThemeMode.dark);
    await repository.saveTestTimeLimits({
      for (final type in CognitiveTestType.values)
        type: type == CognitiveTestType.reasoning
            ? const Duration(minutes: 2, seconds: 30)
            : null,
    });

    expect(await repository.loadThemeMode(), ThemeMode.dark);
    expect(
      (await repository.loadTestTimeLimits())[CognitiveTestType.reasoning],
      const Duration(minutes: 2, seconds: 30),
    );
    expect(
      (await repository.loadTestTimeLimits())[CognitiveTestType.wordMemory],
      isNull,
    );
  });
}
