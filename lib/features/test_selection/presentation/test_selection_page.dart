import 'package:flutter/material.dart';

import '../../../app/models/training_mode.dart';
import '../data/test_catalog.dart';
import 'test_overview_page.dart';

class TestSelectionPage extends StatelessWidget {
  const TestSelectionPage({required this.mode, super.key});

  final TrainingMode mode;

  @override
  Widget build(BuildContext context) {
    final isPractice = mode == TrainingMode.practice;

    return Scaffold(
      appBar: AppBar(
        title: Text(isPractice ? 'Mode Entraînement' : 'Mode Test'),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(24),
          children: [
            Text(
              'Choisis un test',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 8),
            Text(
              isPractice
                  ? 'Les exercices du livret seront corrigés après chaque réponse.'
                  : 'Chaque session portera sur un seul type de test.',
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            const SizedBox(height: 20),
            for (final test in testCatalog) ...[
              Card(
                clipBehavior: Clip.antiAlias,
                child: ListTile(
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 12,
                  ),
                  title: Text(test.title),
                  subtitle: Padding(
                    padding: const EdgeInsets.only(top: 6),
                    child: Text(test.description),
                  ),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute<void>(
                        builder: (_) =>
                            TestOverviewPage(mode: mode, test: test),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 8),
            ],
          ],
        ),
      ),
    );
  }
}
