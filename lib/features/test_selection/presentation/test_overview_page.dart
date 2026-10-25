import 'package:flutter/material.dart';

import '../../../app/models/training_mode.dart';
import '../data/test_catalog.dart';

class TestOverviewPage extends StatelessWidget {
  const TestOverviewPage({required this.mode, required this.test, super.key});

  final TrainingMode mode;
  final TestCatalogEntry test;

  @override
  Widget build(BuildContext context) {
    final isPractice = mode == TrainingMode.practice;

    return Scaffold(
      appBar: AppBar(title: Text(test.title)),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 640),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Icon(
                    Icons.psychology_alt_outlined,
                    size: 48,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    isPractice ? 'Entraînement · Livret' : 'Test chronométré',
                    style: Theme.of(context).textTheme.titleLarge,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    test.objective,
                    style: Theme.of(context).textTheme.bodyLarge,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Déroulement',
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                          const SizedBox(height: 12),
                          Text(
                            isPractice
                                ? 'Tu pourras passer à la question quand tu '
                                      'seras prêt. La correction suivra chaque '
                                      'réponse.'
                                : 'L’écran de mémorisation disparaîtra '
                                      'automatiquement. Le temps et l’exactitude '
                                      'seront évalués séparément.',
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  const FilledButton(
                    onPressed: null,
                    child: Text('Les exercices seront ajoutés ensuite'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
