import 'dart:math';

import 'package:defense_psycho_tech_train/features/word_memory/domain/word_memory_exercise.dart';
import 'package:defense_psycho_tech_train/features/word_memory/domain/word_memory_exercise_generator.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('every category has at least three known words', () {
    for (final category in WordCategory.values) {
      expect(wordsForCategory(category).length, greaterThanOrEqualTo(3));
    }
  });

  test('each exercise has three categories and three distinct known words', () {
    for (var seed = 0; seed < 200; seed++) {
      final exercises = WordMemoryExerciseGenerator(
        random: Random(seed),
      ).generate(20);
      for (final exercise in exercises) {
        expect(exercise.categories, hasLength(3));
        expect(exercise.words, hasLength(3));
        expect(exercise.words.toSet(), hasLength(3));
        for (final word in exercise.words) {
          expect(categoryForWord(word), isNotNull);
        }
      }
    }
  });

  test('matching count is exactly the requested target', () {
    final generator = WordMemoryExerciseGenerator(random: Random(1));
    for (var target = 0; target <= 3; target++) {
      for (var i = 0; i < 200; i++) {
        final exercise = generator.generateOne('t-$i', target);
        expect(exercise.matchingCount, target);
      }
    }
  });

  test('rejects a target outside 0..3', () {
    final generator = WordMemoryExerciseGenerator(random: Random(1));
    expect(() => generator.generateOne('x', 4), throwsRangeError);
    expect(() => generator.generateOne('x', -1), throwsRangeError);
  });

  test('batch is balanced over 0, 1, 2 and 3 matches', () {
    final exercises = WordMemoryExerciseGenerator(
      random: Random(2),
    ).generate(40);
    for (var target = 0; target <= 3; target++) {
      expect(exercises.where((e) => e.matchingCount == target), hasLength(10));
    }
  });

  test('session exercise answer equals the real number of matches', () {
    final exercises = WordMemoryExerciseGenerator(
      random: Random(3),
    ).generate(80);
    for (final exercise in exercises) {
      final session = exercise.toSessionExercise();
      var expected = 0;
      for (var i = 0; i < 3; i++) {
        if (categoryForWord(exercise.words[i]) == exercise.categories[i]) {
          expected++;
        }
      }
      expect(session.correctOptionId, '$expected');
      expect(session.options.map((o) => o.id), ['0', '1', '2', '3']);
      expect(session.id, startsWith('timed-'));
    }
  });
}
