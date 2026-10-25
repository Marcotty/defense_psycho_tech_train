import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:defense_psycho_tech_train/app/app.dart';

void main() {
  setUp(() => SharedPreferences.setMockInitialValues({}));

  testWidgets('completes the three numerical practice examples', (
    tester,
  ) async {
    await tester.pumpWidget(const BtcaApp());

    await tester.tap(find.text('Mode Entraînement'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Aisance numérique'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Commencer les exercices'));
    await tester.pumpAndSettle();

    expect(find.text('3 × 7'), findsOneWidget);
    await tester.tap(find.text('Je suis prêt'));
    await tester.pumpAndSettle();
    expect(find.textContaining('19 − 1'), findsOneWidget);
    await tester.tap(find.text('Haut'));
    await tester.pumpAndSettle();
    expect(find.text('Bonne réponse'), findsOneWidget);
    expect(find.textContaining('3 × 7 = 21'), findsOneWidget);

    await tester.tap(find.text('Question suivante'));
    await tester.pumpAndSettle();
    expect(find.text('34 − 1'), findsOneWidget);
    await tester.tap(find.text('Je suis prêt'));
    await tester.pumpAndSettle();
    expect(find.textContaining('5 + 30'), findsOneWidget);
    await tester.tap(find.text('Bas'));
    await tester.pumpAndSettle();
    expect(find.textContaining('34 − 1 = 33'), findsOneWidget);

    await tester.tap(find.text('Question suivante'));
    await tester.pumpAndSettle();
    expect(find.text('4 × 3'), findsOneWidget);
    await tester.tap(find.text('Je suis prêt'));
    await tester.pumpAndSettle();
    expect(find.textContaining('9 + 3'), findsOneWidget);
    await tester.tap(find.text('Égal'));
    await tester.pumpAndSettle();
    expect(
      find.textContaining('Les deux résultats sont égaux.'),
      findsOneWidget,
    );

    await tester.tap(find.text('Voir le bilan'));
    await tester.pumpAndSettle();

    expect(find.text('Session terminée'), findsOneWidget);
    expect(find.text('Exactitude'), findsOneWidget);
    expect(find.text('100 %'), findsOneWidget);
  });
}
