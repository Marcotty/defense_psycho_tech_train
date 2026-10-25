import 'package:flutter/material.dart';

import '../../../app/models/training_mode.dart';
import '../../session/domain/session_exercise.dart';
import '../../session/presentation/session_runner_page.dart';
import '../data/reasoning_repository.dart';

class ReasoningPracticePage extends StatefulWidget {
  const ReasoningPracticePage({super.key});

  @override
  State<ReasoningPracticePage> createState() => _ReasoningPracticePageState();
}

class _ReasoningPracticePageState extends State<ReasoningPracticePage> {
  final ReasoningRepository _repository = const ReasoningRepository();
  late Future<List<SessionExercise>> _exercises;

  @override
  void initState() {
    super.initState();
    _exercises = _loadExercises();
  }

  Future<List<SessionExercise>> _loadExercises() async {
    final exercises = await _repository.loadExercises();
    return List.unmodifiable(
      exercises.map((exercise) => exercise.toSessionExercise()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<SessionExercise>>(
      future: _exercises,
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return _LoadErrorPage(
            onRetry: () => setState(() => _exercises = _loadExercises()),
            error: snapshot.error!,
          );
        }
        if (!snapshot.hasData) {
          return Scaffold(
            appBar: AppBar(title: const Text('Raisonnement')),
            body: const Center(child: CircularProgressIndicator()),
          );
        }

        return SessionRunnerPage(
          title: 'Raisonnement',
          mode: TrainingMode.practice,
          exercises: snapshot.requireData,
        );
      },
    );
  }
}

class _LoadErrorPage extends StatelessWidget {
  const _LoadErrorPage({required this.onRetry, required this.error});

  final VoidCallback onRetry;
  final Object error;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Raisonnement')),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('Impossible de charger les exercices.'),
              const SizedBox(height: 12),
              Text('$error', textAlign: TextAlign.center),
              const SizedBox(height: 16),
              FilledButton(onPressed: onRetry, child: const Text('Réessayer')),
            ],
          ),
        ),
      ),
    );
  }
}
