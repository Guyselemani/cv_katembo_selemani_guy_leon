import 'package:flutter/material.dart';

import 'membre_form_page.dart';
import 'services/api_service.dart';
import 'theme/app_theme.dart';
import 'widgets/common.dart';

/// Liste des membres de famille, chargés depuis l'API (table famille_membre),
/// avec ajout, modification et suppression.
class FamilyPage extends StatefulWidget {
  const FamilyPage({super.key, this.api});

  /// Permet d'injecter un faux service dans les tests.
  final ApiService? api;

  @override
  State<FamilyPage> createState() => _FamilyPageState();
}

class _FamilyPageState extends State<FamilyPage> {
  late final ApiService _api = widget.api ?? ApiService();

  List<FamilleMembre> membres = [];
  bool loading = true;
  String? error;

  @override
  void initState() {
    super.initState();
    charger();
  }

  Future<void> charger() async {
    setState(() {
      loading = true;
      error = null;
    });
    try {
      final liste = await _api.getMembres();
      if (!mounted) return;
      setState(() => membres = liste);
    } on ApiException catch (e) {
      if (!mounted) return;
      setState(() => error = e.message);
    } finally {
      if (mounted) setState(() => loading = false);
    }
  }

  Future<void> ouvrirFormulaire([FamilleMembre? membre]) async {
    final saved = await Navigator.push<FamilleMembre>(
      context,
      MaterialPageRoute(
        builder: (_) => MembreFormPage(api: _api, membre: membre),
      ),
    );
    if (saved == null || !mounted) return;
    showAppMessage(
      context,
      membre == null
          ? '${saved.prenom} a été ajouté(e)'
          : '${saved.prenom} a été modifié(e)',
      success: true,
    );
    await charger();
  }

  Future<void> supprimer(FamilleMembre membre) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        icon: const Icon(
          Icons.delete_outline,
          color: AppColors.danger,
          size: 32,
        ),
        title: const Text('Supprimer ce membre ?'),
        content: Text(
          '${membre.nomComplet} (${membre.parente}) sera supprimé(e) définitivement, '
          'ainsi que sa photo.',
          textAlign: TextAlign.center,
        ),
        actionsAlignment: MainAxisAlignment.center,
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Annuler'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: AppColors.danger),
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Supprimer'),
          ),
        ],
      ),
    );
    if (ok != true || !mounted) return;

    try {
      await _api.deleteMembre(membre.id!);
      if (!mounted) return;
      setState(() => membres.removeWhere((m) => m.id == membre.id));
      showAppMessage(context, '${membre.prenom} a été supprimé(e)');
    } on ApiException catch (e) {
      if (!mounted) return;
      showAppMessage(context, e.message, error: true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final count = membres.length;

    return Scaffold(
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => ouvrirFormulaire(),
        icon: const Icon(Icons.person_add_alt_1),
        label: const Text(
          'Ajouter',
          style: TextStyle(fontWeight: FontWeight.w700),
        ),
      ),
      body: Column(
        children: [
          PageHeader(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                HeaderBar(
                  title: 'Ma famille',
                  actions: [
                    HeaderIconButton(
                      icon: Icons.refresh,
                      tooltip: 'Actualiser',
                      onPressed: loading ? null : charger,
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.16),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: const Icon(
                        Icons.family_restroom,
                        color: Colors.white,
                        size: 28,
                      ),
                    ),
                    const SizedBox(width: 14),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          loading && count == 0
                              ? 'Chargement…'
                              : '$count membre${count > 1 ? 's' : ''}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 22,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        const Text(
                          'Ceux qui m’ont fait grandir',
                          style: TextStyle(color: Colors.white70),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
          Expanded(
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 720),
                child: _body(),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _body() {
    if (loading && membres.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    if (error != null && membres.isEmpty) {
      return _EmptyState(
        icon: Icons.cloud_off_outlined,
        color: AppColors.danger,
        title: 'Connexion impossible',
        message: error!,
        action: ElevatedButton.icon(
          style: ElevatedButton.styleFrom(minimumSize: const Size(160, 48)),
          onPressed: charger,
          icon: const Icon(Icons.refresh),
          label: const Text('Réessayer'),
        ),
      );
    }

    if (membres.isEmpty) {
      return RefreshIndicator(
        onRefresh: charger,
        child: const _EmptyState(
          icon: Icons.group_add_outlined,
          title: 'Aucun membre pour le moment',
          message: 'Appuie sur « Ajouter » pour commencer',
          scrollable: true,
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: charger,
      child: ListView.separated(
        padding: const EdgeInsets.fromLTRB(16, 18, 16, 100),
        itemCount: membres.length,
        separatorBuilder: (_, _) => const SizedBox(height: 12),
        itemBuilder: (context, index) => _MembreCard(
          membre: membres[index],
          onEdit: () => ouvrirFormulaire(membres[index]),
          onDelete: () => supprimer(membres[index]),
        ),
      ),
    );
  }
}

class _MembreCard extends StatelessWidget {
  const _MembreCard({
    required this.membre,
    required this.onEdit,
    required this.onDelete,
  });

  final FamilleMembre membre;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  static Color colorFor(String parente) {
    final p = parente.toLowerCase();
    if (p.contains('grand')) return const Color(0xFFA7780A); // ocre
    if (p.contains('père') || p.contains('mère')) return AppColors.red;
    if (p.contains('frère') || p.contains('sœur') || p.contains('soeur')) {
      return AppColors.primary;
    }
    if (p.contains('fils') || p.contains('fille')) return AppColors.success;
    if (p.contains('époux') || p.contains('épouse')) return AppColors.red;
    return AppColors.primaryDark;
  }

  /// 1970-05-12 -> 12/05/1970
  static String dateFr(String iso) {
    final p = iso.split('-');
    return p.length == 3 ? '${p[2]}/${p[1]}/${p[0]}' : iso;
  }

  @override
  Widget build(BuildContext context) {
    final color = colorFor(membre.parente);

    return PaperCard(
      onTap: onEdit,
      padding: const EdgeInsets.fromLTRB(14, 14, 4, 14),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(2.5),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: color.withValues(alpha: 0.5), width: 2),
            ),
            child: CircleAvatar(
              radius: 31,
              backgroundColor: color.withValues(alpha: 0.12),
              backgroundImage: membre.imageUrl != null
                  ? NetworkImage(membre.imageUrl!)
                  : null,
              child: membre.imageUrl == null
                  ? Text(
                      membre.prenom.isNotEmpty
                          ? membre.prenom[0].toUpperCase()
                          : '?',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w800,
                        color: color,
                      ),
                    )
                  : null,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  membre.nomComplet,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 6),
                Tag(membre.parente, color: color, icon: Icons.favorite),
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Icon(
                      Icons.cake_outlined,
                      size: 15,
                      color: AppColors.textMuted,
                    ),
                    const SizedBox(width: 5),
                    Flexible(
                      child: Text(
                        'Né(e) le ${dateFr(membre.dateNaissance)} à ${membre.lieuNaissance}',
                        style: const TextStyle(
                          color: AppColors.textMuted,
                          fontSize: 13.5,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          PopupMenuButton<String>(
            tooltip: 'Actions',
            icon: const Icon(Icons.more_vert, color: AppColors.textMuted),
            onSelected: (action) => action == 'edit' ? onEdit() : onDelete(),
            itemBuilder: (_) => const [
              PopupMenuItem(
                value: 'edit',
                child: ListTile(
                  leading: Icon(Icons.edit_outlined, color: AppColors.primary),
                  title: Text('Modifier'),
                ),
              ),
              PopupMenuItem(
                value: 'delete',
                child: ListTile(
                  leading: Icon(Icons.delete_outline, color: AppColors.danger),
                  title: Text(
                    'Supprimer',
                    style: TextStyle(color: AppColors.danger),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({
    required this.icon,
    required this.title,
    required this.message,
    this.color = AppColors.primary,
    this.action,
    this.scrollable = false,
  });

  final IconData icon;
  final String title;
  final String message;
  final Color color;
  final Widget? action;
  final bool scrollable;

  @override
  Widget build(BuildContext context) {
    final content = Padding(
      padding: const EdgeInsets.all(32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(22),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, size: 48, color: color),
          ),
          const SizedBox(height: 18),
          Text(
            title,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 6),
          Text(
            message,
            textAlign: TextAlign.center,
            style: const TextStyle(color: AppColors.textMuted),
          ),
          if (action != null) ...[const SizedBox(height: 18), action!],
        ],
      ),
    );

    if (!scrollable) return Center(child: content);
    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      children: [const SizedBox(height: 40), content],
    );
  }
}
