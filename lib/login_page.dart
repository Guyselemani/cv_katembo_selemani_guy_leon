import 'package:flutter/material.dart';

import 'api/api_service.dart';
import 'main_navigation.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final _api = ApiService();

  bool obscurePassword = true;
  bool isRegister = false;
  bool loading = false;

  /// Erreurs renvoyées par l'API pour chaque champ (422).
  Map<String, String> serverErrors = {};

  Future<void> submit() async {
    setState(() => serverErrors = {});
    if (!_formKey.currentState!.validate()) return;

    setState(() => loading = true);
    final email = emailController.text.trim();
    final password = passwordController.text;

    try {
      if (isRegister) {
        await _api.register(email, password);
      } else {
        await _api.login(email, password);
      }
      if (!mounted) return;
      if (isRegister) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Compte créé, bienvenue !')),
        );
      }
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const MainNavigation()),
      );
    } on ApiException catch (e) {
      if (!mounted) return;
      setState(() => serverErrors = e.errors);
      final message = switch (e.statusCode) {
        401 => 'Email ou mot de passe incorrect !',
        409 => 'Cet email est déjà utilisé.',
        _ => e.message,
      };
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(message)));
    } finally {
      if (mounted) setState(() => loading = false);
    }
  }

  String? validateEmail(String? value) {
    final v = value?.trim() ?? '';
    if (v.isEmpty) return 'L\'email est obligatoire';
    if (v.length > 100) return '100 caractères maximum';
    if (!RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(v)) {
      return 'Adresse email invalide';
    }
    return null;
  }

  String? validatePassword(String? value) {
    final v = value ?? '';
    if (v.isEmpty) return 'Le mot de passe est obligatoire';
    if (isRegister && v.length < 6) return '6 caractères minimum';
    return null;
  }

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(25),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const CircleAvatar(
                  radius: 50,
                  backgroundImage: AssetImage('assets/profil.jpeg'),
                ),
                const SizedBox(height: 20),
                Text(
                  isRegister ? 'Créer un compte' : 'Bienvenue !',
                  style: const TextStyle(
                    fontSize: 30,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  isRegister
                      ? 'Inscrivez-vous pour découvrir mon CV'
                      : 'Connectez-vous pour découvrir mon CV',
                ),
                const SizedBox(height: 35),

                TextFormField(
                  controller: emailController,
                  keyboardType: TextInputType.emailAddress,
                  autofillHints: const [AutofillHints.email],
                  validator: validateEmail,
                  decoration: InputDecoration(
                    labelText: 'Email',
                    prefixIcon: const Icon(Icons.email),
                    border: const OutlineInputBorder(),
                    errorText: serverErrors['email'],
                  ),
                ),

                const SizedBox(height: 20),

                TextFormField(
                  controller: passwordController,
                  obscureText: obscurePassword,
                  validator: validatePassword,
                  onFieldSubmitted: (_) => submit(),
                  decoration: InputDecoration(
                    labelText: 'Mot de passe',
                    prefixIcon: const Icon(Icons.lock),
                    border: const OutlineInputBorder(),
                    errorText: serverErrors['password'],
                    suffixIcon: IconButton(
                      icon: Icon(
                        obscurePassword
                            ? Icons.visibility
                            : Icons.visibility_off,
                      ),
                      onPressed: () {
                        setState(() {
                          obscurePassword = !obscurePassword;
                        });
                      },
                    ),
                  ),
                ),

                const SizedBox(height: 25),

                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: loading ? null : submit,
                    child: loading
                        ? const SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : Text(
                            isRegister ? 'Créer mon compte' : 'Se connecter',
                            style: const TextStyle(fontSize: 18),
                          ),
                  ),
                ),

                const SizedBox(height: 10),

                TextButton(
                  onPressed: loading
                      ? null
                      : () {
                          setState(() {
                            isRegister = !isRegister;
                            serverErrors = {};
                          });
                          _formKey.currentState?.reset();
                        },
                  child: Text(
                    isRegister
                        ? 'Déjà un compte ? Se connecter'
                        : 'Pas encore de compte ? S\'inscrire',
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
