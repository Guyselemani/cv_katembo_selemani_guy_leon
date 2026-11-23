class FamilleMembre {
  final int? id;
  final String nom;
  final String postnom;
  final String prenom;
  final String lieuNaissance;

  /// Format AAAA-MM-JJ, comme attendu par l'API.
  final String dateNaissance;
  final String parente;
  final String? imageUrl;

  const FamilleMembre({
    this.id,
    required this.nom,
    required this.postnom,
    required this.prenom,
    required this.lieuNaissance,
    required this.dateNaissance,
    required this.parente,
    this.imageUrl,
  });

  String get nomComplet => '$prenom $nom $postnom';

  factory FamilleMembre.fromJson(Map<String, dynamic> json) {
    return FamilleMembre(
      id: json['id'] == null ? null : int.parse(json['id'].toString()),
      nom: (json['nom'] ?? '').toString(),
      postnom: (json['postnom'] ?? '').toString(),
      prenom: (json['prenom'] ?? '').toString(),
      lieuNaissance: (json['lieu_naissance'] ?? '').toString(),
      dateNaissance: (json['date_naissance'] ?? '').toString(),
      parente: (json['parente'] ?? '').toString(),
      imageUrl: json['image_url']?.toString(),
    );
  }

  /// Champs envoyés à l'API (JSON ou form-data).
  Map<String, String> toFields() {
    return {
      'nom': nom,
      'postnom': postnom,
      'prenom': prenom,
      'lieu_naissance': lieuNaissance,
      'date_naissance': dateNaissance,
      'parente': parente,
    };
  }
}
