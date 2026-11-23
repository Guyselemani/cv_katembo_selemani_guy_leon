import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

import 'login_page.dart';
import 'theme/app_theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Charge la configuration (adresse de l'API). Si le fichier .env est
  // absent ou vide, l'application utilise les adresses par défaut.
  try {
    await dotenv.load(fileName: '.env');
  } catch (e) {
    debugPrint('Fichier .env introuvable, adresses par défaut utilisées ($e)');
  }
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'CV Katembo Selemani Guy Leon',
      theme: AppTheme.light,
      home: const LoginPage(),
    );
  }
}
