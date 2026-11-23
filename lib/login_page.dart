import 'package:flutter/material.dart';

import 'main_navigation.dart';
import 'register_page.dart';
import 'services/api_service.dart';
import 'theme/app_theme.dart';
import 'widgets/auth_layout.dart';
import 'widgets/common.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key, this.api});

  /// Permet d'injecter un faux service dans les tests.
  final ApiService? api;

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  late final ApiService _api = widget.api ?? ApiService();

  bool obscurePassword = true;
  bool loading = false;
  Map<String, String> serverErrors = {};

  Future<void> login() async {
    setState(() => serverErrors = {});
    if (!_formKey.currentState!.validate()) return;

    setState(() => loading = true);
    try {
      final user = await _api.login(
        emailController.text.trim(),
        passwordController.text,
      );
      if (!mounted) return;
      showAppMessage(
        context,
        'Content de te voir, ${user.email} !',
        success: true,
      );
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const MainNavigation()),
      );
    } on ApiException catch (e) {
      if (!mounted) return;
      setState(() => serverErrors = e.errors);
      _formKey.currentState!.validate();
      showAppMessage(context, e.message, error: true);
    } finally {
      if (mounted) setState(() => loading = false);
    }
  }

  Future<void> openRegister() async {
    final email = await Navigator.push<String>(
      context,
      MaterialPageRoute(builder: (context) => RegisterPage(api: _api)),
    );
    if (email != null && mounted) {
      emailController.text = email;
      passwordController.clear();
    }
  }

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AuthLayout(
      header: const Column(
        children: [
          SizedBox(height: 8),
          RingAvatar(radius: 52, image: AssetImage('assets/profil.jpeg')),
          SizedBox(height: 16),
          Text(
            'Karibu !',
            style: TextStyle(
              color: Colors.white,
              fontSize: 32,
              fontWeight: FontWeight.w800,
            ),
          ),
          SizedBox(height: 4),
          Text(
            'Bienvenue chez moi. Connecte-toi pour\ndécouvrir mon parcours et mon rêve.',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.white70, fontSize: 15, height: 1.4),
          ),
        ],
      ),
      card: Form(
        key: _formKey,
        child: AutofillGroup(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                'Connexion',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800),
              ),
              const SizedBox(height: 4),
              const Text(
                'Ton email, ton mot de passe, et c’est parti.',
                style: TextStyle(color: AppColors.textMuted),
              ),
              const SizedBox(height: 22),

              TextFormField(
                controller: emailController,
                keyboardType: TextInputType.emailAddress,
                textInputAction: TextInputAction.next,
                autofillHints: const [AutofillHints.email],
                decoration: const InputDecoration(
                  labelText: 'Email',
                  prefixIcon: Icon(Icons.alternate_email),
                ),
                validator: (value) {
                  final v = value?.trim() ?? '';
                  if (v.isEmpty) return "L'email est obligatoire";
                  if (!v.contains('@'))
                    return "L'adresse email n'est pas valide";
                  return serverErrors['email'];
                },
              ),

              const SizedBox(height: 16),

              TextFormField(
                controller: passwordController,
                obscureText: obscurePassword,
                textInputAction: TextInputAction.done,
                autofillHints: const [AutofillHints.password],
                onFieldSubmitted: (_) => loading ? null : login(),
                decoration: InputDecoration(
                  labelText: 'Mot de passe',
                  prefixIcon: const Icon(Icons.lock_outline),
                  suffixIcon: IconButton(
                    tooltip: obscurePassword ? 'Afficher' : 'Masquer',
                    icon: Icon(
                      obscurePassword
                          ? Icons.visibility_outlined
                          : Icons.visibility_off_outlined,
                    ),
                    onPressed: () =>
                        setState(() => obscurePassword = !obscurePassword),
                  ),
                ),
                validator: (value) {
                  if ((value ?? '').isEmpty)
                    return 'Le mot de passe est obligatoire';
                  return serverErrors['password'];
                },
              ),

              const SizedBox(height: 24),

              ElevatedButton(
                onPressed: loading ? null : login,
                child: loading
                    ? const ButtonLoader()
                    : const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text('Se connecter'),
                          SizedBox(width: 8),
                          Icon(Icons.arrow_forward, size: 20),
                        ],
                      ),
              ),
            ],
          ),
        ),
      ),
      footer: Wrap(
        alignment: WrapAlignment.center,
        crossAxisAlignment: WrapCrossAlignment.center,
        children: [
          const Text(
            'Pas encore de compte ?',
            style: TextStyle(color: AppColors.textMuted),
          ),
          TextButton(
            onPressed: loading ? null : openRegister,
            child: const Text('Créer un compte'),
          ),
        ],
      ),
    );
  }
}
