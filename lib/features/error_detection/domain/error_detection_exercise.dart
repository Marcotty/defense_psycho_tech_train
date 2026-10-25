import '../../session/domain/session_exercise.dart';

class ErrorDetectionExercise {
  const ErrorDetectionExercise({
    required this.id,
    required this.original,
    required this.copy,
  }) : assert(original.length == copy.length);

  final String id;
  final String original;
  final String copy;

  int get differenceCount {
    if (original.length != copy.length) {
      throw StateError('The strings in "$id" must have the same length.');
    }
    var differences = 0;
    for (var index = 0; index < original.length; index++) {
      if (original[index] != copy[index]) differences++;
    }
    return differences;
  }

  SessionExercise toSessionExercise() {
    return SessionExercise(
      id: id,
      memorizationContent: original,
      prompt: 'Combien de différences y a-t-il dans la copie ?\n$copy',
      options: const [
        SessionAnswerOption(id: '0', label: '0'),
        SessionAnswerOption(id: '1', label: '1'),
        SessionAnswerOption(id: '2', label: '2'),
        SessionAnswerOption(id: '3', label: '3'),
        SessionAnswerOption(id: '4', label: '4'),
      ],
      correctOptionId: '$differenceCount',
      explanation:
          '$differenceCount différence${differenceCount > 1 ? 's' : ''} '
          'en comparant chaque caractère à la même position.',
    );
  }
}
