import 'package:equatable/equatable.dart';

class AgentKpiModel extends Equatable {
  final int totalVisitesJour;
  final int reservationsEnAttente;
  final int reservationsExpirees;
  final int totalReservationsConfirmees;

  const AgentKpiModel({
    this.totalVisitesJour = 0,
    this.reservationsEnAttente = 0,
    this.reservationsExpirees = 0,
    this.totalReservationsConfirmees = 0,
  });

  factory AgentKpiModel.fromJson(Map<String, dynamic> json) {
    return AgentKpiModel(
      totalVisitesJour: json['totalVisitesJour'] as int? ?? 0,
      reservationsEnAttente: json['reservationsEnAttente'] as int? ?? 0,
      reservationsExpirees: json['reservationsExpirees'] as int? ?? 0,
      totalReservationsConfirmees:
          json['totalReservationsConfirmees'] as int? ?? 0,
    );
  }

  Map<String, dynamic> toJson() => {
        'totalVisitesJour': totalVisitesJour,
        'reservationsEnAttente': reservationsEnAttente,
        'reservationsExpirees': reservationsExpirees,
        'totalReservationsConfirmees': totalReservationsConfirmees,
      };

  @override
  List<Object?> get props => [
        totalVisitesJour,
        reservationsEnAttente,
        reservationsExpirees,
        totalReservationsConfirmees,
      ];
}
