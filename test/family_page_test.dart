import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

import 'package:cv_katembo_selemani_guy_leon/family_page.dart';
import 'package:cv_katembo_selemani_guy_leon/membre_form_page.dart';
import 'package:cv_katembo_selemani_guy_leon/services/api_service.dart';

/// Faux serveur qui imite /famille-membres de l'API PHP.
class FakeFamilleServer {
  final membres = <int, Map<String, dynamic>>{
    1: {
      'id': 1,
      'nom': 'Musubao',
      'postnom': 'Christian',
      'prenom': 'Papa',
      'lieu_naissance': 'Goma',
      'date_naissance': '1970-05-12',
      'parente': 'Père',
      'image': null,
      'image_url': null,
    },
  };
  int nextId = 2;
  final requests = <String>[];

  http.Response _json(Map<String, dynamic> b, int code) => http.Response.bytes(
    utf8.encode(jsonEncode(b)),
    code,
    headers: {'content-type': 'application/json; charset=utf-8'},
  );

  late final client = MockClient((request) async {
    final path = request.url.path.replaceFirst('/api-test/public', '');
    requests.add('${request.method} $path');
    final id = int.tryParse(path.split('/').last);

    if (request.method == 'GET') {
      return _json({
        'success': true,
        'message': 'Liste',
        'data': membres.values.toList(),
      }, 200);
    }
    if (request.method == 'DELETE') {
      membres.remove(id);
      return _json({'success': true, 'message': 'Membre supprimé'}, 200);
    }
    final data = jsonDecode(request.body) as Map<String, dynamic>;
    if (request.method == 'POST') {
      final m = {...data, 'id': nextId, 'image': null, 'image_url': null};
      membres[nextId++] = m;
      return _json({'success': true, 'message': 'Membre créé', 'data': m}, 201);
    }
    // PUT
    final m = {...membres[id]!, ...data};
    membres[id!] = m;
    return _json({
      'success': true,
      'message': 'Membre modifié',
      'data': m,
    }, 200);
  });

  ApiService get api => ApiService(client: client);
}

void main() {
  late FakeFamilleServer server;

  setUp(() => server = FakeFamilleServer());

  Future<void> pumpFamily(WidgetTester tester) async {
    tester.view.physicalSize = const Size(800, 1600);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(MaterialApp(home: FamilyPage(api: server.api)));
    await tester.pumpAndSettle();
  }

  testWidgets('affiche les membres venant de l\'API', (tester) async {
    await pumpFamily(tester);
    expect(find.text('Papa Musubao Christian'), findsOneWidget);
    expect(find.textContaining('Né(e) le 12/05/1970 à Goma'), findsOneWidget);
  });

  testWidgets('ajouter un membre', (tester) async {
    await pumpFamily(tester);
    await tester.tap(find.text('Ajouter'));
    await tester.pumpAndSettle();
    expect(find.byType(MembreFormPage), findsOneWidget);

    // Champs vides -> erreurs
    await tester.tap(find.text('Ajouter le membre'));
    await tester.pumpAndSettle();
    expect(find.text('Le champ Nom est obligatoire'), findsOneWidget);
    expect(find.text('Choisissez la parenté'), findsOneWidget);

    final fields = find.byType(TextFormField);
    await tester.enterText(fields.at(0), 'Nabudukuli');
    await tester.enterText(fields.at(1), 'Mpaka');
    await tester.enterText(fields.at(2), 'Maman');
    await tester.enterText(fields.at(3), 'Bukavu');
    await tester.enterText(fields.at(4), '1975-02-14');
    await tester.tap(find.byType(DropdownButtonFormField<String>));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Mère').last);
    await tester.pumpAndSettle();

    await tester.tap(find.text('Ajouter le membre'));
    await tester.pumpAndSettle();

    expect(server.requests, contains('POST /famille-membres'));
    expect(server.membres[2]!['parente'], 'Mère');
    expect(find.byType(MembreFormPage), findsNothing);
    expect(find.text('Maman Nabudukuli Mpaka'), findsOneWidget);
  });

  testWidgets('modifier un membre (PUT, champs pré-remplis)', (tester) async {
    await pumpFamily(tester);
    await tester.tap(find.text('Papa Musubao Christian'));
    await tester.pumpAndSettle();
    expect(find.text('Modifier le membre'), findsOneWidget);
    expect(find.text('Goma'), findsOneWidget);

    await tester.enterText(find.byType(TextFormField).at(3), 'Kinshasa');
    await tester.tap(find.text('Enregistrer les modifications'));
    await tester.pumpAndSettle();

    expect(server.requests, contains('PUT /famille-membres/1'));
    expect(find.textContaining('à Kinshasa'), findsOneWidget);
  });

  testWidgets('supprimer un membre après confirmation', (tester) async {
    await pumpFamily(tester);
    await tester.tap(find.byTooltip('Actions'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Supprimer'));
    await tester.pumpAndSettle();
    expect(find.text('Supprimer ce membre ?'), findsOneWidget);

    // Annuler ne supprime rien
    await tester.tap(find.text('Annuler'));
    await tester.pumpAndSettle();
    expect(server.membres, contains(1));

    await tester.tap(find.byTooltip('Actions'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Supprimer'));
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(FilledButton, 'Supprimer'));
    await tester.pumpAndSettle();

    expect(server.requests, contains('DELETE /famille-membres/1'));
    expect(server.membres, isEmpty);
    expect(find.text('Aucun membre pour le moment'), findsOneWidget);
  });
}
