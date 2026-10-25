import '../../../app/models/cognitive_test_type.dart';

class TestCatalogEntry {
  const TestCatalogEntry({
    required this.type,
    required this.title,
    required this.description,
    required this.objective,
  });

  final CognitiveTestType type;
  final String title;
  final String description;
  final String objective;
}

const testCatalog = <TestCatalogEntry>[
  TestCatalogEntry(
    type: CognitiveTestType.numericalFluency,
    title: 'Aisance numérique',
    description: 'Compare mentalement deux opérations simples.',
    objective:
        'Calculer les deux résultats et choisir le plus grand, '
        'le plus petit ou l’égalité.',
  ),
  TestCatalogEntry(
    type: CognitiveTestType.spatialOrientation,
    title: 'Orientation spatiale',
    description: 'Mémorise des règles de direction et de couleur.',
    objective:
        'Retenir les règles puis repérer la combinaison de flèches '
        'qui les respecte.',
  ),
  TestCatalogEntry(
    type: CognitiveTestType.wordMemory,
    title: 'Mémoire des mots',
    description: 'Mémorise une suite de catégories.',
    objective:
        'Comparer chaque mot à la catégorie correspondant à sa position.',
  ),
  TestCatalogEntry(
    type: CognitiveTestType.reasoning,
    title: 'Raisonnement',
    description: 'Déduis un ordre à partir de deux comparaisons.',
    objective: 'Relier les deux indices pour répondre à la question posée.',
  ),
  TestCatalogEntry(
    type: CognitiveTestType.errorDetection,
    title: 'Détection d’erreurs',
    description: 'Compare deux chaînes de caractères.',
    objective:
        'Mémoriser la ligne originale puis compter les différences '
        'dans sa copie.',
  ),
];
