class RecordedAnswer {
  const RecordedAnswer({
    required this.exerciseId,
    required this.selectedOptionId,
    required this.isCorrect,
    required this.responseTime,
  });

  final String exerciseId;
  final String selectedOptionId;
  final bool isCorrect;
  final Duration responseTime;
}
