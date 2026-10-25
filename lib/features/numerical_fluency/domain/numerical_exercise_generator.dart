import 'dart:math';

import 'arithmetic_operation.dart';
import 'numerical_exercise.dart';

/// Génère des exercices d'aisance numérique inédits.
///
/// Règles : opérandes entiers positifs, soustraction à résultat positif,
/// division exacte, multiplication des tables jusqu'à 12, résultats compris
/// entre [minResult] et [maxResult], deux opérations différentes.
class NumericalExerciseGenerator {
  NumericalExerciseGenerator({Random? random}) : _random = random ?? Random();

  static const minResult = 2;
  static const maxResult = 144;
  static const maxAddend = 50;
  static const maxSubtractionLeft = 99;
  static const minFactor = 2;
  static const maxFactor = 12;

  final Random _random;

  List<NumericalExercise> generate(int count, {String idPrefix = 'timed-num'}) {
    final targets = _balancedTargets(count);
    return [
      for (var index = 0; index < count; index++)
        generateOne('$idPrefix-${index + 1}', targets[index]),
    ];
  }

  NumericalExercise generateOne(String id, ResultComparison target) {
    for (var attempt = 0; attempt < 10000; attempt++) {
      final first = _randomOperation();
      final ArithmeticOperation second;
      if (target == ResultComparison.equal) {
        final built = _operationWithResult(first.result);
        if (built == null) continue;
        second = built;
      } else {
        second = _randomOperation();
      }
      if (first.expression == second.expression) continue;
      final exercise = NumericalExercise(
        id: id,
        firstOperation: first,
        secondOperation: second,
      );
      if (exercise.comparison == target) return exercise;
    }
    throw StateError('Unable to generate a numerical exercise for $target.');
  }

  List<ResultComparison> _balancedTargets(int count) {
    // Environ 20 % d'égalités, le reste réparti entre « haut » et « bas ».
    final targets = <ResultComparison>[
      for (var index = 0; index < count; index++)
        switch (index % 5) {
          0 || 3 => ResultComparison.firstGreater,
          1 || 4 => ResultComparison.secondGreater,
          _ => ResultComparison.equal,
        },
    ]..shuffle(_random);
    return targets;
  }

  ArithmeticOperation _randomOperation() {
    while (true) {
      final operation = _operation(
        ArithmeticOperator.values[_random.nextInt(4)],
      );
      if (_isValid(operation)) return operation;
    }
  }

  ArithmeticOperation _operation(ArithmeticOperator operator) {
    switch (operator) {
      case ArithmeticOperator.addition:
        return ArithmeticOperation(
          left: _between(1, maxAddend),
          operator: operator,
          right: _between(1, maxAddend),
        );
      case ArithmeticOperator.subtraction:
        final left = _between(3, maxSubtractionLeft);
        return ArithmeticOperation(
          left: left,
          operator: operator,
          right: _between(1, left - 1),
        );
      case ArithmeticOperator.multiplication:
        return ArithmeticOperation(
          left: _between(minFactor, maxFactor),
          operator: operator,
          right: _between(minFactor, maxFactor),
        );
      case ArithmeticOperator.division:
        final divisor = _between(minFactor, maxFactor);
        return ArithmeticOperation(
          left: divisor * _between(minFactor, maxFactor),
          operator: operator,
          right: divisor,
        );
    }
  }

  ArithmeticOperation? _operationWithResult(int result) {
    final operator = ArithmeticOperator.values[_random.nextInt(4)];
    final ArithmeticOperation? operation = switch (operator) {
      ArithmeticOperator.addition when result >= 2 && result - 1 <= 98 =>
        _additionWithResult(result),
      ArithmeticOperator.subtraction => _subtractionWithResult(result),
      ArithmeticOperator.multiplication => _multiplicationWithResult(result),
      ArithmeticOperator.division => _divisionWithResult(result),
      _ => null,
    };
    return operation != null && _isValid(operation) ? operation : null;
  }

  ArithmeticOperation? _additionWithResult(int result) {
    final left = _between(1, result - 1);
    final right = result - left;
    if (left > maxAddend || right > maxAddend) return null;
    return ArithmeticOperation(
      left: left,
      operator: ArithmeticOperator.addition,
      right: right,
    );
  }

  ArithmeticOperation? _subtractionWithResult(int result) {
    final right = _between(1, 50);
    final left = result + right;
    if (left > maxSubtractionLeft) return null;
    return ArithmeticOperation(
      left: left,
      operator: ArithmeticOperator.subtraction,
      right: right,
    );
  }

  ArithmeticOperation? _multiplicationWithResult(int result) {
    final factors = [
      for (var factor = minFactor; factor <= maxFactor; factor++)
        if (result % factor == 0 &&
            result ~/ factor >= minFactor &&
            result ~/ factor <= maxFactor)
          factor,
    ];
    if (factors.isEmpty) return null;
    final left = factors[_random.nextInt(factors.length)];
    return ArithmeticOperation(
      left: left,
      operator: ArithmeticOperator.multiplication,
      right: result ~/ left,
    );
  }

  ArithmeticOperation? _divisionWithResult(int result) {
    if (result < minFactor || result > maxFactor) return null;
    final divisor = _between(minFactor, maxFactor);
    return ArithmeticOperation(
      left: result * divisor,
      operator: ArithmeticOperator.division,
      right: divisor,
    );
  }

  bool _isValid(ArithmeticOperation operation) =>
      operation.result >= minResult && operation.result <= maxResult;

  int _between(int min, int max) => min + _random.nextInt(max - min + 1);
}
