import 'package:flutter/material.dart';

import '../../../app/models/training_mode.dart';
import '../../session/domain/session_exercise.dart';
import '../../session/presentation/session_runner_page.dart';
import '../data/numerical_exercise_repository.dart';

class NumericalFluencyPracticePage extends StatefulWidget {
  const NumericalFluencyPracticePage({super.key});

  @override
  State<NumericalFluencyPracticePage> createState() =>
      _NumericalFluencyPracticePageState();
}

class _NumericalFluencyPracticePageState
    extends State<NumericalFluencyPracticePage> {
  final NumericalExerciseRepository _repository =
      const NumericalExerciseRepository();
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

  void _retryLoading() {
    setState(() {
      _exercises = _loadExercises();
    });
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<SessionExercise>>(
      future: _exercises,
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Scaffold(
            appBar: AppBar(title: const Text('Aisance numérique')),
            body: Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text('Impossible de charger les exercices.'),
                    const SizedBox(height: 12),
                    Text('${snapshot.error}', textAlign: TextAlign.center),
                    const SizedBox(height: 16),
                    FilledButton(
                      onPressed: _retryLoading,
                      child: const Text('Réessayer'),
                    ),
                  ],
                ),
              ),
            ),
          );
        }

        if (!snapshot.hasData) {
          return Scaffold(
            appBar: AppBar(title: const Text('Aisance numérique')),
            body: const Center(child: CircularProgressIndicator()),
          );
        }

        return SessionRunnerPage(
          title: 'Aisance numérique',
          mode: TrainingMode.practice,
          exercises: snapshot.requireData,
        );
      },
    );
  }
}
