class SessionAnswerOption {
  const SessionAnswerOption({required this.id, required this.label});

  final String id;
  final String label;
}

class SessionExercise {
  const SessionExercise({
    required this.id,
    required this.memorizationContent,
    required this.prompt,
    required this.options,
    required this.correctOptionId,
    required this.explanation,
  });

  final String id;
  final String memorizationContent;
  final String prompt;
  final List<SessionAnswerOption> options;
  final String correctOptionId;
  final String explanation;
}
