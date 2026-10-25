import 'dart:async';

import 'package:flutter/material.dart';

import '../../../app/models/training_mode.dart';
import '../domain/session_controller.dart';
import '../domain/session_exercise.dart';
import '../domain/session_phase.dart';

class SessionRunnerPage extends StatefulWidget {
  const SessionRunnerPage({
    required this.title,
    required this.mode,
    required this.exercises,
    this.memorizationDuration,
    super.key,
  }) : assert(
         mode == TrainingMode.practice || memorizationDuration != null,
         'Timed sessions require a memorization duration.',
       );

  final String title;
  final TrainingMode mode;
  final List<SessionExercise> exercises;
  final Duration? memorizationDuration;

  @override
  State<SessionRunnerPage> createState() => _SessionRunnerPageState();
}

class _SessionRunnerPageState extends State<SessionRunnerPage> {
  late final SessionController _session;
  final Stopwatch _questionStopwatch = Stopwatch();
  Timer? _memorizationTimer;
  bool _submittedAnswerIsCorrect = false;

  @override
  void initState() {
    super.initState();
    final memorizationDuration = widget.memorizationDuration;
    if (widget.mode == TrainingMode.timedTest &&
        (memorizationDuration == null ||
            memorizationDuration <= Duration.zero)) {
      throw ArgumentError.value(
        memorizationDuration,
        'memorizationDuration',
        'Timed sessions require a positive memorization duration.',
      );
    }
    _session = SessionController(
      mode: widget.mode,
      exercises: widget.exercises,
    );
    _scheduleTimedTransition();
  }

  @override
  void dispose() {
    _memorizationTimer?.cancel();
    _questionStopwatch.stop();
    super.dispose();
  }

  void _scheduleTimedTransition() {
    if (widget.mode != TrainingMode.timedTest ||
        _session.phase != SessionPhase.memorization) {
      return;
    }

    _memorizationTimer?.cancel();
    _memorizationTimer = Timer(widget.memorizationDuration!, _showQuestion);
  }

  void _showQuestion() {
    if (!mounted || _session.phase != SessionPhase.memorization) {
      return;
    }

    setState(() {
      _memorizationTimer?.cancel();
      _session.showQuestion();
      _questionStopwatch
        ..reset()
        ..start();
    });
  }

  void _submitAnswer(String optionId) {
    _questionStopwatch.stop();
    final answer = _session.submitAnswer(
      optionId: optionId,
      responseTime: _questionStopwatch.elapsed,
    );

    setState(() {
      _submittedAnswerIsCorrect = answer.isCorrect;
      _scheduleTimedTransition();
    });
  }

  void _continueAfterFeedback() {
    setState(() {
      _session.continueAfterFeedback();
    });
  }

  @override
  Widget build(BuildContext context) {
    final phase = _session.phase;

    return Scaffold(
      appBar: AppBar(title: Text(widget.title)),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 680),
              child: switch (phase) {
                SessionPhase.memorization => _buildMemorization(context),
                SessionPhase.answering => _buildQuestion(context),
                SessionPhase.feedback => _buildFeedback(context),
                SessionPhase.completed => _buildResult(context),
              },
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMemorization(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _ProgressLabel(
          current: _session.currentIndex + 1,
          total: _session.questionCount,
          label: 'Écran 1 · mémorisation',
        ),
        const SizedBox(height: 24),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Text(
              _session.currentExercise.memorizationContent,
              style: Theme.of(context).textTheme.headlineSmall,
              textAlign: TextAlign.center,
            ),
          ),
        ),
        const SizedBox(height: 24),
        if (widget.mode == TrainingMode.practice)
          FilledButton(
            onPressed: _showQuestion,
            child: const Text('Je suis prêt'),
          )
        else
          Text(
            'Mémorise les informations. Elles disparaîtront automatiquement.',
            style: Theme.of(context).textTheme.bodyLarge,
            textAlign: TextAlign.center,
          ),
      ],
    );
  }

  Widget _buildQuestion(BuildContext context) {
    final exercise = _session.currentExercise;
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _ProgressLabel(
          current: _session.currentIndex + 1,
          total: _session.questionCount,
          label: 'Écran 2 · question',
        ),
        const SizedBox(height: 24),
        Text(
          exercise.prompt,
          style: Theme.of(context).textTheme.headlineSmall,
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 24),
        for (final option in exercise.options) ...[
          SizedBox(
            height: 56,
            child: OutlinedButton(
              onPressed: () => _submitAnswer(option.id),
              child: Text(option.label),
            ),
          ),
          const SizedBox(height: 12),
        ],
      ],
    );
  }

  Widget _buildFeedback(BuildContext context) {
    final exercise = _session.currentExercise;
    final colorScheme = Theme.of(context).colorScheme;

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Icon(
          _submittedAnswerIsCorrect ? Icons.check_circle : Icons.cancel,
          size: 48,
          color: _submittedAnswerIsCorrect
              ? colorScheme.primary
              : colorScheme.error,
        ),
        const SizedBox(height: 12),
        Text(
          _submittedAnswerIsCorrect ? 'Bonne réponse' : 'Réponse incorrecte',
          style: Theme.of(context).textTheme.headlineSmall,
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 16),
        Text(exercise.explanation, textAlign: TextAlign.center),
        const SizedBox(height: 24),
        FilledButton(
          onPressed: _continueAfterFeedback,
          child: Text(
            _session.currentIndex + 1 == _session.questionCount
                ? 'Voir le bilan'
                : 'Question suivante',
          ),
        ),
      ],
    );
  }

  Widget _buildResult(BuildContext context) {
    final totalTime = _session.totalResponseTime;
    final averageMilliseconds = _session.answers.isEmpty
        ? 0
        : totalTime.inMilliseconds ~/ _session.answers.length;

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          'Session terminée',
          style: Theme.of(context).textTheme.headlineMedium,
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 24),
        _ResultMetric(
          label: 'Exactitude',
          value: '${(_session.accuracy * 100).toStringAsFixed(0)} %',
        ),
        const SizedBox(height: 12),
        _ResultMetric(
          label: 'Temps moyen par question',
          value: _formatDuration(Duration(milliseconds: averageMilliseconds)),
        ),
        const SizedBox(height: 12),
        _ResultMetric(
          label: 'Temps total de réponse',
          value: _formatDuration(totalTime),
        ),
        const SizedBox(height: 20),
        Text(
          'Le respect de l’objectif de rapidité sera évalué avec la limite '
          'définie pour ce test.',
          style: Theme.of(context).textTheme.bodyMedium,
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  String _formatDuration(Duration duration) {
    final seconds = duration.inMilliseconds / 1000;
    return '${seconds.toStringAsFixed(1)} s';
  }
}

class _ProgressLabel extends StatelessWidget {
  const _ProgressLabel({
    required this.current,
    required this.total,
    required this.label,
  });

  final int current;
  final int total;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          'Question $current sur $total',
          style: Theme.of(context).textTheme.labelLarge,
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 8),
        Text(label, style: Theme.of(context).textTheme.titleMedium),
      ],
    );
  }
}

class _ResultMetric extends StatelessWidget {
  const _ResultMetric({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(child: Text(label)),
            const SizedBox(width: 16),
            Text(value, style: Theme.of(context).textTheme.titleLarge),
          ],
        ),
      ),
    );
  }
}
