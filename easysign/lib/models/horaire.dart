import 'dart:convert';

class Horaire {
  final int id;
  final int organisationId;
  final String heureArrivee;
  final String heureDepart;
  final String pauseDebut;
  final String pauseFin;
  final List<String> joursTravail;

  Horaire({
    required this.id,
    required this.organisationId,
    required this.heureArrivee,
    required this.heureDepart,
    required this.pauseDebut,
    required this.pauseFin,
    required this.joursTravail,
  });

  factory Horaire.fromJson(Map<String, dynamic> json) => Horaire(
    id: json['id'],
    organisationId: json['organisation_id'],
    heureArrivee: json['heure_arrivee'],
    heureDepart: json['heure_depart'],
    pauseDebut: json['heure_pause_debut'],
    pauseFin: json['heure_pause_fin'],
    joursTravail: List<String>.from(jsonDecode(json['jours_travail'])),
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'organisation_id': organisationId,
    'heure_arrivee': heureArrivee,
    'heure_depart': heureDepart,
    'heure_pause_debut': pauseDebut,
    'heure_pause_fin': pauseFin,
    'jours_travail': jsonEncode(joursTravail),
  };
}
