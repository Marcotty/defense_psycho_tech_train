import 'package:flutter_test/flutter_test.dart';
import 'package:defense_psycho_tech_train/features/reasoning/data/reasoning_repository.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('loads the booklet exercises and derives their unique order', () async {
    const repository = ReasoningRepository();

    final exercises = await repository.loadExercises();

    expect(exercises, hasLength(8));
    expect(exercises.map((exercise) => exercise.correctEntity).toList(), [
      'Tram',
      'Camion',
      'Bois',
      'Pilote',
      'Église',
      'Rivière',
      'Régiment',
      'Casque',
    ]);
  });
}
