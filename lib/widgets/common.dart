import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

/// Fine bande aux couleurs du drapeau de la RDC (bleu, jaune, rouge, jaune, bleu).
class FlagStripe extends StatelessWidget {
  const FlagStripe({super.key, this.height = 5});

  final double height;

  @override
  Widget build(BuildContext context) {
    Widget part(Color c, int flex) => Expanded(
      flex: flex,
      child: ColoredBox(color: c),
    );
    return SizedBox(
      height: height,
      child: Row(
        children: [
          part(const Color(0xFF3C8DDB), 10),
          part(AppColors.accent, 1),
          part(AppColors.red, 3),
          part(AppColors.accent, 1),
          part(const Color(0xFF3C8DDB), 10),
        ],
      ),
    );
  }
}

/// En-tête bleu nuit uni, terminé par la bande du drapeau.
class PageHeader extends StatelessWidget {
  const PageHeader({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.fromLTRB(20, 12, 20, 28),
  });

  final Widget child;
  final EdgeInsets padding;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: double.infinity,
          color: AppColors.primaryDark,
          child: SafeArea(
            bottom: false,
            child: Padding(padding: padding, child: child),
          ),
        ),
        const FlagStripe(),
      ],
    );
  }
}

/// Barre de titre posée sur l'en-tête.
class HeaderBar extends StatelessWidget {
  const HeaderBar({
    super.key,
    required this.title,
    this.leading,
    this.actions = const [],
  });

  final String title;
  final Widget? leading;
  final List<Widget> actions;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 48,
      child: Row(
        children: [
          if (leading != null) ...[leading!, const SizedBox(width: 8)],
          Expanded(
            child: Text(
              title,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.w800,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          ...actions,
        ],
      ),
    );
  }
}

/// Bouton discret pour les en-têtes.
class HeaderIconButton extends StatelessWidget {
  const HeaderIconButton({
    super.key,
    required this.icon,
    required this.onPressed,
    required this.tooltip,
  });

  final IconData icon;
  final VoidCallback? onPressed;
  final String tooltip;

  @override
  Widget build(BuildContext context) {
    return IconButton(
      tooltip: tooltip,
      onPressed: onPressed,
      style: IconButton.styleFrom(
        backgroundColor: Colors.white.withValues(alpha: 0.10),
        foregroundColor: Colors.white,
        disabledForegroundColor: Colors.white54,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
      icon: Icon(icon),
    );
  }
}

/// Photo ronde avec un liseré jaune, comme un portrait encadré.
class RingAvatar extends StatelessWidget {
  const RingAvatar({super.key, required this.radius, this.image, this.child});

  final double radius;
  final ImageProvider? image;
  final Widget? child;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(3),
      decoration: const BoxDecoration(
        shape: BoxShape.circle,
        color: AppColors.accent,
      ),
      child: Container(
        padding: const EdgeInsets.all(3),
        decoration: const BoxDecoration(
          shape: BoxShape.circle,
          color: AppColors.primaryDark,
        ),
        child: CircleAvatar(
          radius: radius,
          backgroundColor: AppColors.background,
          backgroundImage: image,
          child: child,
        ),
      ),
    );
  }
}

/// Texte « surligné au marqueur » jaune.
class Highlight extends StatelessWidget {
  const Highlight(this.text, {super.key, this.style});

  final String text;
  final TextStyle? style;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 2),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Colors.transparent,
            Colors.transparent,
            AppColors.accent.withValues(alpha: 0.55),
            AppColors.accent.withValues(alpha: 0.55),
          ],
          stops: const [0, 0.58, 0.58, 0.92],
        ),
      ),
      child: Text(text, style: style),
    );
  }
}

/// Carte blanche avec ombre décalée.
class PaperCard extends StatelessWidget {
  const PaperCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(18),
    this.onTap,
  });

  final Widget child;
  final EdgeInsets padding;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
        boxShadow: AppColors.handShadow,
      ),
      child: Material(
        type: MaterialType.transparency,
        child: InkWell(
          borderRadius: BorderRadius.circular(14),
          onTap: onTap,
          child: Padding(padding: padding, child: child),
        ),
      ),
    );
  }
}

/// Carte de section : icône + titre surligné + contenu.
class SectionCard extends StatelessWidget {
  const SectionCard({
    super.key,
    required this.icon,
    required this.title,
    required this.child,
    this.color = AppColors.primary,
  });

  final IconData icon;
  final String title;
  final Widget child;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return PaperCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 22),
              const SizedBox(width: 10),
              Flexible(
                child: Highlight(
                  title,
                  style: const TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          child,
        ],
      ),
    );
  }
}

/// Petit carré arrondi coloré contenant une icône.
class IconBadge extends StatelessWidget {
  const IconBadge({
    super.key,
    required this.icon,
    this.color = AppColors.primary,
    this.size = 40,
  });

  final IconData icon;
  final Color color;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(size * 0.28),
      ),
      child: Icon(icon, color: color, size: size * 0.52),
    );
  }
}

/// Petite étiquette colorée (ex. parenté).
class Tag extends StatelessWidget {
  const Tag(this.label, {super.key, this.color = AppColors.primary, this.icon});

  final String label;
  final Color color;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 13, color: color),
            const SizedBox(width: 4),
          ],
          Text(
            label,
            style: TextStyle(
              color: color,
              fontSize: 12.5,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

/// Indicateur de chargement pour les boutons.
class ButtonLoader extends StatelessWidget {
  const ButtonLoader({super.key});

  @override
  Widget build(BuildContext context) => const SizedBox(
    width: 22,
    height: 22,
    child: CircularProgressIndicator(strokeWidth: 2.5, color: Colors.white),
  );
}

/// SnackBar uniforme (succès / erreur / info).
void showAppMessage(
  BuildContext context,
  String text, {
  bool error = false,
  bool success = false,
}) {
  final color = error
      ? AppColors.danger
      : (success ? AppColors.success : AppColors.primaryDark);
  final icon = error
      ? Icons.error_outline
      : (success ? Icons.check_circle_outline : Icons.info_outline);
  ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(
      SnackBar(
        backgroundColor: color,
        content: Row(
          children: [
            Icon(icon, color: Colors.white),
            const SizedBox(width: 10),
            Expanded(child: Text(text)),
          ],
        ),
      ),
    );
}
