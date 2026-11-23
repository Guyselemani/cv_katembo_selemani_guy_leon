import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:cv_katembo_selemani_guy_leon/main.dart';

void main() {
  testWidgets('La page de connexion s\'affiche et bascule en inscription', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const MyApp());

    expect(find.text('Bienvenue !'), findsOneWidget);
    expect(find.text('Se connecter'), findsOneWidget);

    await tester.tap(find.text('Pas encore de compte ? S\'inscrire'));
    await tester.pump();

    expect(find.text('Créer un compte'), findsOneWidget);
    expect(find.text('Créer mon compte'), findsOneWidget);
  });

  testWidgets('Les champs vides sont refusés avant tout appel à l\'API', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const MyApp());

    await tester.tap(find.widgetWithText(ElevatedButton, 'Se connecter'));
    await tester.pump();

    expect(find.text('L\'email est obligatoire'), findsOneWidget);
    expect(find.text('Le mot de passe est obligatoire'), findsOneWidget);
  });
}
