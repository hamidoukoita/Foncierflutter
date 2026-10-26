import 'description_maison.dart';
import 'projet_construction.dart';

enum StatutProposition {
  enAttente('EN_ATTENTE', 'À vous de répondre'),
  acceptee('ACCEPTEE', 'Acceptée'),
  refusee('REFUSEE', 'Déclinée'),
  caduque('CADUQUE', 'Sans suite');

  final String code;
  final String libelle;
  const StatutProposition(this.code, this.libelle);

  static StatutProposition depuis(String? code) =>
      StatutProposition.values.firstWhere((s) => s.code == code, orElse: () => StatutProposition.caduque);
}

/// Proposition de la société : un modèle et/ou une maison décrite, avec prix et délai estimés.
class PropositionProjet {
  final int id;
  final int numero;
  final String titre;
  final DescriptionMaison? maison;
  final String? modeleLibelle;
  final String? modeleImageUrl;
  final double? prixEstime;
  final int? delaiMois;
  final String? commentaire;
  final StatutProposition statut;
  final String? reponseAcquereur;
  final DateTime? dateProposition;
  final List<FichierProjet> plans;

  const PropositionProjet({
    required this.id,
    required this.numero,
    required this.titre,
    required this.statut,
    this.maison,
    this.modeleLibelle,
    this.modeleImageUrl,
    this.prixEstime,
    this.delaiMois,
    this.commentaire,
    this.reponseAcquereur,
    this.dateProposition,
    this.plans = const [],
  });

  bool get enAttente => statut == StatutProposition.enAttente;

  factory PropositionProjet.fromJson(Map<String, dynamic> json) => PropositionProjet(
        id: (json['id'] as num).toInt(),
        numero: (json['numero'] as num?)?.toInt() ?? 1,
        titre: json['titre'] as String? ?? 'Proposition',
        maison: json['maison'] is Map<String, dynamic>
            ? DescriptionMaison.fromJson(json['maison'] as Map<String, dynamic>)
            : null,
        modeleLibelle: json['modelMaisonLibeller'] as String?,
        modeleImageUrl: json['modelMaisonImageUrl'] as String?,
        prixEstime: (json['prixEstime'] as num?)?.toDouble(),
        delaiMois: (json['delaiMois'] as num?)?.toInt(),
        commentaire: json['commentaire'] as String?,
        statut: StatutProposition.depuis(json['statut'] as String?),
        reponseAcquereur: json['reponseAcquereur'] as String?,
        dateProposition: DateTime.tryParse(json['dateProposition']?.toString() ?? ''),
        plans: ((json['plans'] as List?) ?? const [])
            .map((f) => FichierProjet.fromJson(f as Map<String, dynamic>))
            .toList(),
      );
}

enum CoteEchange { acquereur, societe }

class MessageProjet {
  final int id;
  final String texte;
  final CoteEchange cote;
  final String? auteurNom;
  final DateTime? dateEnvoi;

  const MessageProjet({required this.id, required this.texte, required this.cote, this.auteurNom, this.dateEnvoi});

  factory MessageProjet.fromJson(Map<String, dynamic> json) => MessageProjet(
        id: (json['id'] as num).toInt(),
        texte: json['texte'] as String? ?? '',
        cote: json['cote'] == 'SOCIETE' ? CoteEchange.societe : CoteEchange.acquereur,
        auteurNom: json['auteurNom'] as String?,
        dateEnvoi: DateTime.tryParse(json['dateEnvoi']?.toString() ?? ''),
      );
}

/// Élément du fil d'échange, par ordre chronologique.
sealed class ElementFil {
  const ElementFil();

  static ElementFil? fromJson(Map<String, dynamic> json) => switch (json['type']) {
        'MESSAGE' when json['message'] is Map<String, dynamic> =>
          MessageFil(MessageProjet.fromJson(json['message'] as Map<String, dynamic>)),
        'PROPOSITION' when json['proposition'] is Map<String, dynamic> =>
          PropositionFil(PropositionProjet.fromJson(json['proposition'] as Map<String, dynamic>)),
        _ => null,
      };
}

class MessageFil extends ElementFil {
  final MessageProjet message;
  const MessageFil(this.message);
}

class PropositionFil extends ElementFil {
  final PropositionProjet proposition;
  const PropositionFil(this.proposition);
}
