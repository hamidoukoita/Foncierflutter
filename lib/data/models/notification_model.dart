import 'package:equatable/equatable.dart';

/// Notification utilisateur — miroir de `NotificationResponse`.
class NotificationModel extends Equatable {
  final int id;
  final String titre;
  final String message;
  final bool lue;
  final DateTime dateEnvoi;
  final String? typeNotificationLibelle;

  const NotificationModel({
    required this.id,
    required this.titre,
    required this.message,
    required this.lue,
    required this.dateEnvoi,
    this.typeNotificationLibelle,
  });

  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    return NotificationModel(
      id: json['id'] as int,
      titre: json['titre'] as String? ?? '',
      message: json['message'] as String? ?? '',
      lue: json['lue'] as bool? ?? false,
      dateEnvoi: json['dateEnvoi'] != null
          ? DateTime.parse(json['dateEnvoi'] as String)
          : DateTime.now(),
      typeNotificationLibelle: json['typeNotificationLibelle'] as String?,
    );
  }

  @override
  List<Object?> get props =>
      [id, titre, message, lue, dateEnvoi, typeNotificationLibelle];
}
