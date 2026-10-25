import 'dart:math';

import 'package:defense_psycho_tech_train/features/numerical_fluency/domain/arithmetic_operation.dart';
import 'package:defense_psycho_tech_train/features/numerical_fluency/domain/numerical_exercise.dart';
import 'package:defense_psycho_tech_train/features/numerical_fluency/domain/numerical_exercise_generator.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  void expectOperationRules(ArithmeticOperation op) {
    expect(op.left, greaterThan(0));
    expect(op.right, greaterThan(0));
    expect(op.result, inInclusiveRange(2, 144));
    switch (op.operator) {
      case ArithmeticOperator.addition:
        expect(op.left, lessThanOrEqualTo(50));
        expect(op.right, lessThanOrEqualTo(50));
      case ArithmeticOperator.subtraction:
        expect(op.left, greaterThan(op.right));
        expect(op.left, lessThanOrEqualTo(99));
      case ArithmeticOperator.multiplication:
        expect(op.left, inInclusiveRange(2, 12));
        expect(op.right, inInclusiveRange(2, 12));
      case ArithmeticOperator.division:
        expect(op.left % op.right, 0);
        expect(op.right, inInclusiveRange(2, 12));
        expect(op.result, inInclusiveRange(2, 12));
    }
  }

  test('respects every operation rule over many seeds', () {
    for (var seed = 0; seed < 100; seed++) {
      final exercises = NumericalExerciseGenerator(
        random: Random(seed),
      ).generate(30);
      for (final exercise in exercises) {
        expectOperationRules(exercise.firstOperation);
        expectOperationRules(exercise.secondOperation);
        expect(
          exercise.firstOperation.expression,
          isNot(exercise.secondOperation.expression),
        );
      }
    }
  });

  test('uses all four operators and all three outcomes', () {
    final exercises = NumericalExerciseGenerator(
      random: Random(1),
    ).generate(100);
    final operators = {
      for (final e in exercises) ...[
        e.firstOperation.operator,
        e.secondOperation.operator,
      ],
    };
    expect(operators, ArithmeticOperator.values.toSet());
    expect(
      exercises.map((e) => e.comparison).toSet(),
      ResultComparison.values.toSet(),
    );
  });

  test('produces a balanced share of equalities, highs and lows', () {
    final exercises = NumericalExerciseGenerator(
      random: Random(2),
    ).generate(100);
    int count(ResultComparison c) =>
        exercises.where((e) => e.comparison == c).length;
    expect(count(ResultComparison.equal), 20);
    expect(count(ResultComparison.firstGreater), 40);
    expect(count(ResultComparison.secondGreater), 40);
  });

  test('session exercise carries the correct answer and explanation', () {
    final exercises = NumericalExerciseGenerator(
      random: Random(3),
    ).generate(60);
    for (final exercise in exercises) {
      final session = exercise.toSessionExercise();
      final expected = switch (exercise.comparison) {
        ResultComparison.firstGreater => 'haut',
        ResultComparison.secondGreater => 'bas',
        ResultComparison.equal => 'egal',
      };
      expect(session.correctOptionId, expected);
      expect(session.options.map((o) => o.id), ['haut', 'bas', 'egal']);
      expect(session.memorizationContent, exercise.firstOperation.expression);
      expect(
        session.explanation,
        contains('${exercise.firstOperation.result}'),
      );
    }
  });

  test('generates unique ids and is reproducible for a given seed', () {
    final a = NumericalExerciseGenerator(random: Random(9)).generate(20);
    final b = NumericalExerciseGenerator(random: Random(9)).generate(20);
    expect(a.map((e) => e.id).toSet().length, 20);
    expect(a.every((e) => e.id.startsWith('timed-')), isTrue);
    expect(
      a.map((e) => e.firstOperation.expression),
      b.map((e) => e.firstOperation.expression),
    );
  });
}
