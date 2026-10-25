import 'package:flutter_test/flutter_test.dart';
import 'package:defense_psycho_tech_train/features/error_detection/data/error_detection_repository.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test(
    'loads booklet pairs and counts differences by character position',
    () async {
      const repository = ErrorDetectionRepository();

      final exercises = await repository.loadExercises();

      expect(exercises, hasLength(8));
      expect(exercises.map((exercise) => exercise.differenceCount).toList(), [
        3,
        2,
        3,
        0,
        4,
        4,
        2,
        2,
      ]);
      expect(
        exercises.map(
          (exercise) => exercise.toSessionExercise().correctOptionId,
        ),
        ['3', '2', '3', '0', '4', '4', '2', '2'],
      );
    },
  );
}
