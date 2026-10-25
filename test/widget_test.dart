import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:defense_psycho_tech_train/app/app.dart';

void main() {
  testWidgets('home offers the two training modes and history', (tester) async {
    await tester.pumpWidget(const BtcaApp());

    expect(find.text('Mode Entraînement'), findsOneWidget);
    expect(find.text('Mode Test'), findsOneWidget);
    expect(find.text('Historique et statistiques'), findsOneWidget);
  });

  testWidgets('practice mode opens the five-test selection', (tester) async {
    await tester.pumpWidget(const BtcaApp());

    await tester.tap(find.text('Mode Entraînement'));
    await tester.pumpAndSettle();

    expect(find.text('Choisis un test'), findsOneWidget);
    for (final title in [
      'Aisance numérique',
      'Orientation spatiale',
      'Mémoire des mots',
      'Raisonnement',
      'Détection d’erreurs',
    ]) {
      final testTitle = find.text(title);
      await tester.scrollUntilVisible(
        testTitle,
        250,
        scrollable: find.byType(Scrollable),
      );
      expect(testTitle, findsOneWidget);
    }
  });

  testWidgets('selecting a test opens its overview', (tester) async {
    await tester.pumpWidget(const BtcaApp());

    await tester.tap(find.text('Mode Test'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Aisance numérique'));
    await tester.pumpAndSettle();

    expect(find.text('Test chronométré'), findsOneWidget);
    expect(find.text('Déroulement'), findsOneWidget);
    expect(find.text('Contenu en préparation'), findsOneWidget);
  });

  testWidgets('history opens an honest empty state', (tester) async {
    await tester.pumpWidget(const BtcaApp());

    final historyButton = find.text('Historique et statistiques');
    await tester.ensureVisible(historyButton);
    await tester.tap(historyButton);
    await tester.pumpAndSettle();

    expect(find.text('Aucune session enregistrée'), findsOneWidget);
  });
}
