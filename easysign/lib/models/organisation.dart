class Organisation {
  final int id;
  final String nom;
  final String adresse;
  final int user_id;

  Organisation({
    required this.id,
    required this.nom,
    required this.adresse,
    required this.user_id,
  });

  factory Organisation.fromJson(Map<String, dynamic> json) => Organisation(
    id: json['id'],
    nom: json['nom'],
    adresse: json['adresse'],
    user_id: json['user_id'],
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'nom': nom,
    'adresse': adresse,
    'user_id': user_id,
  };
}
