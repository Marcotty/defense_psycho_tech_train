import 'package:flutter_test/flutter_test.dart';
import 'package:defense_psycho_tech_train/features/numerical_fluency/domain/arithmetic_operation.dart';
import 'package:defense_psycho_tech_train/features/numerical_fluency/domain/numerical_exercise.dart';

void main() {
  group('ArithmeticOperation', () {
    test('calculates supported integer operations', () {
      expect(_operation(7, ArithmeticOperator.addition, 8).result, 15);
      expect(_operation(84, ArithmeticOperator.division, 2).result, 42);
      expect(_operation(50, ArithmeticOperator.subtraction, 7).result, 43);
      expect(_operation(5, ArithmeticOperator.multiplication, 9).result, 45);
    });
  });

  group('NumericalExercise', () {
    test('builds a higher answer and a calculation explanation', () {
      final exercise = NumericalExercise(
        id: 'higher',
        firstOperation: _operation(3, ArithmeticOperator.multiplication, 7),
        secondOperation: _operation(19, ArithmeticOperator.subtraction, 1),
      ).toSessionExercise();

      expect(exercise.memorizationContent, '3 × 7');
      expect(exercise.prompt, contains('19 − 1'));
      expect(exercise.correctOptionId, 'haut');
      expect(exercise.explanation, contains('3 × 7 = 21'));
      expect(exercise.explanation, contains('19 − 1 = 18'));
    });

    test('distinguishes lower and equal results', () {
      final lower = NumericalExercise(
        id: 'lower',
        firstOperation: _operation(34, ArithmeticOperator.subtraction, 1),
        secondOperation: _operation(5, ArithmeticOperator.addition, 30),
      );
      final equal = NumericalExercise(
        id: 'equal',
        firstOperation: _operation(4, ArithmeticOperator.multiplication, 3),
        secondOperation: _operation(9, ArithmeticOperator.addition, 3),
      );

      expect(lower.toSessionExercise().correctOptionId, 'bas');
      expect(equal.toSessionExercise().correctOptionId, 'egal');
      expect(equal.toSessionExercise().explanation, contains('sont égaux'));
    });
  });
}

ArithmeticOperation _operation(
  int left,
  ArithmeticOperator operator,
  int right,
) {
  return ArithmeticOperation(left: left, operator: operator, right: right);
}
