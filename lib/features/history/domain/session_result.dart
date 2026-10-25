import '../../../app/models/training_mode.dart';

class SessionResult {
  const SessionResult({
    required this.testTitle,
    required this.mode,
    required this.startedAt,
    required this.elapsed,
    required this.correctCount,
    required this.questionCount,
    required this.timeLimit,
  });

  final String testTitle;
  final TrainingMode mode;
  final DateTime startedAt;
  final Duration elapsed;
  final int correctCount;
  final int questionCount;
  final Duration? timeLimit;

  double get accuracy => questionCount == 0 ? 0 : correctCount / questionCount;

  bool? get passed {
    if (mode != TrainingMode.timedTest) return null;
    final limit = timeLimit;
    return limit != null && accuracy >= 0.95 && elapsed <= limit;
  }
}
