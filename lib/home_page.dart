import 'package:flutter/material.dart';

import 'login_page.dart';
import 'theme/app_theme.dart';
import 'widgets/common.dart';

/// Jaune foncé lisible sur fond clair (le jaune du drapeau est trop pâle pour du texte).
const _ochre = Color(0xFFA7780A);

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  Future<void> _logout(BuildContext context) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Tu pars déjà ?'),
        content: const Text('Tu reviendras à l’écran de connexion.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Rester'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Déconnexion'),
          ),
        ],
      ),
    );
    if (ok == true && context.mounted) {
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const LoginPage()),
        (_) => false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: [
            PageHeader(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 26),
              child: Column(
                children: [
                  HeaderBar(
                    title: 'Mon CV',
                    actions: [
                      HeaderIconButton(
                        icon: Icons.logout,
                        tooltip: 'Se déconnecter',
                        onPressed: () => _logout(context),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  const RingAvatar(
                    radius: 60,
                    image: AssetImage('assets/profil.jpeg'),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Karibu, moi c’est',
                    style: TextStyle(color: Colors.white70, fontSize: 15),
                  ),
                  const SizedBox(height: 2),
                  const Text(
                    'Katembo Selemani\nGuy Leon',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 27,
                      height: 1.15,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.star, color: AppColors.accent, size: 18),
                      SizedBox(width: 6),
                      Text(
                        'Jeune entrepreneur congolais',
                        style: TextStyle(
                          color: AppColors.accent,
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  const Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    alignment: WrapAlignment.center,
                    children: [
                      _HeaderChip(
                        icon: Icons.location_on_outlined,
                        label: 'Goma, RDC',
                      ),
                      _HeaderChip(
                        icon: Icons.school_outlined,
                        label: 'Étudiant à l’ISIG',
                      ),
                      _HeaderChip(icon: Icons.code, label: 'Flutter'),
                    ],
                  ),
                ],
              ),
            ),
            Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 720),
                child: const Padding(
                  padding: EdgeInsets.fromLTRB(16, 22, 16, 28),
                  child: _CvContent(),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CvContent extends StatelessWidget {
  const _CvContent();

  static const _gap = SizedBox(height: 16);
  static const _body = TextStyle(
    fontSize: 15,
    height: 1.6,
    color: Color(0xFF3A3F4B),
  );

  @override
  Widget build(BuildContext context) {
    return const Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _DreamCard(),
        _gap,
        SectionCard(
          icon: Icons.waving_hand_outlined,
          title: 'Qui suis-je ?',
          color: _ochre,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Je m’appelle Katembo Selemani Guy Leon. Je suis un jeune entrepreneur '
                'de la République démocratique du Congo, et j’étudie l’informatique à l’ISIG Goma.',
                style: _body,
              ),
              SizedBox(height: 10),
              Text(
                'J’en ai marre de voir des jeunes souffrir faute de travail. Mon rêve, c’est de '
                'devenir un grand PDG dans une ville de la RDC et de donner du travail à '
                'beaucoup de jeunes, ici et partout dans le monde.',
                style: _body,
              ),
              SizedBox(height: 10),
              Text(
                'Je veux être une vraie solution pour ma génération. Ce CV, c’est le début '
                'de cette histoire.',
                style: _body,
              ),
            ],
          ),
        ),
        _gap,
        SectionCard(
          icon: Icons.school_outlined,
          title: 'Formation',
          color: AppColors.primary,
          child: _TimelineItem(
            title: 'Informatique',
            subtitle: 'Études en informatique à l’ISIG Goma',
            period: '2023 – 2027',
            color: AppColors.primary,
            last: true,
          ),
        ),
        _gap,
        SectionCard(
          icon: Icons.work_outline,
          title: 'Expériences et projets',
          color: AppColors.red,
          child: Column(
            children: [
              _TimelineItem(
                title: 'Projet de développement',
                subtitle: 'Création de petits projets en HTML, CSS, JavaScript et Flutter.',
                color: AppColors.red,
              ),
              _TimelineItem(
                title: 'Projet professionnel',
                subtitle: 'Gestion et organisation d’activités de services.',
                color: AppColors.red,
                last: true,
              ),
            ],
          ),
        ),
        _gap,
        SectionCard(
          icon: Icons.code,
          title: 'Ce que je sais faire',
          color: AppColors.primaryDark,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _SubTitle('Programmation'),
              _ChipWrap(['HTML', 'CSS', 'JavaScript', 'Dart', 'Flutter']),
              SizedBox(height: 14),
              _SubTitle('Outils informatiques'),
              _ChipWrap(['Microsoft Word', 'Excel', 'Git', 'GitHub']),
            ],
          ),
        ),
        _gap,
        SectionCard(
          icon: Icons.translate,
          title: 'Langues',
          color: AppColors.success,
          child: Column(
            children: [
              _LanguageRow(language: 'Français', level: 'Bonne communication'),
              Divider(height: 20),
              _LanguageRow(language: 'Swahili', level: 'Bonne communication'),
            ],
          ),
        ),
        _gap,
        SectionCard(
          icon: Icons.favorite_outline,
          title: 'Ce que j’aime',
          color: AppColors.red,
          child: Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              _Interest(icon: Icons.computer, label: 'Informatique'),
              _Interest(icon: Icons.memory, label: 'Nouvelles technologies'),
              _Interest(icon: Icons.sports_soccer, label: 'Football'),
              _Interest(icon: Icons.music_note, label: 'Musique'),
            ],
          ),
        ),
        SizedBox(height: 28),
        _Signature(),
      ],
    );
  }
}

/// Carte « Mon rêve » : la citation de Guy, mise en avant.
class _DreamCard extends StatelessWidget {
  const _DreamCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.primaryDark,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: AppColors.accent.withValues(alpha: 0.9),
            offset: const Offset(5, 6),
          ),
        ],
      ),
      padding: const EdgeInsets.fromLTRB(20, 14, 20, 20),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '“',
            style: TextStyle(
              color: AppColors.accent,
              fontSize: 64,
              height: 0.9,
              fontWeight: FontWeight.w900,
            ),
          ),
          Text(
            'Mon rêve : devenir un grand PDG en RDC et donner du travail '
            'à beaucoup de jeunes de ce monde. Je veux être une solution.',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18.5,
              height: 1.45,
              fontStyle: FontStyle.italic,
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: 14),
          Row(
            children: [
              SizedBox(
                width: 22,
                child: Divider(color: AppColors.accent, thickness: 2),
              ),
              SizedBox(width: 8),
              Text(
                'Guy Leon',
                style: TextStyle(
                  color: AppColors.accent,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// Petit mot de fin, signé.
class _Signature extends StatelessWidget {
  const _Signature();

  @override
  Widget build(BuildContext context) {
    return const Column(
      children: [
        Text(
          'Merci d’avoir pris le temps de me lire.',
          textAlign: TextAlign.center,
          style: TextStyle(color: AppColors.textMuted, fontSize: 14.5),
        ),
        SizedBox(height: 10),
        Highlight(
          'Guy Leon',
          style: TextStyle(
            fontSize: 24,
            fontStyle: FontStyle.italic,
            fontWeight: FontWeight.w800,
            color: AppColors.primaryDark,
          ),
        ),
        SizedBox(height: 4),
        Text(
          'Goma, RDC',
          style: TextStyle(color: AppColors.textMuted, fontSize: 13),
        ),
        SizedBox(height: 14),
        SizedBox(width: 90, child: FlagStripe(height: 4)),
      ],
    );
  }
}

class _HeaderChip extends StatelessWidget {
  const _HeaderChip({required this.icon, required this.label});
  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 6),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.white30),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 15, color: Colors.white70),
          const SizedBox(width: 6),
          Text(
            label,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _TimelineItem extends StatelessWidget {
  const _TimelineItem({
    required this.title,
    required this.subtitle,
    required this.color,
    this.period,
    this.last = false,
  });

  final String title;
  final String subtitle;
  final String? period;
  final Color color;
  final bool last;

  @override
  Widget build(BuildContext context) {
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Column(
            children: [
              Container(
                margin: const EdgeInsets.only(top: 5),
                width: 10,
                height: 10,
                decoration: BoxDecoration(color: color, shape: BoxShape.circle),
              ),
              if (!last)
                Expanded(
                  child: Container(
                    width: 2,
                    margin: const EdgeInsets.symmetric(vertical: 3),
                    color: AppColors.border,
                  ),
                ),
            ],
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Padding(
              padding: EdgeInsets.only(bottom: last ? 0 : 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          title,
                          style: const TextStyle(
                            fontSize: 15.5,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                      if (period != null)
                        Text(
                          period!,
                          style: TextStyle(
                            color: color,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      color: AppColors.textMuted,
                      height: 1.45,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SubTitle extends StatelessWidget {
  const _SubTitle(this.text);
  final String text;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 8),
    child: Text(
      text,
      style: const TextStyle(
        color: AppColors.textMuted,
        fontWeight: FontWeight.w600,
        fontSize: 13.5,
      ),
    ),
  );
}

class _ChipWrap extends StatelessWidget {
  const _ChipWrap(this.items);
  final List<String> items;

  @override
  Widget build(BuildContext context) => Wrap(
    spacing: 8,
    runSpacing: 8,
    children: [
      for (final i in items)
        Chip(
          label: Text(i),
          materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
          visualDensity: VisualDensity.compact,
        ),
    ],
  );
}

class _LanguageRow extends StatelessWidget {
  const _LanguageRow({required this.language, required this.level});
  final String language;
  final String level;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(
            language,
            style: const TextStyle(fontSize: 15.5, fontWeight: FontWeight.w700),
          ),
        ),
        Text(level, style: const TextStyle(color: AppColors.textMuted)),
      ],
    );
  }
}

class _Interest extends StatelessWidget {
  const _Interest({required this.icon, required this.label});
  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 17, color: AppColors.red),
          const SizedBox(width: 8),
          Text(label, style: const TextStyle(fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}
