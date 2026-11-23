import 'package:flutter/foundation.dart';

/// Adresse de base de l'API PHP (le segment /public est obligatoire).
///
/// Par défaut :
/// - émulateur Android : http://10.0.2.2/api-test/public
///   (10.0.2.2 désigne le PC qui fait tourner l'émulateur) ;
/// - web, Windows, macOS, Linux, simulateur iOS : http://localhost/api-test/public.
///
/// Sur un vrai téléphone, utiliser l'adresse IP du PC sur le réseau local :
///   flutter run --dart-define=API_BASE_URL=http://192.168.1.10/api-test/public
class ApiConfig {
  static const String _fromEnv = String.fromEnvironment('API_BASE_URL');

  static String get baseUrl {
    if (_fromEnv.isNotEmpty) return _fromEnv;
    if (!kIsWeb && defaultTargetPlatform == TargetPlatform.android) {
      return 'http://10.0.2.2/api-test/public';
    }
    return 'http://localhost/api-test/public';
  }
}
