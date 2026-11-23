import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:cv_katembo_selemani_guy_leon/services/api_service.dart';

void main() {
  tearDown(() => debugDefaultTargetPlatformOverride = null);

  test('le fichier .env du projet contient les deux adresses', () {
    dotenv.loadFromString(envString: File('.env').readAsStringSync());
    expect(dotenv.get('API_URL'), 'http://localhost/api-test/public');
    expect(dotenv.get('API_URL_ANDROID'), 'http://10.0.2.2/api-test/public');
  });

  test('baseUrl utilise API_URL (web / Windows)', () {
    debugDefaultTargetPlatformOverride = TargetPlatform.windows;
    dotenv.loadFromString(
      envString: 'API_URL=http://192.168.1.10/api-test/public/\n'
          'API_URL_ANDROID=http://10.0.2.2/autre',
    );
    expect(ApiService.baseUrl, 'http://192.168.1.10/api-test/public');
  });

  test('baseUrl utilise API_URL_ANDROID sur Android', () {
    debugDefaultTargetPlatformOverride = TargetPlatform.android;
    dotenv.loadFromString(
      envString: 'API_URL=http://localhost/x\nAPI_URL_ANDROID=http://192.168.1.10/api',
    );
    expect(ApiService.baseUrl, 'http://192.168.1.10/api');
  });

  test('clé absente : adresse par défaut', () {
    debugDefaultTargetPlatformOverride = TargetPlatform.windows;
    dotenv.loadFromString(envString: 'AUTRE=1');
    expect(ApiService.baseUrl, 'http://localhost/api-test/public');
  });
}
