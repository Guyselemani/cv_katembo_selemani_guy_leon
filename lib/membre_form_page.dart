import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import 'services/api_service.dart';
import 'theme/app_theme.dart';
import 'widgets/common.dart';

/// Formulaire d'ajout (membre == null) ou de modification d'un membre.
/// Renvoie le membre enregistré via Navigator.pop.
class MembreFormPage extends StatefulWidget {
  const MembreFormPage({
    super.key,
    required this.api,
    this.membre,
    this.pickImage,
  });

  final ApiService api;
  final FamilleMembre? membre;

  /// Choix de l'image (remplaçable dans les tests).
  final Future<PickedImage?> Function()? pickImage;

  @override
  State<MembreFormPage> createState() => _MembreFormPageState();
}

class _MembreFormPageState extends State<MembreFormPage> {
  static const parentes = [
    'Père',
    'Mère',
    'Frère',
    'Sœur',
    'Grand-père',
    'Grand-mère',
    'Oncle',
    'Tante',
    'Cousin',
    'Cousine',
    'Fils',
    'Fille',
    'Époux',
    'Épouse',
  ];

  final _formKey = GlobalKey<FormState>();
  late final nomController = TextEditingController(text: widget.membre?.nom);
  late final postnomController = TextEditingController(
    text: widget.membre?.postnom,
  );
  late final prenomController = TextEditingController(
    text: widget.membre?.prenom,
  );
  late final lieuController = TextEditingController(
    text: widget.membre?.lieuNaissance,
  );
  late final dateController = TextEditingController(
    text: widget.membre?.dateNaissance,
  );
  late String? parente = widget.membre?.parente;

  PickedImage? image;
  bool loading = false;
  Map<String, String> serverErrors = {};

  bool get isEdit => widget.membre != null;

  Future<PickedImage?> _defaultPick() async {
    final file = await ImagePicker().pickImage(
      source: ImageSource.gallery,
      maxWidth: 1024,
      maxHeight: 1024,
      imageQuality: 85,
    );
    if (file == null) return null;
    return PickedImage(bytes: await file.readAsBytes(), name: file.name);
  }

  Future<void> choisirImage() async {
    final picked = await (widget.pickImage ?? _defaultPick)();
    if (picked == null || !mounted) return;
    if (picked.bytes.length > 2 * 1024 * 1024) {
      showAppMessage(context, "L'image ne doit pas dépasser 2 Mo", error: true);
      return;
    }
    setState(() => image = picked);
  }

  Future<void> choisirDate() async {
    final today = DateTime.now();
    final initial = DateTime.tryParse(dateController.text) ?? DateTime(1990);
    final date = await showDatePicker(
      context: context,
      initialDate: initial.isAfter(today) ? today : initial,
      firstDate: DateTime(1900),
      lastDate: today,
      helpText: 'Date de naissance',
    );
    if (date != null) dateController.text = _iso(date);
  }

  static String _iso(DateTime d) =>
      '${d.year.toString().padLeft(4, '0')}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

  Future<void> enregistrer() async {
    setState(() => serverErrors = {});
    if (!_formKey.currentState!.validate()) return;

    final membre = FamilleMembre(
      id: widget.membre?.id,
      nom: nomController.text.trim(),
      postnom: postnomController.text.trim(),
      prenom: prenomController.text.trim(),
      lieuNaissance: lieuController.text.trim(),
      dateNaissance: dateController.text.trim(),
      parente: parente!,
    );

    setState(() => loading = true);
    try {
      final saved = isEdit
          ? await widget.api.updateMembre(membre, image: image)
          : await widget.api.createMembre(membre, image: image);
      if (!mounted) return;
      Navigator.pop(context, saved);
    } on ApiException catch (e) {
      if (!mounted) return;
      setState(() => serverErrors = e.errors);
      _formKey.currentState!.validate();
      showAppMessage(context, e.errors['image'] ?? e.message, error: true);
    } finally {
      if (mounted) setState(() => loading = false);
    }
  }

  @override
  void dispose() {
    nomController.dispose();
    postnomController.dispose();
    prenomController.dispose();
    lieuController.dispose();
    dateController.dispose();
    super.dispose();
  }

  String? _required(String field, String label, String? value, int max) {
    final v = value?.trim() ?? '';
    if (v.isEmpty) return 'Le champ $label est obligatoire';
    if (v.length > max) return '$max caractères maximum';
    return serverErrors[field];
  }

  Widget _champ(
    TextEditingController controller,
    String field,
    String label,
    IconData icon,
    int max,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: TextFormField(
        controller: controller,
        maxLength: max,
        textCapitalization: TextCapitalization.words,
        textInputAction: TextInputAction.next,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon),
          counterText: '',
        ),
        validator: (v) => _required(field, label, v, max),
      ),
    );
  }

  Widget _groupTitle(IconData icon, String text) => Padding(
    padding: const EdgeInsets.only(bottom: 14),
    child: Row(
      children: [
        IconBadge(icon: icon, size: 34),
        const SizedBox(width: 10),
        Text(
          text,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
        ),
      ],
    ),
  );

  @override
  Widget build(BuildContext context) {
    final ImageProvider? apercu = image != null
        ? MemoryImage(image!.bytes)
        : (widget.membre?.imageUrl != null
              ? NetworkImage(widget.membre!.imageUrl!)
              : null);
    final options = [
      ...parentes,
      if (parente != null && !parentes.contains(parente)) parente!,
    ];

    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: [
            PageHeader(
              padding: const EdgeInsets.fromLTRB(12, 8, 20, 26),
              child: Column(
                children: [
                  HeaderBar(
                    title: isEdit ? 'Modifier le membre' : 'Ajouter un membre',
                    leading: HeaderIconButton(
                      icon: Icons.arrow_back,
                      tooltip: 'Retour',
                      onPressed: loading ? null : () => Navigator.pop(context),
                    ),
                  ),
                  const SizedBox(height: 12),
                  GestureDetector(
                    onTap: loading ? null : choisirImage,
                    child: Stack(
                      children: [
                        RingAvatar(
                          radius: 56,
                          image: apercu,
                          child: apercu == null
                              ? const Icon(
                                  Icons.person,
                                  size: 58,
                                  color: AppColors.primary,
                                )
                              : null,
                        ),
                        Positioned(
                          right: 2,
                          bottom: 2,
                          child: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: AppColors.accent,
                              shape: BoxShape.circle,
                              border: Border.all(color: Colors.white, width: 3),
                            ),
                            child: const Icon(
                              Icons.camera_alt,
                              size: 18,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 6),
                  TextButton(
                    style: TextButton.styleFrom(foregroundColor: Colors.white),
                    onPressed: loading ? null : choisirImage,
                    child: Text(
                      image != null || widget.membre?.imageUrl != null
                          ? 'Changer la photo'
                          : 'Ajouter une photo (facultatif)',
                    ),
                  ),
                ],
              ),
            ),
            Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 620),
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 18, 16, 28),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Card(
                          child: Padding(
                            padding: const EdgeInsets.fromLTRB(16, 18, 16, 4),
                            child: Column(
                              children: [
                                _groupTitle(Icons.badge_outlined, 'Identité'),
                                _champ(
                                  nomController,
                                  'nom',
                                  'Nom',
                                  Icons.badge_outlined,
                                  50,
                                ),
                                _champ(
                                  postnomController,
                                  'postnom',
                                  'Postnom',
                                  Icons.assignment_ind_outlined,
                                  50,
                                ),
                                _champ(
                                  prenomController,
                                  'prenom',
                                  'Prénom',
                                  Icons.person_outline,
                                  50,
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 14),
                        Card(
                          child: Padding(
                            padding: const EdgeInsets.fromLTRB(16, 18, 16, 18),
                            child: Column(
                              children: [
                                _groupTitle(
                                  Icons.cake_outlined,
                                  'Naissance et parenté',
                                ),
                                _champ(
                                  lieuController,
                                  'lieu_naissance',
                                  'Lieu de naissance',
                                  Icons.location_on_outlined,
                                  100,
                                ),
                                Padding(
                                  padding: const EdgeInsets.only(bottom: 14),
                                  child: TextFormField(
                                    controller: dateController,
                                    keyboardType: TextInputType.datetime,
                                    decoration: InputDecoration(
                                      labelText: 'Date de naissance',
                                      hintText: 'AAAA-MM-JJ',
                                      prefixIcon: const Icon(
                                        Icons.event_outlined,
                                      ),
                                      suffixIcon: IconButton(
                                        tooltip: 'Choisir dans le calendrier',
                                        icon: const Icon(
                                          Icons.calendar_month,
                                          color: AppColors.primary,
                                        ),
                                        onPressed: loading ? null : choisirDate,
                                      ),
                                    ),
                                    validator: (value) {
                                      final v = value?.trim() ?? '';
                                      if (v.isEmpty)
                                        return 'La date de naissance est obligatoire';
                                      final d =
                                          RegExp(r'^\d{4}-\d{2}-\d{2}$')
                                              .hasMatch(v)
                                          ? DateTime.tryParse(v)
                                          : null;
                                      if (d == null || _iso(d) != v) {
                                        return 'Format attendu : AAAA-MM-JJ';
                                      }
                                      if (d.isAfter(DateTime.now())) {
                                        return 'La date ne peut pas être dans le futur';
                                      }
                                      return serverErrors['date_naissance'];
                                    },
                                  ),
                                ),
                                DropdownButtonFormField<String>(
                                  initialValue: parente,
                                  borderRadius: BorderRadius.circular(14),
                                  dropdownColor: Colors.white,
                                  decoration: const InputDecoration(
                                    labelText: 'Parenté',
                                    prefixIcon: Icon(Icons.family_restroom),
                                  ),
                                  items: [
                                    for (final p in options)
                                      DropdownMenuItem(
                                        value: p,
                                        child: Text(p),
                                      ),
                                  ],
                                  onChanged: loading
                                      ? null
                                      : (v) => setState(() => parente = v),
                                  validator: (v) => v == null
                                      ? 'Choisissez la parenté'
                                      : serverErrors['parente'],
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 22),
                        ElevatedButton.icon(
                          onPressed: loading ? null : enregistrer,
                          icon: loading
                              ? const ButtonLoader()
                              : Icon(
                                  isEdit
                                      ? Icons.check_circle_outline
                                      : Icons.person_add_alt_1,
                                ),
                          label: Text(
                            isEdit
                                ? 'Enregistrer les modifications'
                                : 'Ajouter le membre',
                          ),
                        ),
                      ],
                    ),
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
