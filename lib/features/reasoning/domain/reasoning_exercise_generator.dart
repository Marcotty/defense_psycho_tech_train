import 'dart:math';

import 'reasoning_exercise.dart';

class ReasoningDomain {
  const ReasoningDomain({
    required this.highPhrase,
    required this.lowPhrase,
    required this.connector,
    required this.highQuestion,
    required this.lowQuestion,
    required this.entities,
  });

  /// Ex. « plus rapide » ; la relation lue est « A plus rapide que B ».
  final String highPhrase;
  final String lowPhrase;

  /// Mot de liaison élidable (« que » ou « de »).
  final String connector;
  final String highQuestion;
  final String lowQuestion;
  final List<String> entities;
}

const reasoningDomains = <ReasoningDomain>[
  ReasoningDomain(
    highPhrase: 'plus rapide',
    lowPhrase: 'plus lent',
    connector: 'que',
    highQuestion: 'Quel est le plus rapide ?',
    lowQuestion: 'Quel est le plus lent ?',
    entities: [
      'Tram',
      'Ferry',
      'Camion',
      'Hélicoptère',
      'Vélo',
      'Train',
      'Avion',
      'Bus',
    ],
  ),
  ReasoningDomain(
    highPhrase: 'plus haut',
    lowPhrase: 'plus bas',
    connector: 'que',
    highQuestion: 'Quel est le plus haut ?',
    lowQuestion: 'Quel est le plus bas ?',
    entities: ['Pont', 'Église', 'Arbre', 'Tour', 'Immeuble', 'Phare'],
  ),
  ReasoningDomain(
    highPhrase: 'plus loin',
    lowPhrase: 'plus près',
    connector: 'que',
    highQuestion: 'Quel est le plus loin ?',
    lowQuestion: 'Quel est le plus près ?',
    entities: ['Lac', 'Montagne', 'Bois', 'Rivière', 'Village', 'Forêt'],
  ),
  ReasoningDomain(
    highPhrase: 'plus grand',
    lowPhrase: 'plus petit',
    connector: 'que',
    highQuestion: 'Qui est le plus grand ?',
    lowQuestion: 'Qui est le plus petit ?',
    entities: ['Policier', 'Pompier', 'Pilote', 'Soldat', 'Médecin', 'Marin'],
  ),
  ReasoningDomain(
    highPhrase: 'plus lourd',
    lowPhrase: 'plus léger',
    connector: 'que',
    highQuestion: 'Quel est le plus lourd ?',
    lowQuestion: 'Quel est le plus léger ?',
    entities: ['Casque', 'Baïonnette', 'Fusil', 'Sac', 'Gilet', 'Radio'],
  ),
  ReasoningDomain(
    highPhrase: 'à droite',
    lowPhrase: 'à gauche',
    connector: 'de',
    highQuestion: 'Quel est le plus à droite ?',
    lowQuestion: 'Quel est le plus à gauche ?',
    entities: [
      'Patrouille',
      'Régiment',
      'Compagnie',
      'Section',
      'Bataillon',
      'Escadron',
    ],
  ),
];

/// Génère des exercices de raisonnement inédits.
///
/// Règles : trois entités distinctes d'un même domaine, exactement deux
/// indices formant une chaîne (l'entité intermédiaire figure dans les deux),
/// ordre total non ambigu, une question sur le maximum ou le minimum, et des
/// indices formulés indifféremment dans un sens ou dans l'autre.
class ReasoningExerciseGenerator {
  ReasoningExerciseGenerator({Random? random}) : _random = random ?? Random();

  final Random _random;

  List<ReasoningExercise> generate(
    int count, {
    String idPrefix = 'timed-reasoning',
  }) {
    return [
      for (var index = 0; index < count; index++)
        generateOne('$idPrefix-${index + 1}'),
    ];
  }

  ReasoningExercise generateOne(String id) {
    final domain = reasoningDomains[_random.nextInt(reasoningDomains.length)];
    final picked = ([...domain.entities]..shuffle(_random)).take(3).toList();
    final top = picked[0];
    final middle = picked[1];
    final bottom = picked[2];

    final clues = [
      _clue(domain, greater: top, lesser: middle),
      _clue(domain, greater: middle, lesser: bottom),
    ]..shuffle(_random);

    final extreme = _random.nextBool()
        ? OrderExtreme.maximum
        : OrderExtreme.minimum;
    return ReasoningExercise(
      id: id,
      entities: List.unmodifiable([...picked]..shuffle(_random)),
      clues: List.unmodifiable(clues),
      question: extreme == OrderExtreme.maximum
          ? domain.highQuestion
          : domain.lowQuestion,
      extreme: extreme,
    );
  }

  OrderingClue _clue(
    ReasoningDomain domain, {
    required String greater,
    required String lesser,
  }) {
    final statement = _random.nextBool()
        ? '$greater ${domain.highPhrase} ${_link(domain.connector, lesser)}'
        : '$lesser ${domain.lowPhrase} ${_link(domain.connector, greater)}';
    return OrderingClue(
      greaterEntity: greater,
      lesserEntity: lesser,
      statement: statement,
    );
  }

  String _link(String connector, String entity) {
    const elidable = 'AEIOUYÉÈÊÂÎÔÛHaeiouyéèêâîôûh';
    final elides = elidable.contains(entity[0]);
    return elides
        ? '${connector.substring(0, connector.length - 1)}’$entity'
        : '$connector $entity';
  }
}
