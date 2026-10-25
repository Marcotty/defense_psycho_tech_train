import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:defense_psycho_tech_train/app/app.dart';

void main() {
  setUp(() => SharedPreferences.setMockInitialValues({}));

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
    expect(find.text('Commencer le test'), findsOneWidget);
  });

  testWidgets('history opens an honest empty state', (tester) async {
    await tester.pumpWidget(const BtcaApp());

    final historyButton = find.text('Historique et statistiques');
    await tester.ensureVisible(historyButton);
    await tester.tap(historyButton);
    await tester.pumpAndSettle();

    expect(find.text('Aucune session enregistrée'), findsOneWidget);
  });

  testWidgets('settings are reachable from the app menu', (tester) async {
    await tester.pumpWidget(const BtcaApp());
    await tester.tap(find.byTooltip('Open navigation menu'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Paramètres'));
    await tester.pumpAndSettle();

    expect(find.text('Apparence'), findsOneWidget);
    expect(find.text('Mode Test'), findsOneWidget);
    await tester.tap(find.text('Sombre'));
    await tester.pumpAndSettle();
    expect(
      Theme.of(tester.element(find.text('Apparence'))).brightness,
      Brightness.dark,
    );
    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pumpWidget(const BtcaApp());
    await tester.pumpAndSettle();
    expect(
      Theme.of(tester.element(find.text('BTCA'))).brightness,
      Brightness.dark,
    );
  });

  testWidgets('a configured timed test saves its result to history', (
    tester,
  ) async {
    await tester.pumpWidget(const BtcaApp());
    await tester.tap(find.text('Mode Test'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Aisance numérique'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Commencer le test'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Ouvrir les paramètres'));
    await tester.pumpAndSettle();
    final timeLimitField = find.byWidgetPredicate(
      (widget) =>
          widget is TextField &&
          widget.decoration?.labelText == 'Aisance numérique',
    );
    await tester.enterText(timeLimitField, '30');
    final saveDurationsButton = find.text('Enregistrer les durées');
    await tester.scrollUntilVisible(
      saveDurationsButton,
      300,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.tap(find.text('Enregistrer les durées'));
    await tester.pumpAndSettle();
    expect(find.text('Limites enregistrées.'), findsOneWidget);
    tester.testTextInput.hide();
    await tester.pump();
    await tester.pageBack();
    await tester.pump(const Duration(milliseconds: 500));
    await tester.pump();

    expect(find.text('Afficher la question'), findsOneWidget);
    while (find.text('Afficher la question').evaluate().isNotEmpty) {
      final memorized = tester
          .widgetList<Text>(find.byType(Text))
          .map((text) => text.data ?? '')
          .firstWhere(_expression.hasMatch);
      await tester.tap(find.text('Afficher la question'));
      await tester.pump();
      final prompt = tester
          .widgetList<Text>(find.byType(Text))
          .map((text) => text.data ?? '')
          .firstWhere((text) => text.startsWith('Compare le résultat'));
      final second = prompt.split('\n').last;
      final first = _evaluate(memorized);
      final other = _evaluate(second);
      final answer = first > other
          ? 'Haut'
          : first < other
          ? 'Bas'
          : 'Égal';
      await tester.tap(find.text(answer));
      await tester.pump();
    }

    expect(find.text('Test réussi'), findsOneWidget);
    await tester.pumpAndSettle();
    await tester.pageBack();
    await tester.pumpAndSettle();
    await tester.pageBack();
    await tester.pumpAndSettle();
    await tester.pageBack();
    await tester.pumpAndSettle();
    final historyButton = find.text('Historique et statistiques');
    await tester.ensureVisible(historyButton);
    await tester.tap(historyButton);
    await tester.pumpAndSettle();

    expect(find.text('Aisance numérique'), findsOneWidget);
    expect(find.text('Tests chronométrés réussis'), findsOneWidget);
    expect(find.text('1 / 1'), findsOneWidget);
  });
}

final _expression = RegExp(r'^(\d+) ([+−×÷]) (\d+)$');

int _evaluate(String expression) {
  final match = _expression.firstMatch(expression.trim())!;
  final left = int.parse(match.group(1)!);
  final right = int.parse(match.group(3)!);
  return switch (match.group(2)!) {
    '+' => left + right,
    '−' => left - right,
    '×' => left * right,
    _ => left ~/ right,
  };
}
