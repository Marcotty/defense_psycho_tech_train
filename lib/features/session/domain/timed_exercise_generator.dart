import 'dart:math';

import '../../../app/models/cognitive_test_type.dart';
import '../../error_detection/domain/error_detection_exercise_generator.dart';
import '../../numerical_fluency/domain/numerical_exercise_generator.dart';
import '../../reasoning/domain/reasoning_exercise_generator.dart';
import '../../spatial_orientation/domain/spatial_exercise.dart';
import '../../spatial_orientation/domain/spatial_exercise_generator.dart';
import '../../word_memory/domain/word_memory_exercise_generator.dart';
import 'session_exercise.dart';

/// Produit les exercices inédits du mode chronométré (jamais ceux du livret).
class TimedExerciseGenerator {
  TimedExerciseGenerator({Random? random, this.exerciseCount = 40})
    : _random = random ?? Random() {
    if (exerciseCount <= 0) {
      throw ArgumentError.value(exerciseCount, 'exerciseCount', 'Must be > 0.');
    }
  }

  final int exerciseCount;
  final Random _random;

  List<SpatialExercise> generateSpatialExercises() =>
      SpatialExerciseGenerator(random: _random).generate(exerciseCount);

  List<SessionExercise> generate(CognitiveTestType type) {
    final exercises = switch (type) {
      CognitiveTestType.numericalFluency => NumericalExerciseGenerator(
        random: _random,
      ).generate(exerciseCount).map((exercise) => exercise.toSessionExercise()),
      CognitiveTestType.spatialOrientation => generateSpatialExercises().map(
        (exercise) => exercise.toSessionExercise(),
      ),
      CognitiveTestType.wordMemory => WordMemoryExerciseGenerator(
        random: _random,
      ).generate(exerciseCount).map((exercise) => exercise.toSessionExercise()),
      CognitiveTestType.reasoning => ReasoningExerciseGenerator(
        random: _random,
      ).generate(exerciseCount).map((exercise) => exercise.toSessionExercise()),
      CognitiveTestType.errorDetection => ErrorDetectionExerciseGenerator(
        random: _random,
      ).generate(exerciseCount).map((exercise) => exercise.toSessionExercise()),
    };
    return List.unmodifiable(exercises);
  }
}
