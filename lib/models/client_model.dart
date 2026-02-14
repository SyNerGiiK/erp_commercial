class Client {
  final String? id;
  final String? userId;
  final String nomComplet;
  final String typeClient; // 'particulier' ou 'professionnel'
  final String? nomContact;
  final String? siret;
  final String? tvaIntra;
  final String adresse;
  final String codePostal;
  final String ville;
  final String telephone;
  final String email;
  final String? notesPrivees;

  Client({
    this.id,
    this.userId,
    required this.nomComplet,
    this.typeClient = 'particulier',
    this.nomContact,
    this.siret,
    this.tvaIntra,
    required this.adresse,
    required this.codePostal,
    required this.ville,
    required this.telephone,
    required this.email,
    this.notesPrivees,
  });

  factory Client.fromMap(Map<String, dynamic> map) {
    return Client(
      id: map['id'],
      userId: map['user_id'],
      nomComplet: map['nom_complet'] ?? '',
      typeClient: map['type_client'] ?? 'particulier',
      nomContact: map['nom_contact'],
      siret: map['siret'],
      tvaIntra: map['tva_intra'],
      adresse: map['adresse'] ?? '',
      codePostal: map['code_postal'] ?? '',
      ville: map['ville'] ?? '',
      telephone: map['telephone'] ?? '',
      email: map['email'] ?? '',
      notesPrivees: map['notes_privees'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'user_id': userId,
      'nom_complet': nomComplet,
      'type_client': typeClient,
      'nom_contact': nomContact,
      'siret': siret,
      'tva_intra': tvaIntra,
      'adresse': adresse,
      'code_postal': codePostal,
      'ville': ville,
      'telephone': telephone,
      'email': email,
      'notes_privees': notesPrivees,
    };
  }

  Client copyWith({
    String? id,
    String? userId,
    String? nomComplet,
    String? typeClient,
    String? nomContact,
    String? siret,
    String? tvaIntra,
    String? adresse,
    String? codePostal,
    String? ville,
    String? telephone,
    String? email,
    String? notesPrivees,
  }) {
    return Client(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      nomComplet: nomComplet ?? this.nomComplet,
      typeClient: typeClient ?? this.typeClient,
      nomContact: nomContact ?? this.nomContact,
      siret: siret ?? this.siret,
      tvaIntra: tvaIntra ?? this.tvaIntra,
      adresse: adresse ?? this.adresse,
      codePostal: codePostal ?? this.codePostal,
      ville: ville ?? this.ville,
      telephone: telephone ?? this.telephone,
      email: email ?? this.email,
      notesPrivees: notesPrivees ?? this.notesPrivees,
    );
  }
}
