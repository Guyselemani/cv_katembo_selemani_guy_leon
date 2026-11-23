import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import 'api/api_service.dart';
import 'family_page.dart';
import 'models/famille_membre.dart';

/// Formulaire de création (membre == null) ou de modification d'un membre.
/// Renvoie `true` à la page précédente si un enregistrement a eu lieu.
class FamilleFormPage extends StatefulWidget {
  const FamilleFormPage({super.key, this.membre});

  final FamilleMembre? membre;

  @override
  State<FamilleFormPage> createState() => _FamilleFormPageState();
}

class _FamilleFormPageState extends State<FamilleFormPage> {
  static const int maxImageBytes = 2 * 1024 * 1024; // 2 Mo
  static const allowedExtensions = ['jpg', 'jpeg', 'png', 'gif', 'webp'];

  final _formKey = GlobalKey<FormState>();
  final _api = ApiService();

  late final TextEditingController nom;
  late final TextEditingController postnom;
  late final TextEditingController prenom;
  late final TextEditingController lieuNaissance;
  late final TextEditingController dateNaissance;
  late final TextEditingController parente;

  Uint8List? imageBytes;
  String? imageName;
  bool saving = false;
  Map<String, String> serverErrors = {};

  bool get isEdit => widget.membre != null;

  @override
  void initState() {
    super.initState();
    final m = widget.membre;
    nom = TextEditingController(text: m?.nom);
    postnom = TextEditingController(text: m?.postnom);
    prenom = TextEditingController(text: m?.prenom);
    lieuNaissance = TextEditingController(text: m?.lieuNaissance);
    dateNaissance = TextEditingController(text: m?.dateNaissance);
    parente = TextEditingController(text: m?.parente);
  }

  @override
  void dispose() {
    for (final c in [
      nom,
      postnom,
      prenom,
      lieuNaissance,
      dateNaissance,
      parente,
    ]) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> pickImage(ImageSource source) async {
    final messenger = ScaffoldMessenger.of(context);
    try {
      final file = await ImagePicker().pickImage(
        source: source,
        maxWidth: 1200,
        maxHeight: 1200,
        imageQuality: 85,
      );
      if (file == null) return;

      final ext = file.name.split('.').last.toLowerCase();
      if (!allowedExtensions.contains(ext)) {
        messenger.showSnackBar(
          const SnackBar(
            content: Text('Formats acceptés : jpg, png, gif, webp'),
          ),
        );
        return;
      }
      final bytes = await file.readAsBytes();
      if (bytes.length > maxImageBytes) {
        messenger.showSnackBar(
          const SnackBar(content: Text('L\'image dépasse 2 Mo')),
        );
        return;
      }
      setState(() {
        imageBytes = bytes;
        imageName = file.name;
      });
    } catch (e) {
      messenger.showSnackBar(
        SnackBar(content: Text('Impossible de choisir l\'image : $e')),
      );
    }
  }

  void showImageSourcePicker() {
    showModalBottomSheet(
      context: context,
      builder: (context) => SafeArea(
        child: Wrap(
          children: [
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text('Galerie'),
              onTap: () {
                Navigator.pop(context);
                pickImage(ImageSource.gallery);
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_camera),
              title: const Text('Appareil photo'),
              onTap: () {
                Navigator.pop(context);
                pickImage(ImageSource.camera);
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> pickDate() async {
    final initial =
        DateTime.tryParse(dateNaissance.text) ?? DateTime(2000, 1, 1);
    final picked = await showDatePicker(
      context: context,
      initialDate: initial.isAfter(DateTime.now()) ? DateTime.now() : initial,
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
      helpText: 'Date de naissance',
    );
    if (picked == null) return;
    final y = picked.year.toString().padLeft(4, '0');
    final mo = picked.month.toString().padLeft(2, '0');
    final d = picked.day.toString().padLeft(2, '0');
    setState(() => dateNaissance.text = '$y-$mo-$d');
  }

  Future<void> save() async {
    setState(() => serverErrors = {});
    if (!_formKey.currentState!.validate()) return;

    final membre = FamilleMembre(
      nom: nom.text.trim(),
      postnom: postnom.text.trim(),
      prenom: prenom.text.trim(),
      lieuNaissance: lieuNaissance.text.trim(),
      dateNaissance: dateNaissance.text.trim(),
      parente: parente.text.trim(),
    );
    final image = imageBytes == null
        ? null
        : ImageUpload(bytes: imageBytes!, filename: imageName ?? 'photo.jpg');

    setState(() => saving = true);
    final messenger = ScaffoldMessenger.of(context);
    final navigator = Navigator.of(context);
    try {
      if (isEdit) {
        await _api.updateFamilleMembre(
          widget.membre!.id!,
          membre,
          image: image,
        );
      } else {
        await _api.createFamilleMembre(membre, image: image);
      }
      messenger.showSnackBar(
        SnackBar(content: Text(isEdit ? 'Membre modifié' : 'Membre créé')),
      );
      navigator.pop(true);
    } on ApiException catch (e) {
      if (!mounted) return;
      setState(() => serverErrors = e.errors);
      messenger.showSnackBar(SnackBar(content: Text(e.details)));
    } finally {
      if (mounted) setState(() => saving = false);
    }
  }

  String? Function(String?) required(String label, int max) {
    return (value) {
      final v = value?.trim() ?? '';
      if (v.isEmpty) return 'Le champ $label est obligatoire';
      if (v.length > max) return '$max caractères maximum';
      return null;
    };
  }

  String? validateDate(String? value) {
    final v = value?.trim() ?? '';
    if (v.isEmpty) return 'La date de naissance est obligatoire';
    final date = DateTime.tryParse(v);
    if (date == null || !RegExp(r'^\d{4}-\d{2}-\d{2}$').hasMatch(v)) {
      return 'Format attendu : AAAA-MM-JJ';
    }
    if (date.isAfter(DateTime.now())) return 'La date ne peut pas être future';
    return null;
  }

  Widget field(
    String key,
    String label,
    TextEditingController controller,
    int max, {
    IconData? icon,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15),
      child: TextFormField(
        controller: controller,
        maxLength: max,
        textCapitalization: TextCapitalization.words,
        validator: required(label, max),
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: icon == null ? null : Icon(icon),
          border: const OutlineInputBorder(),
          counterText: '',
          errorText: serverErrors[key],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bytes = imageBytes;
    return Scaffold(
      appBar: AppBar(
        title: Text(isEdit ? 'Modifier le membre' : 'Nouveau membre'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            Center(
              child: GestureDetector(
                onTap: saving ? null : showImageSourcePicker,
                child: Stack(
                  children: [
                    bytes != null
                        ? CircleAvatar(
                            radius: 55,
                            backgroundImage: MemoryImage(bytes),
                          )
                        : MembreAvatar(
                            imageUrl: widget.membre?.imageUrl,
                            radius: 55,
                          ),
                    const Positioned(
                      right: 0,
                      bottom: 0,
                      child: CircleAvatar(
                        radius: 18,
                        backgroundColor: Colors.blue,
                        child: Icon(
                          Icons.camera_alt,
                          size: 18,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 8),
            Center(
              child: Text(
                'Photo facultative (jpg, png, gif, webp – 2 Mo max)',
                style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
              ),
            ),
            if (serverErrors['image'] != null)
              Center(
                child: Text(
                  serverErrors['image']!,
                  style: const TextStyle(color: Colors.red),
                ),
              ),
            const SizedBox(height: 20),
            field('nom', 'Nom', nom, 50, icon: Icons.badge),
            field(
              'postnom',
              'Postnom',
              postnom,
              50,
              icon: Icons.badge_outlined,
            ),
            field('prenom', 'Prénom', prenom, 50, icon: Icons.person),
            field(
              'parente',
              'Lien de parenté (ex. : Père, Mère, Frère)',
              parente,
              50,
              icon: Icons.family_restroom,
            ),
            field(
              'lieu_naissance',
              'Lieu de naissance',
              lieuNaissance,
              100,
              icon: Icons.place,
            ),
            Padding(
              padding: const EdgeInsets.only(bottom: 15),
              child: TextFormField(
                controller: dateNaissance,
                readOnly: true,
                onTap: pickDate,
                validator: validateDate,
                decoration: InputDecoration(
                  labelText: 'Date de naissance',
                  prefixIcon: const Icon(Icons.cake),
                  suffixIcon: const Icon(Icons.calendar_today),
                  border: const OutlineInputBorder(),
                  errorText: serverErrors['date_naissance'],
                ),
              ),
            ),
            const SizedBox(height: 10),
            SizedBox(
              height: 50,
              child: ElevatedButton.icon(
                onPressed: saving ? null : save,
                icon: saving
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.save),
                label: Text(
                  isEdit
                      ? 'Enregistrer les modifications'
                      : 'Ajouter le membre',
                  style: const TextStyle(fontSize: 16),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
