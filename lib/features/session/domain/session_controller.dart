import '../../../app/models/training_mode.dart';
import 'recorded_answer.dart';
import 'session_exercise.dart';
import 'session_phase.dart';

class SessionController {
  SessionController({
    required this.mode,
    required List<SessionExercise> exercises,
  }) : _exercises = List.unmodifiable(exercises) {
    if (_exercises.isEmpty) {
      throw ArgumentError.value(exercises, 'exercises', 'Must not be empty.');
    }

    final ids = <String>{};
    for (final exercise in _exercises) {
      if (!ids.add(exercise.id)) {
        throw ArgumentError.value(
          exercise.id,
          'exercises',
          'Exercise IDs must be unique.',
        );
      }
      if (exercise.options.isEmpty ||
          exercise.options.map((option) => option.id).toSet().length !=
              exercise.options.length ||
          !exercise.options.any(
            (option) => option.id == exercise.correctOptionId,
          )) {
        throw ArgumentError.value(
          exercise,
          'exercises',
          'Each exercise must have unique options and a valid correct option.',
        );
      }
    }
  }

  final TrainingMode mode;
  final List<SessionExercise> _exercises;
  final List<RecordedAnswer> _answers = [];

  SessionPhase _phase = SessionPhase.memorization;
  int _currentIndex = 0;

  SessionPhase get phase => _phase;
  int get currentIndex => _currentIndex;
  int get questionCount => _exercises.length;
  SessionExercise get currentExercise => _exercises[_currentIndex];
  List<RecordedAnswer> get answers => List.unmodifiable(_answers);

  int get correctCount => _answers.where((answer) => answer.isCorrect).length;

  double get accuracy => _answers.isEmpty
      ? 0
      : correctCount /
            (mode == TrainingMode.timedTest ? questionCount : _answers.length);

  Duration get totalResponseTime => _answers.fold(
    Duration.zero,
    (total, answer) => total + answer.responseTime,
  );

  void showQuestion() {
    _expectPhase(SessionPhase.memorization);
    _phase = SessionPhase.answering;
  }

  RecordedAnswer submitAnswer({
    required String optionId,
    required Duration responseTime,
  }) {
    _expectPhase(SessionPhase.answering);
    if (responseTime.isNegative) {
      throw ArgumentError.value(
        responseTime,
        'responseTime',
        'Must not be negative.',
      );
    }
    if (!currentExercise.options.any((option) => option.id == optionId)) {
      throw ArgumentError.value(optionId, 'optionId', 'Unknown answer option.');
    }

    final answer = RecordedAnswer(
      exerciseId: currentExercise.id,
      selectedOptionId: optionId,
      isCorrect: optionId == currentExercise.correctOptionId,
      responseTime: responseTime,
    );
    _answers.add(answer);

    if (mode == TrainingMode.practice) {
      _phase = SessionPhase.feedback;
    } else {
      _advanceOrComplete();
    }
    return answer;
  }

  void continueAfterFeedback() {
    _expectPhase(SessionPhase.feedback);
    _advanceOrComplete();
  }

  void endTimedSession() {
    if (mode != TrainingMode.timedTest) {
      throw StateError('Only timed sessions can end when their timer expires.');
    }
    if (_phase == SessionPhase.completed) return;
    _phase = SessionPhase.completed;
  }

  void _advanceOrComplete() {
    if (_currentIndex + 1 == _exercises.length) {
      _phase = SessionPhase.completed;
      return;
    }
    _currentIndex++;
    _phase = SessionPhase.memorization;
  }

  void _expectPhase(SessionPhase expected) {
    if (_phase != expected) {
      throw StateError('Expected $expected but session is in $_phase.');
    }
  }
}
