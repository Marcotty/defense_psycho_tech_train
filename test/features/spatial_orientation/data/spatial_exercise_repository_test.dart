import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:defense_psycho_tech_train/features/spatial_orientation/data/spatial_exercise_repository.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('loads six exercises with one correct tile in each grid', () async {
    const repository = SpatialExerciseRepository();

    final exercises = await repository.loadExercises();

    expect(exercises, hasLength(6));
    expect(exercises.map((exercise) => exercise.correctTileIndex), [
      3,
      4,
      5,
      5,
      3,
      2,
    ]);
    for (final exercise in exercises) {
      expect(exercise.tiles, hasLength(6));
      expect(exercise.matchingTileIndexes, [exercise.correctTileIndex]);
    }
  });

  test('reports a missing data asset with its path', () async {
    const repository = SpatialExerciseRepository(
      assetPath: 'assets/exercises/not_found.json',
    );

    await expectLater(
      repository.loadExercises(),
      throwsA(
        isA<FlutterError>().having(
          (error) => error.message,
          'message',
          contains('assets/exercises/not_found.json'),
        ),
      ),
    );
  });
}
