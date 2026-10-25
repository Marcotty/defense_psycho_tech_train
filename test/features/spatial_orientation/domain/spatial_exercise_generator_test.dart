import 'dart:math';

import 'package:defense_psycho_tech_train/features/spatial_orientation/domain/spatial_exercise.dart';
import 'package:defense_psycho_tech_train/features/spatial_orientation/domain/spatial_exercise_generator.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('every exercise has six distinct tiles and exactly one match', () {
    for (var seed = 0; seed < 200; seed++) {
      final exercises = SpatialExerciseGenerator(
        random: Random(seed),
      ).generate(20);
      for (final exercise in exercises) {
        expect(exercise.tiles, hasLength(6));
        expect(exercise.matchingTileIndexes, [exercise.correctTileIndex]);
        final keys = exercise.tiles.map(
          (t) =>
              '${t.above.color}${t.above.direction}'
              '${t.below.color}${t.below.direction}',
        );
        expect(keys.toSet(), hasLength(6));
      }
    }
  });

  test('every tile has one black and one yellow arrow', () {
    final exercises = SpatialExerciseGenerator(random: Random(4)).generate(100);
    for (final exercise in exercises) {
      for (final tile in exercise.tiles) {
        expect(tile.above.color, isNot(tile.below.color));
      }
    }
  });

  test('the correct tile satisfies both color and direction rules', () {
    final exercises = SpatialExerciseGenerator(random: Random(5)).generate(100);
    for (final exercise in exercises) {
      final tile = exercise.tiles[exercise.correctTileIndex];
      final rules = exercise.rules;
      expect(tile.above.color, rules.colorAbove);
      expect(tile.below.color, rules.colorBelow);
      expect(tile.above.direction, rules.directionAbove);
      expect(tile.below.direction, rules.directionBelow);
    }
  });

  test('wrong tiles each break at least one rule', () {
    final exercises = SpatialExerciseGenerator(random: Random(6)).generate(100);
    for (final exercise in exercises) {
      for (var i = 0; i < 6; i++) {
        if (i == exercise.correctTileIndex) continue;
        expect(exercise.rules.matches(exercise.tiles[i]), isFalse);
      }
    }
  });

  test('correct position and all rule values vary', () {
    final exercises = SpatialExerciseGenerator(random: Random(7)).generate(200);
    expect(exercises.map((e) => e.correctTileIndex).toSet(), {
      0,
      1,
      2,
      3,
      4,
      5,
    });
    expect(
      exercises.map((e) => e.rules.directionAbove).toSet(),
      ArrowDirection.values.toSet(),
    );
    expect(
      exercises.map((e) => e.rules.colorAbove).toSet(),
      ArrowColor.values.toSet(),
    );
  });

  test('session exercise exposes six options and the right answer', () {
    final exercises = SpatialExerciseGenerator(random: Random(8)).generate(50);
    for (final exercise in exercises) {
      final session = exercise.toSessionExercise();
      expect(session.options, hasLength(6));
      expect(
        session.correctOptionId,
        '${exercise.id}-case-${exercise.correctTileIndex}',
      );
      expect(
        session.options.map((o) => o.id),
        contains(session.correctOptionId),
      );
      expect(session.id, startsWith('timed-'));
    }
  });
}
