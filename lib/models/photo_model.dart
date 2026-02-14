class PhotoChantier {
  final String? id;
  final String clientId;
  final String url;
  final String? commentaire;
  final DateTime createdAt;

  PhotoChantier({
    this.id,
    required this.clientId,
    required this.url,
    this.commentaire,
    required this.createdAt,
  });

  factory PhotoChantier.fromMap(Map<String, dynamic> map) {
    return PhotoChantier(
      id: map['id'],
      clientId: map['client_id'],
      url: map['url'],
      commentaire: map['commentaire'],
      createdAt: DateTime.parse(map['created_at']),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'client_id': clientId,
      'url': url,
      'commentaire': commentaire,
      'created_at': createdAt.toIso8601String(),
    };
  }

  PhotoChantier copyWith({
    String? id,
    String? clientId,
    String? url,
    String? commentaire,
    DateTime? createdAt,
  }) {
    return PhotoChantier(
      id: id ?? this.id,
      clientId: clientId ?? this.clientId,
      url: url ?? this.url,
      commentaire: commentaire ?? this.commentaire,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
