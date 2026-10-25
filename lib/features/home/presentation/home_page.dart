import 'package:flutter/material.dart';

import '../../../app/models/training_mode.dart';
import '../../history/presentation/history_page.dart';
import '../../test_selection/presentation/test_selection_page.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  void _openTestSelection(BuildContext context, TrainingMode mode) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(builder: (_) => TestSelectionPage(mode: mode)),
    );
  }

  void _openHistory(BuildContext context) {
    Navigator.of(
      context,
    ).push(MaterialPageRoute<void>(builder: (_) => const HistoryPage()));
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(title: const Text('BTCA')),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, _) {
            return SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 680),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          color: colorScheme.primary,
                          borderRadius: BorderRadius.circular(24),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'PRÉPARATION SAO · BELGIQUE',
                              style: Theme.of(context).textTheme.labelLarge
                                  ?.copyWith(
                                    color: colorScheme.onPrimary,
                                    letterSpacing: 1.2,
                                  ),
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'Entraîne-toi avec méthode.',
                              style: Theme.of(context).textTheme.headlineMedium
                                  ?.copyWith(
                                    color: colorScheme.onPrimary,
                                    fontWeight: FontWeight.bold,
                                  ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Pratique les cinq types d’exercices BTCA, '
                              'à ton rythme ou en conditions chronométrées.',
                              style: Theme.of(context).textTheme.bodyLarge
                                  ?.copyWith(color: colorScheme.onPrimary),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 28),
                      Text(
                        'Choisis ton mode',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const SizedBox(height: 12),
                      _HomeActionCard(
                        icon: Icons.menu_book_outlined,
                        title: 'Mode Entraînement',
                        description:
                            'Exercices du livret avec correction '
                            'après chaque réponse.',
                        onTap: () =>
                            _openTestSelection(context, TrainingMode.practice),
                      ),
                      const SizedBox(height: 12),
                      _HomeActionCard(
                        icon: Icons.timer_outlined,
                        title: 'Mode Test',
                        description:
                            'Une session chronométrée, sans '
                            'correction avant le résultat.',
                        onTap: () =>
                            _openTestSelection(context, TrainingMode.timedTest),
                      ),
                      const SizedBox(height: 12),
                      _HomeActionCard(
                        icon: Icons.insights_outlined,
                        title: 'Historique et statistiques',
                        description:
                            'Retrouve tes résultats et suis '
                            'ta progression.',
                        onTap: () => _openHistory(context),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class _HomeActionCard extends StatelessWidget {
  const _HomeActionCard({
    required this.icon,
    required this.title,
    required this.description,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String description;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              CircleAvatar(
                backgroundColor: colorScheme.secondaryContainer,
                foregroundColor: colorScheme.onSecondaryContainer,
                child: Icon(icon),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: Theme.of(context).textTheme.titleMedium),
                    const SizedBox(height: 4),
                    Text(
                      description,
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              const Icon(Icons.chevron_right),
            ],
          ),
        ),
      ),
    );
  }
}
