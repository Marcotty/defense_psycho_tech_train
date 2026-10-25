import 'dart:math';

import 'package:defense_psycho_tech_train/app/models/cognitive_test_type.dart';
import 'package:defense_psycho_tech_train/features/session/domain/timed_exercise_generator.dart';
import 'package:defense_psycho_tech_train/features/session/presentation/timed_test_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  Future<void> pumpTimedTest(
    WidgetTester tester,
    CognitiveTestType type,
    int seed,
  ) async {
    SharedPreferences.setMockInitialValues({
      'timeLimitSeconds.${type.name}': 600,
    });
    await tester.pumpWidget(
      MaterialApp(
        home: TimedTestPage(
          testType: type,
          exerciseGenerator: TimedExerciseGenerator(
            random: Random(seed),
            exerciseCount: 6,
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  for (final type in CognitiveTestType.values) {
    testWidgets('${type.name}: generated exercises validate rules in a run', (
      tester,
    ) async {
      await pumpTimedTest(tester, type, 11);
      final expected = TimedExerciseGenerator(
        random: Random(11),
        exerciseCount: 6,
      ).generate(type);

      for (final exercise in expected) {
        expect(find.text('Afficher la question'), findsOneWidget);
        expect(find.text(exercise.memorizationContent), findsOneWidget);
        await tester.tap(find.text('Afficher la question'));
        await tester.pumpAndSettle();

        final correct = exercise.options.singleWhere(
          (o) => o.id == exercise.correctOptionId,
        );
        final correctButton = type == CognitiveTestType.spatialOrientation
            ? find.widgetWithText(
                OutlinedButton,
                'Case ${int.parse(correct.id.split('-').last) + 1}',
              )
            : find.widgetWithText(OutlinedButton, correct.label);
        if (type == CognitiveTestType.spatialOrientation) {
          expect(
            find.byWidgetPredicate(
              (widget) =>
                  widget is Icon &&
                  widget.icon == Icons.arrow_upward_rounded &&
                  widget.size == 34,
            ),
            findsNWidgets(12),
          );
          expect(find.text(correct.label), findsNothing);
        }
        await tester.ensureVisible(correctButton);
        await tester.tap(correctButton);
        await tester.pumpAndSettle();
      }

      expect(find.text('Session terminée'), findsOneWidget);
      expect(find.text('100 %'), findsOneWidget);
      await tester.pumpWidget(const SizedBox());
    });

    testWidgets('${type.name}: a wrong answer is scored as incorrect', (
      tester,
    ) async {
      await pumpTimedTest(tester, type, 12);
      final expected = TimedExerciseGenerator(
        random: Random(12),
        exerciseCount: 6,
      ).generate(type);

      for (final exercise in expected) {
        await tester.tap(find.text('Afficher la question'));
        await tester.pumpAndSettle();
        final wrong = exercise.options.firstWhere(
          (o) => o.id != exercise.correctOptionId,
        );
        final wrongButton = type == CognitiveTestType.spatialOrientation
            ? find.widgetWithText(
                OutlinedButton,
                'Case ${int.parse(wrong.id.split('-').last) + 1}',
              )
            : find.widgetWithText(OutlinedButton, wrong.label);
        await tester.ensureVisible(wrongButton);
        await tester.tap(wrongButton);
        await tester.pumpAndSettle();
      }

      expect(find.text('Session terminée'), findsOneWidget);
      expect(find.text('0 %'), findsOneWidget);
      await tester.pumpWidget(const SizedBox());
    });
  }

  testWidgets('shows the settings prompt when no time limit is defined', (
    tester,
  ) async {
    SharedPreferences.setMockInitialValues({});
    await tester.pumpWidget(
      const MaterialApp(
        home: TimedTestPage(testType: CognitiveTestType.reasoning),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Ouvrir les paramètres'), findsOneWidget);
  });
}
