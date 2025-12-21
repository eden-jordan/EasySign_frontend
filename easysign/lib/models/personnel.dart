class Personnel {
  final int id;
  final String nom;
  final String prenom;
  final String? email;
  final String? tel;

  Personnel({
    required this.id,
    required this.nom,
    required this.prenom,
    this.email,
    this.tel,
  });

  factory Personnel.fromJson(Map<String, dynamic> json) => Personnel(
    id: json['id'],
    nom: json['nom'],
    prenom: json['prenom'],
    email: json['email'],
    tel: json['tel'],
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'nom': nom,
    'prenom': prenom,
    'email': email,
    'tel': tel,
  };
}
