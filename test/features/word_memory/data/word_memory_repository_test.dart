import 'package:flutter_test/flutter_test.dart';
import 'package:defense_psycho_tech_train/features/word_memory/data/word_memory_repository.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test(
    'loads the booklet exercises and derives their matching counts',
    () async {
      const repository = WordMemoryRepository();

      final exercises = await repository.loadExercises();

      expect(exercises, hasLength(8));
      expect(exercises.map((exercise) => exercise.matchingCount).toList(), [
        2,
        1,
        2,
        2,
        0,
        1,
        1,
        3,
      ]);
      expect(
        exercises.map(
          (exercise) => exercise.toSessionExercise().correctOptionId,
        ),
        ['2', '1', '2', '2', '0', '1', '1', '3'],
      );
    },
  );
}
