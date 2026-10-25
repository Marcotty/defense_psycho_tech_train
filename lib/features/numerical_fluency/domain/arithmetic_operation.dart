enum ArithmeticOperator {
  addition('+'),
  subtraction('−'),
  multiplication('×'),
  division('÷');

  const ArithmeticOperator(this.symbol);

  final String symbol;
}

class ArithmeticOperation {
  const ArithmeticOperation({
    required this.left,
    required this.operator,
    required this.right,
  }) : assert(
         operator != ArithmeticOperator.division || right != 0,
         'A division cannot have zero as its divisor.',
       ),
       assert(
         operator != ArithmeticOperator.division || left % right == 0,
         'Division exercises must have an integer result.',
       );

  final int left;
  final ArithmeticOperator operator;
  final int right;

  int get result => switch (operator) {
    ArithmeticOperator.addition => left + right,
    ArithmeticOperator.subtraction => left - right,
    ArithmeticOperator.multiplication => left * right,
    ArithmeticOperator.division => left ~/ right,
  };

  String get expression => '$left ${operator.symbol} $right';
}
