import 'dart:async';

import 'package:flutter/material.dart';

import '../../../app/models/training_mode.dart';
import '../../history/domain/session_result.dart';
import '../domain/session_controller.dart';
import '../domain/session_exercise.dart';
import '../domain/session_phase.dart';

typedef SessionAnswerChoicesBuilder =
    Widget Function(
      BuildContext context,
      List<SessionAnswerOption> options,
      ValueChanged<String> onSelected,
    );

class SessionRunnerPage extends StatefulWidget {
  const SessionRunnerPage({
    required this.title,
    required this.mode,
    required this.exercises,
    this.testTimeLimit,
    this.memorizationDuration,
    this.answerChoicesBuilder,
    this.onCompleted,
    super.key,
  });

  final String title;
  final TrainingMode mode;
  final List<SessionExercise> exercises;
  final Duration? testTimeLimit;
  final Duration? memorizationDuration;
  final SessionAnswerChoicesBuilder? answerChoicesBuilder;
  final Future<void> Function(SessionResult result)? onCompleted;

  @override
  State<SessionRunnerPage> createState() => _SessionRunnerPageState();
}

class _SessionRunnerPageState extends State<SessionRunnerPage> {
  late final SessionController _session;
  final Stopwatch _questionStopwatch = Stopwatch();
  final Stopwatch _sessionStopwatch = Stopwatch();
  Timer? _memorizationTimer;
  Timer? _deadlineTimer;
  Timer? _countdownTimer;
  DateTime? _startedAt;
  int? _displayedRemainingSeconds;
  bool _submittedAnswerIsCorrect = false;
  bool _isSavingResult = false;
  String? _saveError;

  @override
  void initState() {
    super.initState();
    if (widget.mode == TrainingMode.timedTest &&
        (widget.testTimeLimit == null ||
            widget.testTimeLimit! <= Duration.zero)) {
      throw ArgumentError.value(
        widget.testTimeLimit,
        'testTimeLimit',
        'Timed sessions require a positive test time limit.',
      );
    }
    if (widget.memorizationDuration != null &&
        widget.memorizationDuration! <= Duration.zero) {
      throw ArgumentError.value(
        widget.memorizationDuration,
        'memorizationDuration',
        'Must be positive when provided.',
      );
    }
    _session = SessionController(
      mode: widget.mode,
      exercises: widget.exercises,
    );
    _startedAt = DateTime.now();
    _sessionStopwatch.start();
    _scheduleTimedTransition();
    if (widget.mode == TrainingMode.timedTest) {
      _deadlineTimer = Timer(widget.testTimeLimit!, _finishTimedSession);
      _countdownTimer = Timer.periodic(
        const Duration(milliseconds: 250),
        (_) => _updateCountdown(),
      );
    }
  }

  @override
  void dispose() {
    _memorizationTimer?.cancel();
    _deadlineTimer?.cancel();
    _countdownTimer?.cancel();
    _questionStopwatch.stop();
    _sessionStopwatch.stop();
    super.dispose();
  }

  void _scheduleTimedTransition() {
    if (widget.mode != TrainingMode.timedTest ||
        _session.phase != SessionPhase.memorization) {
      return;
    }

    _memorizationTimer?.cancel();
    final duration = widget.memorizationDuration;
    if (duration != null) {
      _memorizationTimer = Timer(duration, _showQuestion);
    }
  }

  Duration get _remainingTime =>
      widget.testTimeLimit! - _sessionStopwatch.elapsed;

  void _updateCountdown() {
    if (!mounted || _session.phase == SessionPhase.completed) return;
    final remaining = _remainingTime;
    if (remaining <= Duration.zero) {
      _finishTimedSession();
      return;
    }

    final seconds = (remaining.inMilliseconds + 999) ~/ 1000;
    if (seconds != _displayedRemainingSeconds) {
      setState(() => _displayedRemainingSeconds = seconds);
    }
  }

  void _finishTimedSession() {
    if (_session.phase == SessionPhase.completed) return;
    _memorizationTimer?.cancel();
    _deadlineTimer?.cancel();
    _countdownTimer?.cancel();
    _questionStopwatch.stop();
    _sessionStopwatch.stop();
    setState(_session.endTimedSession);
    _saveCompletedSession();
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
    if (_session.phase == SessionPhase.completed) {
      _completeSession();
    }
  }

  void _continueAfterFeedback() {
    setState(() {
      _session.continueAfterFeedback();
    });
    if (_session.phase == SessionPhase.completed) {
      _completeSession();
    }
  }

  void _completeSession() {
    _memorizationTimer?.cancel();
    _deadlineTimer?.cancel();
    _countdownTimer?.cancel();
    _questionStopwatch.stop();
    _sessionStopwatch.stop();
    _saveCompletedSession();
  }

  Future<void> _saveCompletedSession() async {
    final onCompleted = widget.onCompleted;
    if (onCompleted == null || _isSavingResult) return;
    final result = SessionResult(
      testTitle: widget.title,
      mode: widget.mode,
      startedAt: _startedAt!,
      elapsed: _sessionStopwatch.elapsed,
      correctCount: _session.correctCount,
      questionCount: _session.questionCount,
      timeLimit: widget.testTimeLimit,
    );

    setState(() {
      _isSavingResult = true;
      _saveError = null;
    });
    try {
      await onCompleted(result);
    } catch (error) {
      if (mounted) setState(() => _saveError = '$error');
    } finally {
      if (mounted) setState(() => _isSavingResult = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final phase = _session.phase;

    return Scaffold(
      appBar: AppBar(title: Text(widget.title)),
      body: SafeArea(
        child: Column(
          children: [
            if (widget.mode == TrainingMode.timedTest &&
                phase != SessionPhase.completed)
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 12, 24, 0),
                child: Text(
                  'Temps restant : ${_formatCountdown(_remainingTime)}',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ),
            Expanded(
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
          ],
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
          Column(
            children: [
              FilledButton(
                onPressed: _showQuestion,
                child: const Text('Afficher la question'),
              ),
              const SizedBox(height: 8),
              Text(
                'Le chronomètre continue pendant la mémorisation.',
                style: Theme.of(context).textTheme.bodyMedium,
                textAlign: TextAlign.center,
              ),
            ],
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
        if (widget.answerChoicesBuilder case final builder?)
          builder(context, exercise.options, _submitAnswer)
        else
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
        if (widget.mode == TrainingMode.timedTest) ...[
          const SizedBox(height: 12),
          Text(
            _session.accuracy >= 0.95 &&
                    _sessionStopwatch.elapsed <= widget.testTimeLimit!
                ? 'Test réussi'
                : 'Objectif non atteint',
            style: Theme.of(context).textTheme.titleLarge,
            textAlign: TextAlign.center,
          ),
          Text(
            'Seuil : 95 % · Limite : ${_formatCountdown(widget.testTimeLimit!)}',
            textAlign: TextAlign.center,
          ),
        ] else ...[
          Text(
            'Prends le temps de revoir les corrections et d’identifier les '
            'points à renforcer.',
            style: Theme.of(context).textTheme.bodyMedium,
            textAlign: TextAlign.center,
          ),
        ],
        if (_isSavingResult) ...[
          const SizedBox(height: 12),
          const Center(child: CircularProgressIndicator()),
        ],
        if (_saveError case final error?) ...[
          const SizedBox(height: 12),
          Text(
            'Le résultat n’a pas pu être enregistré : $error',
            textAlign: TextAlign.center,
          ),
          TextButton(
            onPressed: _saveCompletedSession,
            child: const Text('Réessayer'),
          ),
        ],
      ],
    );
  }

  String _formatCountdown(Duration duration) {
    final seconds = duration.inSeconds < 0 ? 0 : duration.inSeconds;
    final minutes = (seconds ~/ 60).toString().padLeft(2, '0');
    final remainder = (seconds % 60).toString().padLeft(2, '0');
    return '$minutes:$remainder';
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
