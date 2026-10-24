/// Société promotrice agréée, destinataire possible d'un projet de construction.
class SocietePromotrice {
  final int id;
  final String nom;
  final String? adresse;
  final String? telephone;
  final String? logoUrl;
  final String? description;

  /// Budget minimum d'un projet de construction chez cette société (null = pas de minimum).
  final double? budgetMinimumConstruction;

  const SocietePromotrice({
    required this.id,
    required this.nom,
    this.adresse,
    this.telephone,
    this.logoUrl,
    this.description,
    this.budgetMinimumConstruction,
  });

  String get initiales {
    final mots = nom.trim().split(RegExp(r'\s+')).where((m) => m.isNotEmpty);
    final lettres = mots.take(2).map((m) => m[0].toUpperCase()).join();
    return lettres.isEmpty ? 'SP' : lettres;
  }

  factory SocietePromotrice.fromJson(Map<String, dynamic> json) {
    return SocietePromotrice(
      id: (json['id'] as num).toInt(),
      nom: json['nom'] as String? ?? '',
      adresse: json['adresse'] as String?,
      telephone: json['telephone'] as String?,
      logoUrl: json['logoUrl'] as String?,
      description: json['description'] as String?,
      budgetMinimumConstruction: (json['budgetMinimumConstruction'] as num?)?.toDouble(),
    );
  }
}
