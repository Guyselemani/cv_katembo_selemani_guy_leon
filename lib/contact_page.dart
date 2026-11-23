import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import 'theme/app_theme.dart';
import 'widgets/common.dart';

class ContactPage extends StatelessWidget {
  const ContactPage({super.key});

  Future<void> openLink(String value) async {
    final Uri uri = Uri.parse(value);

    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }

  @override
  Widget build(BuildContext context) {
    final contacts = [
      (
        Icons.phone_outlined,
        'Appelle-moi',
        '+243 994 297 702',
        'tel:+243994297702',
        AppColors.success,
      ),
      (
        Icons.mail_outline,
        'Écris-moi',
        'guylalanneselemanimus@gmail.com',
        'mailto:guylalanneselemanimus@gmail.com',
        AppColors.red,
      ),
      (
        Icons.location_on_outlined,
        'Je vis à',
        'Goma, Nord-Kivu, RDC',
        'https://maps.google.com/?q=Goma',
        AppColors.primary,
      ),
      (
        Icons.code,
        'Mon code sur GitHub',
        'Guyselemani',
        'https://github.com/Guyselemani',
        AppColors.primaryDark,
      ),
    ];

    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: [
            const PageHeader(
              padding: EdgeInsets.fromLTRB(20, 8, 20, 32),
              child: Column(
                children: [
                  HeaderBar(title: 'Mes coordonnées'),
                  SizedBox(height: 12),
                  RingAvatar(
                    radius: 40,
                    image: AssetImage('assets/profil.jpeg'),
                  ),
                  SizedBox(height: 14),
                  Text(
                    'Parlons ensemble',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  SizedBox(height: 6),
                  Text(
                    'Un projet, une idée, une opportunité pour les jeunes ?\nJe serai heureux d’en discuter avec toi.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 14.5,
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ),
            Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 720),
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 18, 16, 24),
                  child: Column(
                    children: [
                      for (final (icon, title, value, link, color)
                          in contacts) ...[
                        _ContactCard(
                          icon: icon,
                          title: title,
                          value: value,
                          color: color,
                          onTap: () => openLink(link),
                        ),
                        const SizedBox(height: 12),
                      ],
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ContactCard extends StatelessWidget {
  const _ContactCard({
    required this.icon,
    required this.title,
    required this.value,
    required this.color,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String value;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return PaperCard(
      onTap: onTap,
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          IconBadge(icon: icon, color: color, size: 48),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: AppColors.textMuted,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 15.5,
                    fontWeight: FontWeight.w700,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: AppColors.background,
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(
              Icons.arrow_outward,
              size: 18,
              color: AppColors.textMuted,
            ),
          ),
        ],
      ),
    );
  }
}
