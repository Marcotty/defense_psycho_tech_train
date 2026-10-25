import '../../session/domain/session_exercise.dart';

enum ArrowColor {
  black('Noire', 'Noir'),
  yellow('Jaune', 'Jaune');

  const ArrowColor(this.feminineLabel, this.masculineLabel);

  final String feminineLabel;
  final String masculineLabel;
}

enum ArrowDirection {
  upRight('en haut à droite'),
  upLeft('en haut à gauche'),
  downRight('en bas à droite'),
  downLeft('en bas à gauche');

  const ArrowDirection(this.label);

  final String label;
}

class SpatialArrow {
  const SpatialArrow({required this.color, required this.direction});

  final ArrowColor color;
  final ArrowDirection direction;
}

class SpatialRules {
  const SpatialRules({
    required this.colorAbove,
    required this.directionAbove,
    required this.directionBelow,
  });

  final ArrowColor colorAbove;
  final ArrowDirection directionAbove;
  final ArrowDirection directionBelow;

  ArrowColor get colorBelow =>
      colorAbove == ArrowColor.black ? ArrowColor.yellow : ArrowColor.black;

  bool matches(SpatialTile tile) {
    return tile.above.color == colorAbove &&
        tile.below.color == colorBelow &&
        tile.above.direction == directionAbove &&
        tile.below.direction == directionBelow;
  }

  String get description =>
      '${colorAbove.masculineLabel} au-dessus de ${colorBelow.masculineLabel}'
      '\n${directionAbove.label} au-dessus de ${directionBelow.label}';
}

class SpatialTile {
  const SpatialTile({required this.above, required this.below});

  final SpatialArrow above;
  final SpatialArrow below;
}

class SpatialExercise {
  const SpatialExercise({
    required this.id,
    required this.rules,
    required this.tiles,
    required this.correctTileIndex,
  });

  final String id;
  final SpatialRules rules;
  final List<SpatialTile> tiles;
  final int correctTileIndex;

  List<int> get matchingTileIndexes => [
    for (var index = 0; index < tiles.length; index++)
      if (rules.matches(tiles[index])) index,
  ];

  String get explanation =>
      'La case ${correctTileIndex + 1} respecte les deux règles : '
      '${rules.description.replaceAll('\n', ' ; ')}.';

  SessionExercise toSessionExercise() {
    return SessionExercise(
      id: id,
      memorizationContent: rules.description,
      prompt: 'Choisis la case qui respecte les deux règles.',
      options: [
        for (var index = 0; index < tiles.length; index++)
          SessionAnswerOption(
            id: '$id-case-$index',
            label: _tileDescription(index, tiles[index]),
          ),
      ],
      correctOptionId: '$id-case-$correctTileIndex',
      explanation: explanation,
    );
  }

  String _tileDescription(int index, SpatialTile tile) {
    return 'Case ${index + 1} : ${tile.above.color.feminineLabel} '
        '${tile.above.direction.label}, au-dessus de '
        '${tile.below.color.feminineLabel} ${tile.below.direction.label}.';
  }
}
