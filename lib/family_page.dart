import 'package:flutter/material.dart';

import 'api/api_service.dart';
import 'famille_form_page.dart';
import 'models/famille_membre.dart';

class FamilyPage extends StatefulWidget {
  const FamilyPage({super.key});

  @override
  State<FamilyPage> createState() => _FamilyPageState();
}

class _FamilyPageState extends State<FamilyPage> {
  final _api = ApiService();
  List<FamilleMembre> membres = [];
  bool loading = true;
  String? error;

  @override
  void initState() {
    super.initState();
    loadMembres();
  }

  Future<void> loadMembres() async {
    setState(() {
      loading = true;
      error = null;
    });
    try {
      final result = await _api.getFamilleMembres();
      if (!mounted) return;
      setState(() => membres = result);
    } on ApiException catch (e) {
      if (!mounted) return;
      setState(() => error = e.message);
    } finally {
      if (mounted) setState(() => loading = false);
    }
  }

  Future<void> openForm([FamilleMembre? membre]) async {
    final changed = await Navigator.push<bool>(
      context,
      MaterialPageRoute(builder: (context) => FamilleFormPage(membre: membre)),
    );
    if (changed == true) loadMembres();
  }

  Future<void> deleteMembre(FamilleMembre membre) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Supprimer ce membre ?'),
        content: Text('${membre.nomComplet} sera supprimé avec sa photo.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Annuler'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Supprimer'),
          ),
        ],
      ),
    );
    if (confirm != true || !mounted) return;

    final messenger = ScaffoldMessenger.of(context);
    try {
      await _api.deleteFamilleMembre(membre.id!);
      messenger.showSnackBar(const SnackBar(content: Text('Membre supprimé')));
      loadMembres();
    } on ApiException catch (e) {
      messenger.showSnackBar(SnackBar(content: Text(e.message)));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Ma famille'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            tooltip: 'Actualiser',
            icon: const Icon(Icons.refresh),
            onPressed: loading ? null : loadMembres,
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        tooltip: 'Ajouter un membre',
        onPressed: () => openForm(),
        child: const Icon(Icons.person_add),
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (loading && membres.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    if (error != null && membres.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.cloud_off, size: 60, color: Colors.grey),
              const SizedBox(height: 12),
              Text(error!, textAlign: TextAlign.center),
              const SizedBox(height: 12),
              ElevatedButton.icon(
                onPressed: loadMembres,
                icon: const Icon(Icons.refresh),
                label: const Text('Réessayer'),
              ),
            ],
          ),
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: loadMembres,
      child: membres.isEmpty
          ? ListView(
              children: const [
                SizedBox(height: 120),
                Icon(Icons.family_restroom, size: 60, color: Colors.grey),
                SizedBox(height: 12),
                Center(child: Text('Aucun membre pour le moment.')),
                Center(child: Text('Appuyez sur + pour en ajouter un.')),
              ],
            )
          : ListView.builder(
              padding: const EdgeInsets.fromLTRB(15, 15, 15, 90),
              itemCount: membres.length,
              itemBuilder: (context, index) {
                final membre = membres[index];
                return Card(
                  elevation: 3,
                  margin: const EdgeInsets.only(bottom: 15),
                  child: ListTile(
                    contentPadding: const EdgeInsets.all(12),
                    onTap: () => openForm(membre),
                    leading: MembreAvatar(imageUrl: membre.imageUrl),
                    title: Text(
                      membre.nomComplet,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Text(
                      '${membre.parente}\n'
                      'Né(e) le ${membre.dateNaissance} à ${membre.lieuNaissance}',
                    ),
                    isThreeLine: true,
                    trailing: PopupMenuButton<String>(
                      onSelected: (value) {
                        if (value == 'edit') openForm(membre);
                        if (value == 'delete') deleteMembre(membre);
                      },
                      itemBuilder: (context) => const [
                        PopupMenuItem(value: 'edit', child: Text('Modifier')),
                        PopupMenuItem(
                          value: 'delete',
                          child: Text('Supprimer'),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }
}

/// Photo du membre chargée depuis l'API, avec une icône si elle est absente.
class MembreAvatar extends StatelessWidget {
  const MembreAvatar({super.key, this.imageUrl, this.radius = 30});

  final String? imageUrl;
  final double radius;

  @override
  Widget build(BuildContext context) {
    final url = imageUrl;
    return CircleAvatar(
      radius: radius,
      backgroundColor: Colors.blue.shade100,
      foregroundImage: url == null ? null : NetworkImage(url),
      onForegroundImageError: url == null ? null : (_, _) {},
      child: Icon(Icons.person, size: radius, color: Colors.blue),
    );
  }
}
