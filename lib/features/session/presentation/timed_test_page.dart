import 'package:flutter/material.dart';

import '../../../app/models/cognitive_test_type.dart';
import '../../../app/models/training_mode.dart';
import '../../history/data/session_history_repository.dart';
import '../../spatial_orientation/domain/spatial_exercise.dart';
import '../../spatial_orientation/presentation/spatial_answer_grid.dart';
import '../../test_selection/data/test_catalog.dart';
import '../domain/session_exercise.dart';
import '../domain/timed_exercise_generator.dart';
import '../../settings/data/settings_repository.dart';
import 'session_runner_page.dart';

class TimedTestPage extends StatefulWidget {
  const TimedTestPage({
    required this.testType,
    this.exerciseGenerator,
    super.key,
  });

  final CognitiveTestType testType;
  final TimedExerciseGenerator? exerciseGenerator;

  @override
  State<TimedTestPage> createState() => _TimedTestPageState();
}

class _TimedTestPageState extends State<TimedTestPage> {
  final SettingsRepository _settingsRepository = const SettingsRepository();
  late final TimedExerciseGenerator _exerciseGenerator =
      widget.exerciseGenerator ?? TimedExerciseGenerator();
  late Future<_TimedTestData> _data;

  @override
  void initState() {
    super.initState();
    _data = _loadData();
  }

  Future<_TimedTestData> _loadData() async {
    final timeLimits = await _settingsRepository.loadTestTimeLimits();
    final List<SessionExercise> exercises;
    final Map<String, SpatialTile>? spatialTiles;
    if (widget.testType == CognitiveTestType.spatialOrientation) {
      final generated = _exerciseGenerator.generateSpatialExercises();
      exercises = [
        for (final exercise in generated) exercise.toSessionExercise(),
      ];
      spatialTiles = {
        for (final exercise in generated)
          for (var index = 0; index < exercise.tiles.length; index++)
            '${exercise.id}-case-$index': exercise.tiles[index],
      };
    } else {
      exercises = _exerciseGenerator.generate(widget.testType);
      spatialTiles = null;
    }

    return _TimedTestData(
      title: testCatalog
          .singleWhere((test) => test.type == widget.testType)
          .title,
      timeLimit: timeLimits[widget.testType],
      exercises: List.unmodifiable(exercises),
      spatialTiles: spatialTiles,
    );
  }

  Future<void> _openSettings() async {
    await Navigator.of(context).pushNamed('/settings');
    if (mounted) {
      setState(() {
        _data = _loadData();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<_TimedTestData>(
      future: _data,
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Scaffold(
            appBar: AppBar(title: const Text('Mode Test')),
            body: Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text('Impossible de préparer ce test.'),
                    const SizedBox(height: 12),
                    Text('${snapshot.error}', textAlign: TextAlign.center),
                    const SizedBox(height: 16),
                    FilledButton(
                      onPressed: () {
                        setState(() {
                          _data = _loadData();
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
            appBar: AppBar(title: const Text('Mode Test')),
            body: const Center(child: CircularProgressIndicator()),
          );
        }

        final data = snapshot.requireData;
        if (data.timeLimit == null) {
          return Scaffold(
            appBar: AppBar(title: Text(data.title)),
            body: Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 480),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.timer_outlined, size: 48),
                      const SizedBox(height: 16),
                      Text(
                        'Définis une limite de temps pour ce test.',
                        style: Theme.of(context).textTheme.titleLarge,
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Tu peux la régler dans les paramètres. Aucun temps '
                        'par défaut n’est imposé.',
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 20),
                      FilledButton(
                        onPressed: _openSettings,
                        child: const Text('Ouvrir les paramètres'),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        }

        return SessionRunnerPage(
          title: data.title,
          mode: TrainingMode.timedTest,
          exercises: data.exercises,
          testTimeLimit: data.timeLimit,
          onCompleted: (result) =>
              const SessionHistoryRepository().saveSession(result),
          answerChoicesBuilder: data.spatialTiles == null
              ? null
              : (context, options, onSelected) => SpatialAnswerGrid(
                  options: options,
                  tiles: data.spatialTiles!,
                  onSelected: onSelected,
                ),
        );
      },
    );
  }
}

class _TimedTestData {
  const _TimedTestData({
    required this.title,
    required this.timeLimit,
    required this.exercises,
    required this.spatialTiles,
  });

  final String title;
  final Duration? timeLimit;
  final List<SessionExercise> exercises;
  final Map<String, SpatialTile>? spatialTiles;
}
