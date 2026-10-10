import 'package:equatable/equatable.dart';
import 'package:flutter_mobile_prospect_agent/core/constants/app_constants.dart';

/// Média d'un bien (photo, panorama 360°, visite virtuelle) — miroir de `MediaFoncierResponse`.
class MediaModel extends Equatable {
  final int id;
  final String type; // PHOTO | PANORAMA_360 | VISITE_VIRTUELLE
  final String? titre;
  final String? description;
  final String url;
  final int? ordre;

  const MediaModel({
    required this.id,
    required this.type,
    required this.url,
    this.titre,
    this.description,
    this.ordre,
  });

  bool get isPhoto => type == 'PHOTO';
  bool get isPanorama => type == 'PANORAMA_360';
  bool get isVisiteVirtuelle => type == 'VISITE_VIRTUELLE';

  /// URL absolue : les fichiers téléversés sont servis par le backend sous « /uploads/... ».
  String get urlAbsolue {
    if (url.startsWith('http://') || url.startsWith('https://')) return url;
    final base = AppConstants.apiBaseUrl;
    final origin = base.endsWith('/api') ? base.substring(0, base.length - 4) : base;
    return url.startsWith('/') ? '$origin$url' : '$origin/$url';
  }

  factory MediaModel.fromJson(Map<String, dynamic> json) {
    return MediaModel(
      id: (json['id'] as num?)?.toInt() ?? 0,
      type: json['type']?.toString() ?? 'PHOTO',
      titre: json['titre'] as String?,
      description: json['description'] as String?,
      url: json['url'] as String? ?? '',
      ordre: (json['ordre'] as num?)?.toInt(),
    );
  }

  @override
  List<Object?> get props => [id, type, titre, description, url, ordre];
}
