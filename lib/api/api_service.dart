import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';

import '../models/account.dart';
import '../models/famille_membre.dart';
import 'api_config.dart';

/// Erreur renvoyée par l'API (ou problème réseau).
class ApiException implements Exception {
  final String message;
  final int? statusCode;

  /// Erreurs de validation par champ (réponse 422).
  final Map<String, String> errors;

  ApiException(this.message, {this.statusCode, this.errors = const {}});

  /// Message complet, avec le détail des champs invalides s'il y en a.
  String get details =>
      errors.isEmpty ? message : '$message\n${errors.values.join('\n')}';

  @override
  String toString() => details;
}

/// Image choisie par l'utilisateur, prête à être envoyée en form-data.
class ImageUpload {
  final List<int> bytes;
  final String filename;

  const ImageUpload({required this.bytes, required this.filename});

  MediaType get mediaType {
    final ext = filename.split('.').last.toLowerCase();
    switch (ext) {
      case 'png':
        return MediaType('image', 'png');
      case 'gif':
        return MediaType('image', 'gif');
      case 'webp':
        return MediaType('image', 'webp');
      default:
        return MediaType('image', 'jpeg');
    }
  }
}

class ApiService {
  ApiService({http.Client? client}) : _client = client ?? http.Client();

  final http.Client _client;
  static const _timeout = Duration(seconds: 15);
  static const _jsonHeaders = {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
  };

  Uri _uri(String path) => Uri.parse('${ApiConfig.baseUrl}$path');

  // ---------------------------------------------------------------- Comptes

  Future<Account> register(String email, String password) async {
    final data = await _send(
      () => _client.post(
        _uri('/accounts/register'),
        headers: _jsonHeaders,
        body: jsonEncode({'email': email, 'password': password}),
      ),
    );
    return Account.fromJson(data as Map<String, dynamic>);
  }

  Future<Account> login(String email, String password) async {
    final data = await _send(
      () => _client.post(
        _uri('/accounts/login'),
        headers: _jsonHeaders,
        body: jsonEncode({'email': email, 'password': password}),
      ),
    );
    return Account.fromJson(data as Map<String, dynamic>);
  }

  // ----------------------------------------------------- Membres de famille

  Future<List<FamilleMembre>> getFamilleMembres() async {
    final data = await _send(
      () => _client.get(_uri('/famille-membres'), headers: _jsonHeaders),
    );
    final list = (data as List?) ?? const [];
    return list
        .map((e) => FamilleMembre.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  /// Crée un membre. Avec une image, l'envoi se fait en form-data,
  /// sinon en JSON.
  Future<FamilleMembre> createFamilleMembre(
    FamilleMembre membre, {
    ImageUpload? image,
  }) async {
    final data = image == null
        ? await _send(
            () => _client.post(
              _uri('/famille-membres'),
              headers: _jsonHeaders,
              body: jsonEncode(membre.toFields()),
            ),
          )
        : await _sendMultipart('/famille-membres', membre, image);
    return FamilleMembre.fromJson(data as Map<String, dynamic>);
  }

  /// Modifie un membre. Sans nouvelle image : PUT en JSON (l'image actuelle
  /// est conservée). Avec une nouvelle image : POST en form-data, car PHP ne
  /// lit pas les fichiers envoyés en PUT.
  Future<FamilleMembre> updateFamilleMembre(
    int id,
    FamilleMembre membre, {
    ImageUpload? image,
  }) async {
    final data = image == null
        ? await _send(
            () => _client.put(
              _uri('/famille-membres/$id'),
              headers: _jsonHeaders,
              body: jsonEncode(membre.toFields()),
            ),
          )
        : await _sendMultipart('/famille-membres/$id', membre, image);
    return FamilleMembre.fromJson(data as Map<String, dynamic>);
  }

  Future<void> deleteFamilleMembre(int id) async {
    await _send(
      () => _client.delete(_uri('/famille-membres/$id'), headers: _jsonHeaders),
    );
  }

  // -------------------------------------------------------------- Interne

  Future<dynamic> _sendMultipart(
    String path,
    FamilleMembre membre,
    ImageUpload image,
  ) {
    return _send(() async {
      final request = http.MultipartRequest('POST', _uri(path))
        ..headers['Accept'] = 'application/json'
        ..fields.addAll(membre.toFields())
        ..files.add(
          http.MultipartFile.fromBytes(
            'image',
            image.bytes,
            filename: image.filename,
            contentType: image.mediaType,
          ),
        );
      final streamed = await _client.send(request);
      return http.Response.fromStream(streamed);
    });
  }

  /// Exécute la requête, décode la réponse JSON et renvoie le champ `data`.
  /// Lève une [ApiException] si `success` vaut false ou en cas d'erreur.
  Future<dynamic> _send(Future<http.Response> Function() request) async {
    final http.Response response;
    try {
      response = await request().timeout(_timeout);
    } on TimeoutException {
      throw ApiException(
        "Le serveur ne répond pas (${ApiConfig.baseUrl}). "
        'Vérifiez qu\'Apache et MySQL sont démarrés.',
      );
    } catch (_) {
      throw ApiException(
        'Impossible de joindre l\'API (${ApiConfig.baseUrl}). '
        'Vérifiez l\'adresse et votre connexion.',
      );
    }

    Map<String, dynamic> body;
    try {
      body =
          jsonDecode(utf8.decode(response.bodyBytes)) as Map<String, dynamic>;
    } catch (_) {
      throw ApiException(
        'Réponse inattendue du serveur (code ${response.statusCode}).',
        statusCode: response.statusCode,
      );
    }

    final success = body['success'] == true;
    if (!success || response.statusCode >= 400) {
      final rawErrors = body['errors'];
      throw ApiException(
        (body['message'] ?? 'Erreur ${response.statusCode}').toString(),
        statusCode: response.statusCode,
        errors: rawErrors is Map
            ? rawErrors.map((k, v) => MapEntry(k.toString(), v.toString()))
            : const {},
      );
    }
    return body['data'];
  }
}
