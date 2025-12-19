class User {
  final int id;
  final String nom;
  final String prenom;
  final String email;
  final String? tel;
  final String role;

  User({
    required this.id,
    required this.nom,
    required this.prenom,
    required this.email,
    this.tel,
    required this.role,
  });

  factory User.fromJson(Map<String, dynamic> json) => User(
    id: json['id'],
    nom: json['nom'],
    prenom: json['prenom'],
    email: json['email'],
    tel: json['tel'],
    role: json['role'],
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'nom': nom,
    'prenom': prenom,
    'email': email,
    'tel': tel,
    'role': role,
  };
}
