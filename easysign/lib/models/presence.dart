import 'personnel.dart';

class Presence {
  final int id;
  final int personnelId;
  final String date;
  final String? arrivee;
  final String? depart;
  final String? pauseDebut;
  final String? pauseFin;
  final String statut;
  final Personnel personnel;

  Presence({
    required this.id,
    required this.personnelId,
    required this.date,
    this.arrivee,
    this.depart,
    this.pauseDebut,
    this.pauseFin,
    required this.statut,
    required this.personnel,
  });

  factory Presence.fromJson(Map<String, dynamic> json) => Presence(
    id: json['id'],
    personnelId: json['personnel_id'],
    date: json['date'],
    arrivee: json['arrivee'],
    depart: json['depart'],
    pauseDebut: json['pause_debut'],
    pauseFin: json['pause_fin'],
    statut: json['statut'],
    personnel: Personnel.fromJson(json['personnel']),
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'personnel_id': personnelId,
    'date': date,
    'arrivee': arrivee,
    'depart': depart,
    'pause_debut': pauseDebut,
    'pause_fin': pauseFin,
    'statut': statut,
  };
}
