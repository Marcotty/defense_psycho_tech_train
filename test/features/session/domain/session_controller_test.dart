import 'package:flutter_test/flutter_test.dart';
import 'package:defense_psycho_tech_train/app/models/training_mode.dart';
import 'package:defense_psycho_tech_train/features/session/domain/session_controller.dart';
import 'package:defense_psycho_tech_train/features/session/domain/session_exercise.dart';
import 'package:defense_psycho_tech_train/features/session/domain/session_phase.dart';

void main() {
  group('SessionController', () {
    test('practice records an answer and waits for feedback continuation', () {
      final session = SessionController(
        mode: TrainingMode.practice,
        exercises: [_exercise('first'), _exercise('second')],
      );

      session.showQuestion();
      final answer = session.submitAnswer(
        optionId: 'correct',
        responseTime: const Duration(milliseconds: 850),
      );

      expect(answer.isCorrect, isTrue);
      expect(session.phase, SessionPhase.feedback);
      expect(session.currentIndex, 0);
      expect(session.accuracy, 1);
      expect(session.totalResponseTime, const Duration(milliseconds: 850));

      session.continueAfterFeedback();

      expect(session.phase, SessionPhase.memorization);
      expect(session.currentIndex, 1);
    });

    test('timed test advances immediately and completes without feedback', () {
      final session = SessionController(
        mode: TrainingMode.timedTest,
        exercises: [_exercise('first'), _exercise('second')],
      );

      session
        ..showQuestion()
        ..submitAnswer(
          optionId: 'wrong',
          responseTime: const Duration(seconds: 2),
        );

      expect(session.phase, SessionPhase.memorization);
      expect(session.currentIndex, 1);

      session
        ..showQuestion()
        ..submitAnswer(
          optionId: 'correct',
          responseTime: const Duration(seconds: 1),
        );

      expect(session.phase, SessionPhase.completed);
      expect(session.answers, hasLength(2));
      expect(session.correctCount, 1);
      expect(session.accuracy, 0.5);
      expect(session.totalResponseTime, const Duration(seconds: 3));
    });

    test('timed out unanswered exercises count against the final accuracy', () {
      final session = SessionController(
        mode: TrainingMode.timedTest,
        exercises: [_exercise('first'), _exercise('second')],
      )..endTimedSession();

      expect(session.phase, SessionPhase.completed);
      expect(session.answers, isEmpty);
      expect(session.accuracy, 0);
    });

    test('rejects empty or malformed exercise lists', () {
      expect(
        () => SessionController(mode: TrainingMode.practice, exercises: []),
        throwsArgumentError,
      );
      expect(
        () => SessionController(
          mode: TrainingMode.practice,
          exercises: [_exercise('same'), _exercise('same')],
        ),
        throwsArgumentError,
      );
      expect(
        () => SessionController(
          mode: TrainingMode.practice,
          exercises: [_exercise('invalid', correctOptionId: 'missing')],
        ),
        throwsArgumentError,
      );
    });

    test('rejects answers outside the active question options', () {
      final session = SessionController(
        mode: TrainingMode.practice,
        exercises: [_exercise('first')],
      )..showQuestion();

      expect(
        () => session.submitAnswer(
          optionId: 'unknown',
          responseTime: Duration.zero,
        ),
        throwsArgumentError,
      );
      expect(session.answers, isEmpty);
      expect(session.phase, SessionPhase.answering);
    });
  });
}

SessionExercise _exercise(String id, {String correctOptionId = 'correct'}) {
  return SessionExercise(
    id: id,
    memorizationContent: 'À mémoriser',
    prompt: 'Question de test',
    options: const [
      SessionAnswerOption(id: 'correct', label: 'Bonne réponse'),
      SessionAnswerOption(id: 'wrong', label: 'Mauvaise réponse'),
    ],
    correctOptionId: correctOptionId,
    explanation: 'Explication.',
  );
}
