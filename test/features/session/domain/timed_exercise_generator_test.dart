import 'dart:math';

import 'package:defense_psycho_tech_train/app/models/cognitive_test_type.dart';
import 'package:defense_psycho_tech_train/features/session/domain/timed_exercise_generator.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('generates the requested number of valid exercises for every type', () {
    for (final type in CognitiveTestType.values) {
      final exercises = TimedExerciseGenerator(
        random: Random(1),
        exerciseCount: 25,
      ).generate(type);

      expect(exercises, hasLength(25), reason: type.name);
      expect(exercises.map((e) => e.id).toSet(), hasLength(25));
      for (final exercise in exercises) {
        expect(exercise.id, startsWith('timed-'));
        expect(
          exercise.options.map((o) => o.id).toSet(),
          hasLength(exercise.options.length),
        );
        expect(
          exercise.options.map((o) => o.id),
          contains(exercise.correctOptionId),
        );
        expect(exercise.memorizationContent, isNotEmpty);
        expect(exercise.prompt, isNotEmpty);
        expect(exercise.explanation, isNotEmpty);
      }
    }
  });

  test('result is immutable and differs between seeds', () {
    final a = TimedExerciseGenerator(
      random: Random(1),
    ).generate(CognitiveTestType.errorDetection);
    final b = TimedExerciseGenerator(
      random: Random(2),
    ).generate(CognitiveTestType.errorDetection);
    expect(() => a.add(a.first), throwsUnsupportedError);
    expect(
      a.map((e) => e.memorizationContent).toList(),
      isNot(b.map((e) => e.memorizationContent).toList()),
    );
  });

  test('rejects a non-positive exercise count', () {
    expect(() => TimedExerciseGenerator(exerciseCount: 0), throwsArgumentError);
  });
}
