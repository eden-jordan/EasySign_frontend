class User {
  final int id;
  final String nom;
  final String prenom;
  final String email;
  final String role;
  final int? organisationId;

  User({
    required this.id,
    required this.nom,
    required this.prenom,
    required this.email,
    required this.role,
    this.organisationId,
  });

  factory User.fromJson(Map<String, dynamic> json) => User(
    id: json['id'],
    nom: json['nom'],
    prenom: json['prenom'],
    email: json['email'],
    role: json['role'],
    organisationId: json['organisation_id'],
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'nom': nom,
    'prenom': prenom,
    'email': email,
    'role': role,
    'organisation_id': organisationId,
  };
}
