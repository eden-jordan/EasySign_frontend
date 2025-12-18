class Personnel {
  final int id;
  final String nom;
  final String prenom;
  final String email;
  final String tel;
  final String matricule;
  final String qrCode;
  final int organisationId;

  Personnel({
    required this.id,
    required this.nom,
    required this.prenom,
    required this.email,
    required this.tel,
    required this.matricule,
    required this.qrCode,
    required this.organisationId,
  });

  factory Personnel.fromJson(Map<String, dynamic> json) => Personnel(
    id: json['id'],
    nom: json['nom'],
    prenom: json['prenom'],
    email: json['email'],
    tel: json['tel'],
    matricule: json['matricule'],
    qrCode: json['qr_code'],
    organisationId: json['organisation_id'],
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'nom': nom,
    'prenom': prenom,
    'email': email,
    'tel': tel,
    'matricule': matricule,
    'qr_code': qrCode,
    'organisation_id': organisationId,
  };
}
