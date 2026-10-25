import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:defense_psycho_tech_train/app/app.dart';
import 'package:defense_psycho_tech_train/features/error_detection/data/error_detection_repository.dart';
import 'package:defense_psycho_tech_train/features/reasoning/data/reasoning_repository.dart';
import 'package:defense_psycho_tech_train/features/session/domain/session_exercise.dart';
import 'package:defense_psycho_tech_train/features/word_memory/data/word_memory_repository.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUp(() => SharedPreferences.setMockInitialValues({}));

  testWidgets('completes all eight word-memory practice exercises', (
    tester,
  ) async {
    const repository = WordMemoryRepository();
    final exercises = await repository.loadExercises();

    await _completePractice(
      tester,
      title: 'Mémoire des mots',
      exercises: exercises.map((exercise) => exercise.toSessionExercise()),
    );
  });

  testWidgets('completes all eight reasoning practice exercises', (
    tester,
  ) async {
    const repository = ReasoningRepository();
    final exercises = await repository.loadExercises();

    await _completePractice(
      tester,
      title: 'Raisonnement',
      exercises: exercises.map((exercise) => exercise.toSessionExercise()),
    );
  });

  testWidgets('completes all eight error-detection practice exercises', (
    tester,
  ) async {
    const repository = ErrorDetectionRepository();
    final exercises = await repository.loadExercises();

    await _completePractice(
      tester,
      title: 'Détection d’erreurs',
      exercises: exercises.map((exercise) => exercise.toSessionExercise()),
    );
  });
}

Future<void> _completePractice(
  WidgetTester tester, {
  required String title,
  required Iterable<SessionExercise> exercises,
}) async {
  final exerciseList = exercises.toList();
  await tester.pumpWidget(const BtcaApp());
  await tester.tap(find.text('Mode Entraînement'));
  await tester.pumpAndSettle();
  await tester.scrollUntilVisible(
    find.text(title),
    300,
    scrollable: find.byType(Scrollable).first,
  );
  await tester.tap(find.text(title));
  await tester.pumpAndSettle();
  await tester.tap(find.text('Commencer les exercices'));
  await tester.pumpAndSettle();

  for (var index = 0; index < exerciseList.length; index++) {
    final exercise = exerciseList[index];
    await tester.tap(find.text('Je suis prêt'));
    await tester.pumpAndSettle();
    final option = exercise.options.singleWhere(
      (option) => option.id == exercise.correctOptionId,
    );
    await tester.tap(find.widgetWithText(OutlinedButton, option.label).first);
    await tester.pumpAndSettle();
    expect(find.text('Bonne réponse'), findsOneWidget);

    final isLastExercise = index == exerciseList.length - 1;
    await tester.tap(
      find.text(isLastExercise ? 'Voir le bilan' : 'Question suivante'),
    );
    await tester.pumpAndSettle();
  }

  expect(find.text('Session terminée'), findsOneWidget);
  expect(find.text('100 %'), findsOneWidget);
}
