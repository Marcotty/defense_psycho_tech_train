import 'package:flutter/material.dart';

import '../../../app/models/training_mode.dart';
import '../../history/data/session_history_repository.dart';
import '../../session/presentation/session_runner_page.dart';
import '../data/spatial_exercise_repository.dart';
import '../domain/spatial_exercise.dart';
import 'spatial_answer_grid.dart';

class SpatialOrientationPracticePage extends StatefulWidget {
  const SpatialOrientationPracticePage({super.key});

  @override
  State<SpatialOrientationPracticePage> createState() =>
      _SpatialOrientationPracticePageState();
}

class _SpatialOrientationPracticePageState
    extends State<SpatialOrientationPracticePage> {
  final SpatialExerciseRepository _repository =
      const SpatialExerciseRepository();
  late Future<List<SpatialExercise>> _exercises;

  @override
  void initState() {
    super.initState();
    _exercises = _repository.loadExercises();
  }

  void _retryLoading() {
    setState(() {
      _exercises = _repository.loadExercises();
    });
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<SpatialExercise>>(
      future: _exercises,
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Scaffold(
            appBar: AppBar(title: const Text('Orientation spatiale')),
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
            appBar: AppBar(title: const Text('Orientation spatiale')),
            body: const Center(child: CircularProgressIndicator()),
          );
        }

        final exercises = snapshot.requireData;
        final answerTiles = {
          for (final exercise in exercises)
            for (var index = 0; index < exercise.tiles.length; index++)
              '${exercise.id}-case-$index': exercise.tiles[index],
        };

        return SessionRunnerPage(
          title: 'Orientation spatiale',
          mode: TrainingMode.practice,
          exercises: [
            for (final exercise in exercises) exercise.toSessionExercise(),
          ],
          onCompleted: (result) =>
              const SessionHistoryRepository().saveSession(result),
          answerChoicesBuilder: (context, options, onSelected) {
            return SpatialAnswerGrid(
              options: options,
              tiles: answerTiles,
              onSelected: onSelected,
            );
          },
        );
      },
    );
  }
}
