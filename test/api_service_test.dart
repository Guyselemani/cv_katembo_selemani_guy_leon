import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

import 'package:cv_katembo_selemani_guy_leon/api/api_service.dart';
import 'package:cv_katembo_selemani_guy_leon/models/famille_membre.dart';

http.Response json(Object body, int status) => http.Response.bytes(
  utf8.encode(jsonEncode(body)),
  status,
  headers: {'content-type': 'application/json; charset=utf-8'},
);

const membre = FamilleMembre(
  nom: 'Baraka',
  postnom: 'Bigega',
  prenom: 'Papa',
  lieuNaissance: 'Goma',
  dateNaissance: '1970-05-12',
  parente: 'Père',
);

void main() {
  test('login renvoie le compte', () async {
    final api = ApiService(
      client: MockClient((req) async {
        expect(req.method, 'POST');
        expect(req.url.path, endsWith('/public/accounts/login'));
        expect(jsonDecode(req.body), {'email': 'a@b.com', 'password': 'x'});
        return json({
          'success': true,
          'message': 'Connexion réussie',
          'data': {'id': 1, 'email': 'a@b.com', 'created_at': '2026-11-20'},
        }, 200);
      }),
    );
    final account = await api.login('a@b.com', 'x');
    expect(account.id, 1);
    expect(account.email, 'a@b.com');
  });

  test('401 devient une ApiException', () async {
    final api = ApiService(
      client: MockClient(
        (_) async => json({
          'success': false,
          'message': 'Email ou mot de passe incorrect',
        }, 401),
      ),
    );
    expect(
      () => api.login('a@b.com', 'x'),
      throwsA(isA<ApiException>().having((e) => e.statusCode, 'code', 401)),
    );
  });

  test('422 expose les erreurs par champ', () async {
    final api = ApiService(
      client: MockClient(
        (_) async => json({
          'success': false,
          'message': 'Données invalides',
          'errors': {'nom': 'Le champ nom est obligatoire'},
        }, 422),
      ),
    );
    try {
      await api.createFamilleMembre(membre);
      fail('exception attendue');
    } on ApiException catch (e) {
      expect(e.errors['nom'], 'Le champ nom est obligatoire');
      expect(e.details, contains('Le champ nom est obligatoire'));
    }
  });

  test('liste des membres avec image_url', () async {
    final api = ApiService(
      client: MockClient(
        (_) async => json({
          'success': true,
          'message': 'ok',
          'data': [
            {
              'id': '3',
              'nom': 'Baraka',
              'postnom': 'Bigega',
              'prenom': 'Papa',
              'lieu_naissance': 'Goma',
              'date_naissance': '1970-05-12',
              'parente': 'Père',
              'image': null,
              'image_url': null,
            },
          ],
        }, 200),
      ),
    );
    final list = await api.getFamilleMembres();
    expect(list.single.id, 3);
    expect(list.single.parente, 'Père');
    expect(list.single.imageUrl, isNull);
  });

  test('modification sans image : PUT en JSON', () async {
    final api = ApiService(
      client: MockClient((req) async {
        expect(req.method, 'PUT');
        expect(req.url.path, endsWith('/famille-membres/7'));
        expect(req.headers['Content-Type'], startsWith('application/json'));
        expect(jsonDecode(req.body)['lieu_naissance'], 'Goma');
        return json({
          'success': true,
          'message': 'ok',
          'data': {...membre.toFields(), 'id': 7},
        }, 200);
      }),
    );
    final updated = await api.updateFamilleMembre(7, membre);
    expect(updated.id, 7);
  });

  test('modification avec image : POST en form-data', () async {
    final api = ApiService(
      client: MockClient((req) async {
        expect(req.method, 'POST');
        expect(req.url.path, endsWith('/famille-membres/7'));
        expect(req.headers['content-type'], startsWith('multipart/form-data'));
        final body = latin1.decode(req.bodyBytes);
        expect(body, contains('name="image"; filename="photo.png"'));
        expect(body, contains('content-type: image/png'));
        expect(body, contains('name="date_naissance"'));
        return json({
          'success': true,
          'message': 'ok',
          'data': {
            ...membre.toFields(),
            'id': 7,
            'image_url': 'http://localhost/x.png',
          },
        }, 200);
      }),
    );
    final updated = await api.updateFamilleMembre(
      7,
      membre,
      image: const ImageUpload(bytes: [1, 2, 3], filename: 'photo.png'),
    );
    expect(updated.imageUrl, 'http://localhost/x.png');
  });
}
