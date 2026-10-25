import 'dart:convert';

import 'package:flutter/services.dart';

import '../domain/arithmetic_operation.dart';
import '../domain/numerical_exercise.dart';

class NumericalExerciseRepository {
  const NumericalExerciseRepository({
    AssetBundle? assetBundle,
    this.assetPath = 'assets/exercises/numerical_fluency.json',
  }) : _assetBundle = assetBundle;

  final AssetBundle? _assetBundle;
  final String assetPath;

  Future<List<NumericalExercise>> loadExercises() async {
    final source = await (_assetBundle ?? rootBundle).loadString(assetPath);
    final Object? decoded;
    try {
      decoded = jsonDecode(source);
    } on FormatException catch (error) {
      throw FormatException(
        'Invalid numerical exercise JSON in "$assetPath": ${error.message}',
      );
    }

    if (decoded is! List<Object?>) {
      throw FormatException(
        'Expected a JSON list of exercises in "$assetPath".',
      );
    }

    final exercises = <NumericalExercise>[];
    for (var index = 0; index < decoded.length; index++) {
      final value = decoded[index];
      if (value is! Map<String, Object?>) {
        throw FormatException(
          'Exercise at index $index in "$assetPath" must be an object.',
        );
      }
      exercises.add(_parseExercise(value, index));
    }
    if (exercises.isEmpty) {
      throw FormatException('No exercises found in "$assetPath".');
    }

    return List.unmodifiable(exercises);
  }

  NumericalExercise _parseExercise(Map<String, Object?> value, int index) {
    final id = value['id'];
    if (id is! String || id.trim().isEmpty) {
      throw FormatException(
        'Exercise at index $index must have a non-empty id.',
      );
    }

    final first = _parseOperation(value['first'], 'first', index);
    final second = _parseOperation(value['second'], 'second', index);
    return NumericalExercise(
      id: id,
      firstOperation: first,
      secondOperation: second,
    );
  }

  ArithmeticOperation _parseOperation(
    Object? value,
    String field,
    int exerciseIndex,
  ) {
    if (value is! Map<String, Object?>) {
      throw FormatException(
        'The "$field" operation for exercise $exerciseIndex must be an object.',
      );
    }

    final left = value['left'];
    final operatorValue = value['operator'];
    final right = value['right'];
    if (left is! int || operatorValue is! String || right is! int) {
      throw FormatException(
        'The "$field" operation for exercise $exerciseIndex must contain '
        'integer left/right values and a string operator.',
      );
    }

    final operator = switch (operatorValue) {
      '+' => ArithmeticOperator.addition,
      '-' => ArithmeticOperator.subtraction,
      '*' => ArithmeticOperator.multiplication,
      '/' => ArithmeticOperator.division,
      _ => throw FormatException(
        'Unsupported operator "$operatorValue" in exercise $exerciseIndex.',
      ),
    };

    if (operator == ArithmeticOperator.division &&
        (right == 0 || left % right != 0)) {
      throw FormatException(
        'Division in exercise $exerciseIndex must have a non-zero divisor '
        'and an integer result.',
      );
    }

    return ArithmeticOperation(left: left, operator: operator, right: right);
  }
}
