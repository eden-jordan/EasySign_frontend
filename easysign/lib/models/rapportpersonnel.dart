class Rapportpersonnel {
  final int id;
  final String nom;
  final int present;
  final int absent;
  final int retard;
  final int retardPause;

  Rapportpersonnel({
    required this.id,
    required this.nom,
    required this.present,
    required this.absent,
    required this.retard,
    required this.retardPause,
  });

  factory Rapportpersonnel.fromJson(Map<String, dynamic> json) {
    return Rapportpersonnel(
      id: json['id'],
      nom: json['nom'],
      present: json['present'],
      absent: json['absent'],
      retard: json['retard'],
      retardPause: json['retard_pause'],
    );
  }
}
