import '../../session/domain/session_exercise.dart';
import 'arithmetic_operation.dart';

enum ResultComparison { firstGreater, secondGreater, equal }

class NumericalExercise {
  const NumericalExercise({
    required this.id,
    required this.firstOperation,
    required this.secondOperation,
  });

  final String id;
  final ArithmeticOperation firstOperation;
  final ArithmeticOperation secondOperation;

  ResultComparison get comparison {
    if (firstOperation.result > secondOperation.result) {
      return ResultComparison.firstGreater;
    }
    if (firstOperation.result < secondOperation.result) {
      return ResultComparison.secondGreater;
    }
    return ResultComparison.equal;
  }

  SessionExercise toSessionExercise() {
    final correctOptionId = switch (comparison) {
      ResultComparison.firstGreater => 'haut',
      ResultComparison.secondGreater => 'bas',
      ResultComparison.equal => 'egal',
    };

    return SessionExercise(
      id: id,
      memorizationContent: firstOperation.expression,
      prompt:
          'Compare le résultat mémorisé avec :\n'
          '${secondOperation.expression}',
      options: const [
        SessionAnswerOption(id: 'haut', label: 'Haut'),
        SessionAnswerOption(id: 'bas', label: 'Bas'),
        SessionAnswerOption(id: 'egal', label: 'Égal'),
      ],
      correctOptionId: correctOptionId,
      explanation: _buildExplanation(),
    );
  }

  String _buildExplanation() {
    final firstResult = firstOperation.result;
    final secondResult = secondOperation.result;
    final conclusion = switch (comparison) {
      ResultComparison.firstGreater =>
        'Le résultat de la première opération est le plus grand.',
      ResultComparison.secondGreater =>
        'Le résultat de la seconde opération est le plus grand.',
      ResultComparison.equal => 'Les deux résultats sont égaux.',
    };

    return '${firstOperation.expression} = $firstResult ; '
        '${secondOperation.expression} = $secondResult. $conclusion';
  }
}
