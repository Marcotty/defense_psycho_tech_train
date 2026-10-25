import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:defense_psycho_tech_train/app/app.dart';

void main() {
  setUp(() => SharedPreferences.setMockInitialValues({}));

  testWidgets('completes all six spatial orientation practice exercises', (
    tester,
  ) async {
    await tester.pumpWidget(const BtcaApp());

    await tester.tap(find.text('Mode Entraînement'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Orientation spatiale'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Commencer les exercices'));
    await tester.pumpAndSettle();

    const correctTiles = [4, 5, 6, 6, 4, 3];
    for (var index = 0; index < correctTiles.length; index++) {
      expect(find.textContaining('au-dessus'), findsOneWidget);
      await tester.tap(find.text('Je suis prêt'));
      await tester.pumpAndSettle();
      expect(
        find.text('Choisis la case qui respecte les deux règles.'),
        findsOneWidget,
      );
      expect(
        find.byWidgetPredicate(
          (widget) =>
              widget is Icon &&
              widget.icon == Icons.arrow_upward_rounded &&
              widget.color == Colors.white &&
              widget.size == 40,
        ),
        findsWidgets,
      );

      final correctTile = find.text('Case ${correctTiles[index]}');
      await tester.ensureVisible(correctTile);
      await tester.tap(correctTile);
      await tester.pumpAndSettle();
      expect(find.text('Bonne réponse'), findsOneWidget);

      if (index < correctTiles.length - 1) {
        await tester.tap(find.text('Question suivante'));
        await tester.pumpAndSettle();
      }
    }

    await tester.tap(find.text('Voir le bilan'));
    await tester.pumpAndSettle();

    expect(find.text('Session terminée'), findsOneWidget);
    expect(find.text('100 %'), findsOneWidget);
  });
}
