class ProfilEntreprise {
  final String? id;
  final String? userId;
  final String nomEntreprise;
  final String nomGerant;
  final String adresse;
  final String codePostal;
  final String ville;
  final String siret;
  final String email;
  final String? telephone;
  final String? iban;
  final String? bic;
  final String frequenceCotisation;

  // CHANGEMENT MAJEUR : Stockage par URL (Cloud) et non Base64 (RAM)
  final String? logoUrl;
  final String? signatureUrl;

  final String? mentionsLegales;

  ProfilEntreprise({
    this.id,
    this.userId,
    required this.nomEntreprise,
    required this.nomGerant,
    required this.adresse,
    required this.codePostal,
    required this.ville,
    required this.siret,
    required this.email,
    this.telephone,
    this.iban,
    this.bic,
    required this.frequenceCotisation,
    this.logoUrl,
    this.signatureUrl,
    this.mentionsLegales,
  });

  factory ProfilEntreprise.fromMap(Map<String, dynamic> map) {
    return ProfilEntreprise(
      id: map['id'],
      userId: map['user_id'],
      nomEntreprise: map['nom_entreprise'] ?? '',
      nomGerant: map['nom_gerant'] ?? '',
      adresse: map['adresse'] ?? '',
      codePostal: map['code_postal'] ?? '',
      ville: map['ville'] ?? '',
      siret: map['siret'] ?? '',
      email: map['email'] ?? '',
      telephone: map['telephone'],
      iban: map['iban'],
      bic: map['bic'],
      frequenceCotisation: map['frequence_cotisation'] ?? 'mois',
      logoUrl: map['logo_url'], // Mapping vers la colonne URL
      signatureUrl: map['signature_url'], // Mapping vers la colonne URL
      mentionsLegales: map['mentions_legales'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'user_id': userId,
      'nom_entreprise': nomEntreprise,
      'nom_gerant': nomGerant,
      'adresse': adresse,
      'code_postal': codePostal,
      'ville': ville,
      'siret': siret,
      'email': email,
      'telephone': telephone,
      'iban': iban,
      'bic': bic,
      'frequence_cotisation': frequenceCotisation,
      'logo_url': logoUrl,
      'signature_url': signatureUrl,
      'mentions_legales': mentionsLegales,
    };
  }

  ProfilEntreprise copyWith({
    String? id,
    String? userId,
    String? nomEntreprise,
    String? nomGerant,
    String? adresse,
    String? codePostal,
    String? ville,
    String? siret,
    String? email,
    String? telephone,
    String? iban,
    String? bic,
    String? frequenceCotisation,
    String? logoUrl,
    String? signatureUrl,
    String? mentionsLegales,
  }) {
    return ProfilEntreprise(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      nomEntreprise: nomEntreprise ?? this.nomEntreprise,
      nomGerant: nomGerant ?? this.nomGerant,
      adresse: adresse ?? this.adresse,
      codePostal: codePostal ?? this.codePostal,
      ville: ville ?? this.ville,
      siret: siret ?? this.siret,
      email: email ?? this.email,
      telephone: telephone ?? this.telephone,
      iban: iban ?? this.iban,
      bic: bic ?? this.bic,
      frequenceCotisation: frequenceCotisation ?? this.frequenceCotisation,
      logoUrl: logoUrl ?? this.logoUrl,
      signatureUrl: signatureUrl ?? this.signatureUrl,
      mentionsLegales: mentionsLegales ?? this.mentionsLegales,
    );
  }
}
