import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../app/models/training_mode.dart';
import '../../history/data/session_history_repository.dart';
import '../../session/domain/session_exercise.dart';
import '../../session/presentation/session_runner_page.dart';
import '../data/spatial_exercise_repository.dart';
import '../domain/spatial_exercise.dart';

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
            return _buildAnswerGrid(context, options, answerTiles, onSelected);
          },
        );
      },
    );
  }

  Widget _buildAnswerGrid(
    BuildContext context,
    List<SessionAnswerOption> options,
    Map<String, SpatialTile> tiles,
    ValueChanged<String> onSelected,
  ) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final columns = constraints.maxWidth >= 560 ? 3 : 2;

        return GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: options.length,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: columns,
            mainAxisSpacing: 12,
            crossAxisSpacing: 12,
            childAspectRatio: columns == 3 ? 1.25 : 1.1,
          ),
          itemBuilder: (context, index) {
            final option = options[index];
            final tile = tiles[option.id];
            if (tile == null) {
              throw StateError('No arrow tile is registered for ${option.id}.');
            }

            return Semantics(
              button: true,
              label: option.label,
              child: OutlinedButton(
                onPressed: () => onSelected(option.id),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _ArrowGlyph(arrow: tile.above),
                    const SizedBox(height: 2),
                    _ArrowGlyph(arrow: tile.below),
                    const SizedBox(height: 4),
                    Text(
                      'Case ${index + 1}',
                      style: Theme.of(context).textTheme.labelMedium,
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}

class _ArrowGlyph extends StatelessWidget {
  const _ArrowGlyph({required this.arrow});

  final SpatialArrow arrow;

  @override
  Widget build(BuildContext context) {
    final angle = switch (arrow.direction) {
      ArrowDirection.upRight => math.pi / 4,
      ArrowDirection.upLeft => -math.pi / 4,
      ArrowDirection.downRight => 3 * math.pi / 4,
      ArrowDirection.downLeft => -3 * math.pi / 4,
    };
    final color = switch (arrow.color) {
      ArrowColor.black => Colors.black,
      ArrowColor.yellow => const Color(0xFFFFD600),
    };

    return Transform.rotate(
      angle: angle,
      child: Stack(
        alignment: Alignment.center,
        children: [
          if (arrow.color == ArrowColor.black)
            const Icon(
              Icons.arrow_upward_rounded,
              size: 40,
              color: Colors.white,
            ),
          Icon(
            Icons.arrow_upward_rounded,
            size: 34,
            color: color,
            shadows: arrow.color == ArrowColor.yellow
                ? const [Shadow(color: Colors.black87, blurRadius: 1)]
                : null,
          ),
        ],
      ),
    );
  }
}
