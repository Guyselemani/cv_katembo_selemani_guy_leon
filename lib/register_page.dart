import 'package:flutter/material.dart';

import 'services/api_service.dart';
import 'theme/app_theme.dart';
import 'widgets/auth_layout.dart';
import 'widgets/common.dart';

/// Création de compte via POST /accounts/register.
/// En cas de succès, revient à l'écran de connexion avec l'email pré-rempli.
class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key, this.api});

  final ApiService? api;

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _formKey = GlobalKey<FormState>();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmController = TextEditingController();
  late final ApiService _api = widget.api ?? ApiService();

  bool obscurePassword = true;
  bool loading = false;
  Map<String, String> serverErrors = {};

  Future<void> register() async {
    setState(() => serverErrors = {});
    if (!_formKey.currentState!.validate()) return;

    setState(() => loading = true);
    try {
      final user = await _api.register(
        emailController.text.trim(),
        passwordController.text,
      );
      if (!mounted) return;
      showAppMessage(
        context,
        'Compte créé ! Tu peux te connecter maintenant.',
        success: true,
      );
      Navigator.pop(context, user.email);
    } on ApiException catch (e) {
      if (!mounted) return;
      setState(() => serverErrors = e.errors);
      _formKey.currentState!.validate();
      showAppMessage(context, e.message, error: true);
    } finally {
      if (mounted) setState(() => loading = false);
    }
  }

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    confirmController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final toggle = IconButton(
      tooltip: obscurePassword ? 'Afficher' : 'Masquer',
      icon: Icon(
        obscurePassword
            ? Icons.visibility_outlined
            : Icons.visibility_off_outlined,
      ),
      onPressed: () => setState(() => obscurePassword = !obscurePassword),
    );

    return AuthLayout(
      onBack: loading ? null : () => Navigator.pop(context),
      header: Column(
        children: [
          const RingAvatar(radius: 40, image: AssetImage('assets/profil.jpeg')),
          const SizedBox(height: 16),
          const Text(
            'Créer un compte',
            style: TextStyle(
              color: Colors.white,
              fontSize: 28,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            'Rejoins-moi : ça prend moins d’une minute.',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.white70, fontSize: 15),
          ),
        ],
      ),
      card: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Inscription',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 4),
            const Text(
              'Choisis ton email et un mot de passe.',
              style: TextStyle(color: AppColors.textMuted),
            ),
            const SizedBox(height: 22),

            TextFormField(
              controller: emailController,
              keyboardType: TextInputType.emailAddress,
              textInputAction: TextInputAction.next,
              decoration: const InputDecoration(
                labelText: 'Email',
                prefixIcon: Icon(Icons.alternate_email),
              ),
              validator: (value) {
                final v = value?.trim() ?? '';
                if (v.isEmpty) return "L'email est obligatoire";
                if (!RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(v)) {
                  return "L'adresse email n'est pas valide";
                }
                if (v.length > 100)
                  return "L'email ne doit pas dépasser 100 caractères";
                return serverErrors['email'];
              },
            ),

            const SizedBox(height: 16),

            TextFormField(
              controller: passwordController,
              obscureText: obscurePassword,
              textInputAction: TextInputAction.next,
              decoration: InputDecoration(
                labelText: 'Mot de passe',
                helperText: '6 caractères minimum',
                prefixIcon: const Icon(Icons.lock_outline),
                suffixIcon: toggle,
              ),
              validator: (value) {
                final v = value ?? '';
                if (v.isEmpty) return 'Le mot de passe est obligatoire';
                if (v.length < 6) {
                  return 'Le mot de passe doit contenir au moins 6 caractères';
                }
                return serverErrors['password'];
              },
            ),

            const SizedBox(height: 16),

            TextFormField(
              controller: confirmController,
              obscureText: obscurePassword,
              textInputAction: TextInputAction.done,
              onFieldSubmitted: (_) => loading ? null : register(),
              decoration: const InputDecoration(
                labelText: 'Confirmer le mot de passe',
                prefixIcon: Icon(Icons.verified_user_outlined),
              ),
              validator: (value) => value != passwordController.text
                  ? 'Les mots de passe ne correspondent pas'
                  : null,
            ),

            const SizedBox(height: 24),

            ElevatedButton(
              onPressed: loading ? null : register,
              child: loading
                  ? const ButtonLoader()
                  : const Text('Créer mon compte'),
            ),
          ],
        ),
      ),
      footer: Wrap(
        alignment: WrapAlignment.center,
        crossAxisAlignment: WrapCrossAlignment.center,
        children: [
          const Text(
            'Déjà un compte ?',
            style: TextStyle(color: AppColors.textMuted),
          ),
          TextButton(
            onPressed: loading ? null : () => Navigator.pop(context),
            child: const Text('Se connecter'),
          ),
        ],
      ),
    );
  }
}
