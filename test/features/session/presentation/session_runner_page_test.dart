import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:defense_psycho_tech_train/app/models/training_mode.dart';
import 'package:defense_psycho_tech_train/features/history/domain/session_result.dart';
import 'package:defense_psycho_tech_train/features/session/domain/session_exercise.dart';
import 'package:defense_psycho_tech_train/features/session/presentation/session_runner_page.dart';

void main() {
  testWidgets('practice reveals a question and shows feedback', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: SessionRunnerPage(
          title: 'Aisance numérique',
          mode: TrainingMode.practice,
          exercises: [_exercise],
        ),
      ),
    );

    expect(find.text('À mémoriser'), findsOneWidget);
    expect(find.text('Question de test'), findsNothing);

    await tester.tap(find.text('Je suis prêt'));
    await tester.pumpAndSettle();
    expect(find.text('Question de test'), findsOneWidget);

    await tester.tap(find.text('Bonne réponse'));
    await tester.pumpAndSettle();
    expect(find.text('Bonne réponse'), findsOneWidget);
    expect(find.text('Explication.'), findsOneWidget);

    await tester.tap(find.text('Voir le bilan'));
    await tester.pumpAndSettle();
    expect(find.text('Session terminée'), findsOneWidget);
    expect(find.text('100 %'), findsOneWidget);
  });

  testWidgets('timed test hides memorization after its configured duration', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: SessionRunnerPage(
          title: 'Aisance numérique',
          mode: TrainingMode.timedTest,
          testTimeLimit: const Duration(seconds: 5),
          memorizationDuration: const Duration(seconds: 2),
          exercises: [_exercise],
        ),
      ),
    );

    expect(find.text('À mémoriser'), findsOneWidget);
    await tester.pump(const Duration(seconds: 2));

    expect(find.text('À mémoriser'), findsNothing);
    expect(find.text('Question de test'), findsOneWidget);

    await tester.pump(const Duration(seconds: 1));
    await tester.tap(find.text('Mauvaise réponse'));
    await tester.pumpAndSettle();

    expect(find.text('Session terminée'), findsOneWidget);
    expect(find.text('Explication.'), findsNothing);
    expect(find.text('0 %'), findsOneWidget);
    expect(
      find.byWidgetPredicate(
        (widget) =>
            widget is Text &&
            RegExp(r'^\d+\.\d s$').hasMatch(widget.data ?? ''),
      ),
      findsNWidgets(2),
    );
  });

  testWidgets(
    'timed-out questions count as incorrect and fail the time target',
    (tester) async {
      SessionResult? savedResult;
      await tester.pumpWidget(
        MaterialApp(
          home: SessionRunnerPage(
            title: 'Aisance numérique',
            mode: TrainingMode.timedTest,
            testTimeLimit: const Duration(seconds: 2),
            exercises: [_exercise, _exercise.copyWithId('second')],
            onCompleted: (result) async {
              savedResult = result;
            },
          ),
        ),
      );

      await tester.tap(find.text('Afficher la question'));
      await tester.pump();
      await tester.tap(find.text('Bonne réponse'));
      await tester.pump();
      await tester.pump(const Duration(seconds: 2));

      expect(find.text('Session terminée'), findsOneWidget);
      expect(find.text('50 %'), findsOneWidget);
      expect(find.text('Objectif non atteint'), findsOneWidget);
      await tester.pump();
      expect(savedResult!.correctCount, 1);
      expect(savedResult!.questionCount, 2);
    },
  );
}

final _exercise = SessionExercise(
  id: 'sample',
  memorizationContent: 'À mémoriser',
  prompt: 'Question de test',
  options: const [
    SessionAnswerOption(id: 'correct', label: 'Bonne réponse'),
    SessionAnswerOption(id: 'wrong', label: 'Mauvaise réponse'),
  ],
  correctOptionId: 'correct',
  explanation: 'Explication.',
);

extension on SessionExercise {
  SessionExercise copyWithId(String id) => SessionExercise(
    id: id,
    memorizationContent: memorizationContent,
    prompt: prompt,
    options: options,
    correctOptionId: correctOptionId,
    explanation: explanation,
  );
}
