import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

import 'package:cv_katembo_selemani_guy_leon/login_page.dart';
import 'package:cv_katembo_selemani_guy_leon/main_navigation.dart';
import 'package:cv_katembo_selemani_guy_leon/register_page.dart';
import 'package:cv_katembo_selemani_guy_leon/services/api_service.dart';

/// Faux serveur qui imite l'API PHP (/accounts/login et /accounts/register).
ApiService fakeApi() {
  final accounts = <String, String>{'test@exemple.com': 'secret123'};
  final client = MockClient((request) async {
    final body = jsonDecode(request.body) as Map<String, dynamic>;
    final email = body['email'] as String;
    final password = body['password'] as String;
    http.Response json(Map<String, dynamic> b, int code) => http.Response.bytes(
      utf8.encode(jsonEncode(b)),
      code,
      headers: {'content-type': 'application/json; charset=utf-8'},
    );
    final user = {'id': 1, 'email': email, 'created_at': '2026-11-23 20:00:00'};

    if (request.url.path.endsWith('/accounts/login')) {
      if (accounts[email] == password) {
        return json({
          'success': true,
          'message': 'Connexion réussie',
          'data': user,
        }, 200);
      }
      return json({
        'success': false,
        'message': 'Email ou mot de passe incorrect',
      }, 401);
    }
    if (accounts.containsKey(email)) {
      return json({
        'success': false,
        'message': 'Email déjà utilisé',
        'errors': {'email': 'Cet email est déjà utilisé'},
      }, 409);
    }
    accounts[email] = password;
    return json({'success': true, 'message': 'Compte créé', 'data': user}, 201);
  });
  return ApiService(client: client);
}

Future<void> pumpLogin(WidgetTester tester) async {
  await tester.pumpWidget(MaterialApp(home: LoginPage(api: fakeApi())));
}

void main() {
  testWidgets('champs vides : erreurs de validation', (tester) async {
    await pumpLogin(tester);
    await tester.ensureVisible(find.text('Se connecter'));
    await tester.tap(find.text('Se connecter'));
    await tester.pump();
    expect(find.text("L'email est obligatoire"), findsOneWidget);
    expect(find.text('Le mot de passe est obligatoire'), findsOneWidget);
  });

  testWidgets('mauvais mot de passe : message de l\'API', (tester) async {
    await pumpLogin(tester);
    await tester.enterText(
      find.byType(TextFormField).at(0),
      'test@exemple.com',
    );
    await tester.enterText(find.byType(TextFormField).at(1), 'faux');
    await tester.ensureVisible(find.text('Se connecter'));
    await tester.tap(find.text('Se connecter'));
    await tester.pumpAndSettle();
    expect(find.text('Email ou mot de passe incorrect'), findsOneWidget);
    expect(find.byType(MainNavigation), findsNothing);
  });

  testWidgets('bons identifiants : ouvre le CV', (tester) async {
    await pumpLogin(tester);
    await tester.enterText(
      find.byType(TextFormField).at(0),
      'test@exemple.com',
    );
    await tester.enterText(find.byType(TextFormField).at(1), 'secret123');
    await tester.ensureVisible(find.text('Se connecter'));
    await tester.tap(find.text('Se connecter'));
    await tester.pumpAndSettle();
    expect(find.byType(MainNavigation), findsOneWidget);
  });

  testWidgets('inscription puis retour à la connexion avec email pré-rempli', (
    tester,
  ) async {
    await pumpLogin(tester);
    await tester.ensureVisible(find.text('Créer un compte'));
    await tester.tap(find.text('Créer un compte'));
    await tester.pumpAndSettle();
    expect(find.byType(RegisterPage), findsOneWidget);

    final fields = find.byType(TextFormField);
    await tester.enterText(fields.at(0), 'nouveau@exemple.com');
    await tester.enterText(fields.at(1), '123');
    await tester.enterText(fields.at(2), '456');
    await tester.ensureVisible(find.text('Créer mon compte'));
    await tester.tap(find.text('Créer mon compte'));
    await tester.pump();
    expect(
      find.text('Le mot de passe doit contenir au moins 6 caractères'),
      findsOneWidget,
    );
    expect(find.text('Les mots de passe ne correspondent pas'), findsOneWidget);

    await tester.enterText(fields.at(1), 'secret123');
    await tester.enterText(fields.at(2), 'secret123');
    await tester.tap(find.text('Créer mon compte'));
    await tester.pumpAndSettle();

    expect(find.byType(RegisterPage), findsNothing);
    expect(find.text('nouveau@exemple.com'), findsOneWidget);
  });

  testWidgets('inscription avec un email déjà utilisé : erreur 409', (
    tester,
  ) async {
    await pumpLogin(tester);
    await tester.ensureVisible(find.text('Créer un compte'));
    await tester.tap(find.text('Créer un compte'));
    await tester.pumpAndSettle();
    final fields = find.byType(TextFormField);
    await tester.enterText(fields.at(0), 'test@exemple.com');
    await tester.enterText(fields.at(1), 'secret123');
    await tester.enterText(fields.at(2), 'secret123');
    await tester.ensureVisible(find.text('Créer mon compte'));
    await tester.tap(find.text('Créer mon compte'));
    await tester.pumpAndSettle();
    expect(find.text('Cet email est déjà utilisé'), findsOneWidget);
    expect(find.byType(RegisterPage), findsOneWidget);
  });
}
