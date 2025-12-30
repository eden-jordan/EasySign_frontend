import 'rapportpersonnel.dart';

class Rapport {
  final String periode;
  final String dateDebut;
  final String dateFin;

  final int totalPresent;
  final int totalAbsents;
  final int totalRetards;
  final int totalPauseRetards;

  final List<Rapportpersonnel> personnels;

  Rapport({
    required this.periode,
    required this.dateDebut,
    required this.dateFin,
    required this.totalPresent,
    required this.totalAbsents,
    required this.totalRetards,
    required this.totalPauseRetards,
    required this.personnels,
  });

  factory Rapport.fromJson(Map<String, dynamic> json) {
    return Rapport(
      periode: json['periode'],
      dateDebut: json['date_debut'],
      dateFin: json['date_fin'],

      totalPresent: json['totaux']['present'],
      totalAbsents: json['totaux']['absent'],
      totalRetards: json['totaux']['retard'],
      totalPauseRetards: json['totaux']['retard_pause'],

      personnels: (json['personnels'] as List)
          .map((e) => Rapportpersonnel.fromJson(e))
          .toList(),
    );
  }
}
