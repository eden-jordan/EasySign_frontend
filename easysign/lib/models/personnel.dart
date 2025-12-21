class Personnel {
  final int id;
  final String nom;
  final String prenom;
  final String? email;
  final String? tel;
  final String? qrCode;
  final int? organisation_id;

  Personnel({
    required this.id,
    required this.nom,
    required this.prenom,
    this.email,
    this.tel,
    this.qrCode,
    this.organisation_id,
  });

  factory Personnel.fromJson(Map<String, dynamic> json) => Personnel(
    id: json['id'],
    nom: json['nom'],
    prenom: json['prenom'],
    email: json['email'],
    tel: json['tel'],
    qrCode: json['qr_code'],
    organisation_id: json['organisation_id'],
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'nom': nom,
    'prenom': prenom,
    'email': email,
    'tel': tel,
    'qr_code': qrCode,
    'organisation_id': organisation_id,
  };

  Personnel copyWith({
    String? nom,
    String? prenom,
    String? email,
    String? tel,
  }) {
    return Personnel(
      id: id,
      nom: nom ?? this.nom,
      prenom: prenom ?? this.prenom,
      email: email ?? this.email,
      tel: tel ?? this.tel,
    );
  }
}
