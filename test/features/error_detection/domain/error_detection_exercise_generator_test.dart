import 'dart:math';

import 'package:defense_psycho_tech_train/features/error_detection/domain/error_detection_exercise_generator.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  bool isDigit(String c) => RegExp(r'^[0-9]$').hasMatch(c);
  bool isLower(String c) => RegExp(r'^[a-z]$').hasMatch(c);
  bool isUpper(String c) => RegExp(r'^[A-Z]$').hasMatch(c);

  test('copy has the same length and between 0 and 4 differences', () {
    for (var seed = 0; seed < 200; seed++) {
      final exercises = ErrorDetectionExerciseGenerator(
        random: Random(seed),
      ).generate(25);
      for (final exercise in exercises) {
        expect(exercise.copy.length, exercise.original.length);
        expect(exercise.differenceCount, inInclusiveRange(0, 4));
      }
    }
  });

  test('difference count is exactly the requested target', () {
    final generator = ErrorDetectionExerciseGenerator(random: Random(1));
    for (var target = 0; target <= 4; target++) {
      for (var i = 0; i < 300; i++) {
        expect(generator.generateOne('t-$i', target).differenceCount, target);
      }
    }
  });

  test('rejects targets above four or below zero', () {
    final generator = ErrorDetectionExerciseGenerator(random: Random(1));
    expect(() => generator.generateOne('x', 5), throwsRangeError);
    expect(() => generator.generateOne('x', -1), throwsRangeError);
  });

  test('separators never change and character classes are preserved', () {
    final generator = ErrorDetectionExerciseGenerator(random: Random(2));
    for (var i = 0; i < 500; i++) {
      final exercise = generator.generateOne('t-$i', 4);
      for (var index = 0; index < exercise.original.length; index++) {
        final o = exercise.original[index];
        final c = exercise.copy[index];
        if (isDigit(o)) {
          expect(isDigit(c), isTrue);
        } else if (isLower(o)) {
          expect(isLower(c), isTrue);
        } else if (isUpper(o)) {
          expect(isUpper(c), isTrue);
        } else {
          expect(c, o);
        }
      }
    }
  });

  test('originals look like the booklet formats', () {
    final exercises = ErrorDetectionExerciseGenerator(
      random: Random(3),
    ).generate(300);
    final formats = [
      RegExp(r'^[a-z]{3}\d{3}@[a-z]{3}\.com$'),
      RegExp(r'^[a-z]{5,8}@[a-z]{4,6}\.(com|net|org|fr)$'),
      RegExp(r'^http://www\.[a-z]{6}\.(com|net|org|fr)$'),
      RegExp(r'^[A-Z]{2} \d{5}$'),
      RegExp(r'^[A-Z] \d{3} [A-Z]{3}$'),
    ];
    for (final exercise in exercises) {
      expect(
        formats.any((f) => f.hasMatch(exercise.original)),
        isTrue,
        reason: exercise.original,
      );
    }
    for (final format in formats) {
      expect(exercises.any((e) => format.hasMatch(e.original)), isTrue);
    }
  });

  test('batch is balanced over 0 to 4 differences', () {
    final exercises = ErrorDetectionExerciseGenerator(
      random: Random(4),
    ).generate(50);
    for (var target = 0; target <= 4; target++) {
      expect(
        exercises.where((e) => e.differenceCount == target),
        hasLength(10),
      );
    }
  });

  test('session exercise answer equals the real difference count', () {
    final exercises = ErrorDetectionExerciseGenerator(
      random: Random(5),
    ).generate(100);
    for (final exercise in exercises) {
      final session = exercise.toSessionExercise();
      var expected = 0;
      for (var i = 0; i < exercise.original.length; i++) {
        if (exercise.original[i] != exercise.copy[i]) expected++;
      }
      expect(session.correctOptionId, '$expected');
      expect(session.options.map((o) => o.id), ['0', '1', '2', '3', '4']);
      expect(session.memorizationContent, exercise.original);
      expect(session.prompt, contains(exercise.copy));
      expect(session.id, startsWith('timed-'));
    }
  });
}
