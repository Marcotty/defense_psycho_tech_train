import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:defense_psycho_tech_train/features/numerical_fluency/data/numerical_exercise_repository.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test(
    'loads the three numeric examples and derives their correct answers',
    () async {
      const repository = NumericalExerciseRepository();

      final exercises = await repository.loadExercises();

      expect(exercises, hasLength(3));
      expect(exercises[0].firstOperation.result, 21);
      expect(exercises[0].secondOperation.result, 18);
      expect(exercises[0].toSessionExercise().correctOptionId, 'haut');
      expect(exercises[1].firstOperation.result, 33);
      expect(exercises[1].secondOperation.result, 35);
      expect(exercises[1].toSessionExercise().correctOptionId, 'bas');
      expect(exercises[2].firstOperation.result, 12);
      expect(exercises[2].secondOperation.result, 12);
      expect(exercises[2].toSessionExercise().correctOptionId, 'egal');
    },
  );

  test('reports invalid asset JSON with its asset path', () async {
    const repository = NumericalExerciseRepository(
      assetPath: 'assets/exercises/missing.json',
    );

    await expectLater(
      repository.loadExercises(),
      throwsA(
        isA<FlutterError>().having(
          (error) => error.message,
          'message',
          contains('assets/exercises/missing.json'),
        ),
      ),
    );
  });
}
