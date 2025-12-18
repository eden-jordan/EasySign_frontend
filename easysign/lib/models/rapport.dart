class Rapport {
  final int id;
  final int organisationId;
  final String date;
  final int totalPresent;
  final int totalAbsents;
  final int totalRetards;
  final int totalPauseRetards;

  Rapport({
    required this.id,
    required this.organisationId,
    required this.date,
    required this.totalPresent,
    required this.totalAbsents,
    required this.totalRetards,
    required this.totalPauseRetards,
  });

  factory Rapport.fromJson(Map<String, dynamic> json) => Rapport(
    id: json['id'],
    organisationId: json['organisation_id'],
    date: json['date'],
    totalPresent: json['total_present'],
    totalAbsents: json['total_absents'],
    totalRetards: json['total_retards'],
    totalPauseRetards: json['total_pause_retards'],
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'organisation_id': organisationId,
    'date': date,
    'total_present': totalPresent,
    'total_absents': totalAbsents,
    'total_retards': totalRetards,
    'total_pause_retards': totalPauseRetards,
  };
}
