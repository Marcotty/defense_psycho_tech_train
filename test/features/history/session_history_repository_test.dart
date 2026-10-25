import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:defense_psycho_tech_train/app/models/training_mode.dart';
import 'package:defense_psycho_tech_train/features/history/data/session_history_repository.dart';
import 'package:defense_psycho_tech_train/features/history/domain/session_result.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUp(() => SharedPreferences.setMockInitialValues({}));

  test('persists and reloads session results', () async {
    const repository = SessionHistoryRepository();
    final startedAt = DateTime.utc(2026, 10, 25, 12);
    final result = SessionResult(
      testTitle: 'Aisance numérique',
      mode: TrainingMode.timedTest,
      startedAt: startedAt,
      elapsed: const Duration(minutes: 2),
      correctCount: 3,
      questionCount: 3,
      timeLimit: const Duration(minutes: 3),
    );

    await repository.saveSession(result);
    final sessions = await repository.loadSessions();

    expect(sessions, hasLength(1));
    expect(sessions.single.testTitle, result.testTitle);
    expect(sessions.single.mode, TrainingMode.timedTest);
    expect(sessions.single.startedAt, startedAt);
    expect(sessions.single.accuracy, 1);
    expect(sessions.single.passed, isTrue);
    expect(sessions.single.timeLimit, result.timeLimit);
  });

  test('timed result requires both accuracy and time targets', () {
    final result = SessionResult(
      testTitle: 'Raisonnement',
      mode: TrainingMode.timedTest,
      startedAt: DateTime.utc(2026),
      elapsed: const Duration(seconds: 91),
      correctCount: 7,
      questionCount: 8,
      timeLimit: const Duration(seconds: 90),
    );

    expect(result.accuracy, lessThan(0.95));
    expect(result.passed, isFalse);
  });

  test('a timed result passes at 95 percent when within its time limit', () {
    final result = SessionResult(
      testTitle: 'Mémoire des mots',
      mode: TrainingMode.timedTest,
      startedAt: DateTime.utc(2026),
      elapsed: const Duration(minutes: 3),
      correctCount: 19,
      questionCount: 20,
      timeLimit: const Duration(minutes: 3),
    );

    expect(result.passed, isTrue);
  });
}
