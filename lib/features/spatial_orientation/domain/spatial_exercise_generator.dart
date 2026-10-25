import 'dart:math';

import 'spatial_exercise.dart';

/// Génère des exercices d'orientation spatiale inédits.
///
/// Règles : six cases, une seule case respecte les deux règles (couleur et
/// direction de la flèche du haut / du bas), toutes les cases sont distinctes
/// et portent une flèche noire et une flèche jaune.
class SpatialExerciseGenerator {
  SpatialExerciseGenerator({Random? random}) : _random = random ?? Random();

  static const tileCount = 6;

  final Random _random;

  List<SpatialExercise> generate(
    int count, {
    String idPrefix = 'timed-spatial',
  }) {
    return [
      for (var index = 0; index < count; index++)
        generateOne('$idPrefix-${index + 1}'),
    ];
  }

  SpatialExercise generateOne(String id) {
    final rules = SpatialRules(
      colorAbove: _pick(ArrowColor.values),
      directionAbove: _pick(ArrowDirection.values),
      directionBelow: _pick(ArrowDirection.values),
    );
    final correctTile = SpatialTile(
      above: SpatialArrow(
        color: rules.colorAbove,
        direction: rules.directionAbove,
      ),
      below: SpatialArrow(
        color: rules.colorBelow,
        direction: rules.directionBelow,
      ),
    );

    final tiles = <SpatialTile>[correctTile];
    final seen = <String>{_key(correctTile)};
    while (tiles.length < tileCount) {
      final swapColors = _random.nextBool();
      final aboveColor = swapColors ? rules.colorBelow : rules.colorAbove;
      final tile = SpatialTile(
        above: SpatialArrow(
          color: aboveColor,
          direction: _pick(ArrowDirection.values),
        ),
        below: SpatialArrow(
          color: aboveColor == ArrowColor.black
              ? ArrowColor.yellow
              : ArrowColor.black,
          direction: _pick(ArrowDirection.values),
        ),
      );
      if (!rules.matches(tile) && seen.add(_key(tile))) tiles.add(tile);
    }

    tiles.shuffle(_random);
    return SpatialExercise(
      id: id,
      rules: rules,
      tiles: List.unmodifiable(tiles),
      correctTileIndex: tiles.indexOf(correctTile),
    );
  }

  String _key(SpatialTile tile) =>
      '${tile.above.color.name}-${tile.above.direction.name}-'
      '${tile.below.color.name}-${tile.below.direction.name}';

  T _pick<T>(List<T> values) => values[_random.nextInt(values.length)];
}
