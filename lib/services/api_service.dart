import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart' show MediaType;

/// Utilisateur connecté, tel que renvoyé par l'API.
class User {
  final int id;
  final String email;
  final String createdAt;

  const User({required this.id, required this.email, required this.createdAt});

  factory User.fromJson(Map<String, dynamic> json) => User(
    id: int.parse(json['id'].toString()),
    email: json['email'] as String,
    createdAt: (json['created_at'] ?? '').toString(),
  );
}

/// Erreur renvoyée par l'API (message général + erreurs par champ).
class ApiException implements Exception {
  final String message;
  final int? statusCode;
  final Map<String, String> errors;

  const ApiException(this.message, {this.statusCode, this.errors = const {}});

  @override
  String toString() => message;
}

/// Accès aux endpoints /accounts de l'API PHP (dossier api-test).
class ApiService {
  ApiService({http.Client? client}) : _client = client ?? http.Client();

  final http.Client _client;

  /// URL de base de l'API, lue dans le fichier .env :
  /// - API_URL : Web (Chrome/Edge) et Windows ;
  /// - API_URL_ANDROID : émulateur ou téléphone Android.
  /// Si .env n'est pas chargé (tests) ou si la clé manque, valeurs par défaut.
  static String get baseUrl {
    final android = !kIsWeb && defaultTargetPlatform == TargetPlatform.android;
    final fromEnv = dotenv.isInitialized
        ? dotenv.maybeGet(android ? 'API_URL_ANDROID' : 'API_URL')
        : null;
    final url = (fromEnv != null && fromEnv.trim().isNotEmpty)
        ? fromEnv.trim()
        : (android
              ? 'http://10.0.2.2/api-test/public'
              : 'http://localhost/api-test/public');
    return url.endsWith('/') ? url.substring(0, url.length - 1) : url;
  }

  /// POST /accounts/register
  Future<User> register(String email, String password) =>
      _postAccount('/accounts/register', email, password);

  /// POST /accounts/login
  Future<User> login(String email, String password) =>
      _postAccount('/accounts/login', email, password);

  Future<User> _postAccount(String path, String email, String password) async {
    final body = await _send(
      _client.post(
        Uri.parse('$baseUrl$path'),
        headers: _jsonHeaders,
        body: jsonEncode({'email': email, 'password': password}),
      ),
    );
    return User.fromJson(body['data'] as Map<String, dynamic>);
  }

  // ------------------------------------------------------------------
  // Membres de famille : /famille-membres
  // ------------------------------------------------------------------

  /// GET /famille-membres
  Future<List<FamilleMembre>> getMembres() async {
    final body = await _send(
      _client.get(Uri.parse('$baseUrl/famille-membres')),
    );
    return (body['data'] as List)
        .map((m) => FamilleMembre.fromJson(m as Map<String, dynamic>))
        .toList();
  }

  /// POST /famille-membres : JSON sans image, form-data avec image.
  Future<FamilleMembre> createMembre(
    FamilleMembre membre, {
    PickedImage? image,
  }) => image == null
      ? _sendMembreJson('POST', '/famille-membres', membre)
      : _sendMembreMultipart('/famille-membres', membre, image);

  /// Modification : PUT en JSON si l'image ne change pas (elle est conservée),
  /// POST /famille-membres/{id} en form-data pour remplacer l'image.
  Future<FamilleMembre> updateMembre(
    FamilleMembre membre, {
    PickedImage? image,
  }) => image == null
      ? _sendMembreJson('PUT', '/famille-membres/${membre.id}', membre)
      : _sendMembreMultipart('/famille-membres/${membre.id}', membre, image);

  /// DELETE /famille-membres/{id} (supprime aussi l'image sur le serveur)
  Future<void> deleteMembre(int id) async {
    await _send(_client.delete(Uri.parse('$baseUrl/famille-membres/$id')));
  }

  Future<FamilleMembre> _sendMembreJson(
    String method,
    String path,
    FamilleMembre membre,
  ) async {
    final uri = Uri.parse('$baseUrl$path');
    final payload = jsonEncode(membre.toFields());
    final body = await _send(
      method == 'PUT'
          ? _client.put(uri, headers: _jsonHeaders, body: payload)
          : _client.post(uri, headers: _jsonHeaders, body: payload),
    );
    return FamilleMembre.fromJson(body['data'] as Map<String, dynamic>);
  }

  Future<FamilleMembre> _sendMembreMultipart(
    String path,
    FamilleMembre membre,
    PickedImage image,
  ) async {
    final request = http.MultipartRequest('POST', Uri.parse('$baseUrl$path'))
      ..fields.addAll(membre.toFields())
      ..files.add(
        http.MultipartFile.fromBytes(
          'image',
          image.bytes,
          filename: image.name,
          contentType: MediaType.parse(image.mimeType),
        ),
      );
    final body = await _send(
      _client.send(request).then(http.Response.fromStream),
      timeout: const Duration(seconds: 30),
    );
    return FamilleMembre.fromJson(body['data'] as Map<String, dynamic>);
  }

  // ------------------------------------------------------------------

  static const _jsonHeaders = {
    'Content-Type': 'application/json; charset=utf-8',
  };

  /// Envoie la requête, décode le JSON et lève [ApiException] en cas d'erreur.
  Future<Map<String, dynamic>> _send(
    Future<http.Response> request, {
    Duration timeout = const Duration(seconds: 10),
  }) async {
    final http.Response response;
    try {
      response = await request.timeout(timeout);
    } on TimeoutException {
      throw const ApiException(
        "Le serveur ne répond pas. Vérifiez qu'Apache est démarré dans XAMPP.",
      );
    } catch (_) {
      throw const ApiException(
        "Impossible de joindre l'API. Vérifiez qu'Apache et MySQL sont démarrés dans XAMPP.",
      );
    }

    Map<String, dynamic> body;
    try {
      body =
          jsonDecode(utf8.decode(response.bodyBytes)) as Map<String, dynamic>;
    } catch (_) {
      throw ApiException(
        'Réponse invalide du serveur (code ${response.statusCode}).',
        statusCode: response.statusCode,
      );
    }

    if (body['success'] == true) return body;

    final rawErrors = body['errors'];
    throw ApiException(
      (body['message'] ?? 'Erreur inconnue').toString(),
      statusCode: response.statusCode,
      errors: rawErrors is Map
          ? rawErrors.map((k, v) => MapEntry(k.toString(), v.toString()))
          : const {},
    );
  }
}

/// Image choisie dans la galerie, prête à être envoyée.
class PickedImage {
  final Uint8List bytes;
  final String name;

  const PickedImage({required this.bytes, required this.name});

  String get mimeType {
    final ext = name.split('.').last.toLowerCase();
    return switch (ext) {
      'png' => 'image/png',
      'gif' => 'image/gif',
      'webp' => 'image/webp',
      _ => 'image/jpeg',
    };
  }
}

/// Membre de famille (table famille_membre).
class FamilleMembre {
  final int? id;
  final String nom;
  final String postnom;
  final String prenom;
  final String lieuNaissance;
  final String dateNaissance; // AAAA-MM-JJ
  final String parente;
  final String? imageUrl;

  const FamilleMembre({
    this.id,
    required this.nom,
    required this.postnom,
    required this.prenom,
    required this.lieuNaissance,
    required this.dateNaissance,
    required this.parente,
    this.imageUrl,
  });

  String get nomComplet => '$prenom $nom $postnom';

  factory FamilleMembre.fromJson(Map<String, dynamic> json) => FamilleMembre(
    id: int.parse(json['id'].toString()),
    nom: json['nom'].toString(),
    postnom: json['postnom'].toString(),
    prenom: json['prenom'].toString(),
    lieuNaissance: json['lieu_naissance'].toString(),
    dateNaissance: json['date_naissance'].toString(),
    parente: json['parente'].toString(),
    imageUrl: json['image_url']?.toString(),
  );

  /// Champs attendus par l'API (création et modification).
  Map<String, String> toFields() => {
    'nom': nom,
    'postnom': postnom,
    'prenom': prenom,
    'lieu_naissance': lieuNaissance,
    'date_naissance': dateNaissance,
    'parente': parente,
  };
}
