import 'package:flutter_test/flutter_test.dart';
import 'package:defense_psycho_tech_train/features/spatial_orientation/domain/spatial_exercise.dart';

void main() {
  test(
    'matches only the tile with both required color and direction order',
    () {
      const rules = SpatialRules(
        colorAbove: ArrowColor.black,
        directionAbove: ArrowDirection.upRight,
        directionBelow: ArrowDirection.downRight,
      );
      const matchingTile = SpatialTile(
        above: SpatialArrow(
          color: ArrowColor.black,
          direction: ArrowDirection.upRight,
        ),
        below: SpatialArrow(
          color: ArrowColor.yellow,
          direction: ArrowDirection.downRight,
        ),
      );
      const wrongColor = SpatialTile(
        above: SpatialArrow(
          color: ArrowColor.yellow,
          direction: ArrowDirection.upRight,
        ),
        below: SpatialArrow(
          color: ArrowColor.black,
          direction: ArrowDirection.downRight,
        ),
      );
      const wrongDirection = SpatialTile(
        above: SpatialArrow(
          color: ArrowColor.black,
          direction: ArrowDirection.downLeft,
        ),
        below: SpatialArrow(
          color: ArrowColor.yellow,
          direction: ArrowDirection.downRight,
        ),
      );

      expect(rules.matches(matchingTile), isTrue);
      expect(rules.matches(wrongColor), isFalse);
      expect(rules.matches(wrongDirection), isFalse);
    },
  );

  test(
    'exposes accessible tile descriptions and the correct session answer',
    () {
      const exercise = SpatialExercise(
        id: 'sample',
        rules: SpatialRules(
          colorAbove: ArrowColor.yellow,
          directionAbove: ArrowDirection.upLeft,
          directionBelow: ArrowDirection.upLeft,
        ),
        tiles: [
          SpatialTile(
            above: SpatialArrow(
              color: ArrowColor.yellow,
              direction: ArrowDirection.upLeft,
            ),
            below: SpatialArrow(
              color: ArrowColor.black,
              direction: ArrowDirection.upLeft,
            ),
          ),
        ],
        correctTileIndex: 0,
      );

      final sessionExercise = exercise.toSessionExercise();

      expect(sessionExercise.memorizationContent, contains('Jaune au-dessus'));
      expect(sessionExercise.correctOptionId, 'sample-case-0');
      expect(sessionExercise.options.single.label, contains('Case 1'));
      expect(sessionExercise.options.single.label, contains('haut à gauche'));
    },
  );
}
