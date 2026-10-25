import 'package:flutter/material.dart';

import '../../../app/models/training_mode.dart';
import '../../history/data/session_history_repository.dart';
import '../../session/domain/session_exercise.dart';
import '../../session/presentation/session_runner_page.dart';
import '../data/error_detection_repository.dart';

class ErrorDetectionPracticePage extends StatefulWidget {
  const ErrorDetectionPracticePage({super.key});

  @override
  State<ErrorDetectionPracticePage> createState() =>
      _ErrorDetectionPracticePageState();
}

class _ErrorDetectionPracticePageState
    extends State<ErrorDetectionPracticePage> {
  final ErrorDetectionRepository _repository = const ErrorDetectionRepository();
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
          return Scaffold(
            appBar: AppBar(title: const Text('Détection d’erreurs')),
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
                      onPressed: () {
                        setState(() {
                          _exercises = _loadExercises();
                        });
                      },
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
            appBar: AppBar(title: const Text('Détection d’erreurs')),
            body: const Center(child: CircularProgressIndicator()),
          );
        }

        return SessionRunnerPage(
          title: 'Détection d’erreurs',
          mode: TrainingMode.practice,
          exercises: snapshot.requireData,
          onCompleted: (result) =>
              const SessionHistoryRepository().saveSession(result),
        );
      },
    );
  }
}
