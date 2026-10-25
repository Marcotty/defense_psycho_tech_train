import 'package:flutter/material.dart';

import '../../../app/models/training_mode.dart';
import '../data/session_history_repository.dart';
import '../domain/session_result.dart';

class HistoryPage extends StatefulWidget {
  const HistoryPage({super.key});

  @override
  State<HistoryPage> createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage> {
  final SessionHistoryRepository _repository = const SessionHistoryRepository();
  late Future<List<SessionResult>> _sessions;

  @override
  void initState() {
    super.initState();
    _sessions = _repository.loadSessions();
  }

  void _reload() {
    setState(() {
      _sessions = _repository.loadSessions();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Historique et statistiques'),
        actions: [
          IconButton(
            tooltip: 'Actualiser',
            onPressed: _reload,
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: FutureBuilder<List<SessionResult>>(
        future: _sessions,
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Text(
                  'Impossible de charger l’historique : ${snapshot.error}',
                  textAlign: TextAlign.center,
                ),
              ),
            );
          }
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final sessions = snapshot.requireData;
          if (sessions.isEmpty) {
            return _EmptyHistory(onRefresh: _reload);
          }

          final averageAccuracy =
              sessions.fold<double>(
                0,
                (sum, session) => sum + session.accuracy,
              ) /
              sessions.length;
          final timedSessions = sessions
              .where((session) => session.mode == TrainingMode.timedTest)
              .toList();
          final successes = timedSessions
              .where((session) => session.passed == true)
              .length;

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Row(
                children: [
                  Expanded(
                    child: _SummaryCard(
                      label: 'Sessions',
                      value: '${sessions.length}',
                      icon: Icons.history,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _SummaryCard(
                      label: 'Exactitude moyenne',
                      value: '${(averageAccuracy * 100).toStringAsFixed(0)} %',
                      icon: Icons.track_changes,
                    ),
                  ),
                ],
              ),
              if (timedSessions.isNotEmpty) ...[
                const SizedBox(height: 12),
                _SummaryCard(
                  label: 'Tests chronométrés réussis',
                  value: '$successes / ${timedSessions.length}',
                  icon: Icons.timer_outlined,
                ),
              ],
              const SizedBox(height: 24),
              Text(
                'Sessions récentes',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 8),
              for (final session in sessions)
                Card(
                  child: ListTile(
                    leading: Icon(
                      session.mode == TrainingMode.timedTest
                          ? Icons.timer_outlined
                          : Icons.menu_book_outlined,
                    ),
                    title: Text(session.testTitle),
                    subtitle: Text(
                      '${_formatDate(session.startedAt)} · '
                      '${session.correctCount}/${session.questionCount} bonnes '
                      'réponses · ${_formatDuration(session.elapsed)}',
                    ),
                    trailing: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          '${(session.accuracy * 100).toStringAsFixed(0)} %',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        if (session.passed != null)
                          Text(session.passed! ? 'Réussi' : 'À poursuivre'),
                      ],
                    ),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }

  String _formatDate(DateTime date) {
    final local = date.toLocal();
    final day = local.day.toString().padLeft(2, '0');
    final month = local.month.toString().padLeft(2, '0');
    final hour = local.hour.toString().padLeft(2, '0');
    final minute = local.minute.toString().padLeft(2, '0');
    return '$day/$month/${local.year} · $hour:$minute';
  }

  String _formatDuration(Duration duration) {
    final minutes = duration.inMinutes;
    final seconds = duration.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '${minutes}m ${seconds}s';
  }
}

class _EmptyHistory extends StatelessWidget {
  const _EmptyHistory({required this.onRefresh});

  final VoidCallback onRefresh;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 480),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.insights_outlined,
                size: 48,
                color: Theme.of(context).colorScheme.primary,
              ),
              const SizedBox(height: 16),
              Text(
                'Aucune session enregistrée',
                style: Theme.of(context).textTheme.titleLarge,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                'Termine un exercice pour retrouver ici ton exactitude, '
                'ton temps et ta progression.',
                style: Theme.of(context).textTheme.bodyLarge,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              TextButton(onPressed: onRefresh, child: const Text('Actualiser')),
            ],
          ),
        ),
      ),
    );
  }
}

class _SummaryCard extends StatelessWidget {
  const _SummaryCard({
    required this.label,
    required this.value,
    required this.icon,
  });

  final String label;
  final String value;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Icon(icon, color: Theme.of(context).colorScheme.primary),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(label, style: Theme.of(context).textTheme.bodySmall),
                  Text(value, style: Theme.of(context).textTheme.titleLarge),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
