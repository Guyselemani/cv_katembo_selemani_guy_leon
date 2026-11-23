import 'package:flutter/material.dart';

import '../theme/app_theme.dart';
import 'common.dart';

/// Mise en page des écrans de connexion / inscription :
/// bandeau bleu nuit en haut avec la bande du drapeau, carte « papier » par-dessus.
class AuthLayout extends StatelessWidget {
  const AuthLayout({
    super.key,
    required this.header,
    required this.card,
    this.footer,
    this.onBack,
  });

  final Widget header;
  final Widget card;
  final Widget? footer;
  final VoidCallback? onBack;

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.sizeOf(context).height;
    final bandHeight = (height * 0.40).clamp(290.0, 380.0);

    return Scaffold(
      body: Stack(
        children: [
          Container(height: bandHeight, color: AppColors.primaryDark),
          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 440),
                  child: Column(
                    children: [
                      if (onBack != null)
                        Align(
                          alignment: Alignment.centerLeft,
                          child: HeaderIconButton(
                            icon: Icons.arrow_back,
                            tooltip: 'Retour',
                            onPressed: onBack,
                          ),
                        ),
                      header,
                      const SizedBox(height: 24),
                      Container(
                        clipBehavior: Clip.antiAlias,
                        decoration: BoxDecoration(
                          color: AppColors.surface,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: AppColors.border),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.primaryDark.withValues(
                                alpha: 0.18,
                              ),
                              offset: const Offset(5, 6),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            const FlagStripe(height: 6),
                            Padding(
                              padding: const EdgeInsets.fromLTRB(
                                22,
                                22,
                                22,
                                22,
                              ),
                              child: card,
                            ),
                          ],
                        ),
                      ),
                      if (footer != null) ...[
                        const SizedBox(height: 16),
                        footer!,
                      ],
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
