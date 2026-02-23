class SupportTicket {
  final String? id;
  final String? userId;
  final String subject;
  final String description;
  final String status;
  final String? aiResolution;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  SupportTicket({
    this.id,
    this.userId,
    required this.subject,
    required this.description,
    this.status = 'open',
    this.aiResolution,
    this.createdAt,
    this.updatedAt,
  });

  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      if (userId != null) 'user_id': userId,
      'subject': subject,
      'description': description,
      'status': status,
      if (aiResolution != null) 'ai_resolution': aiResolution,
    };
  }

  factory SupportTicket.fromMap(Map<String, dynamic> map) {
    return SupportTicket(
      id: map['id'],
      userId: map['user_id'],
      subject: map['subject'],
      description: map['description'],
      status: map['status'] ?? 'open',
      aiResolution: map['ai_resolution'],
      createdAt:
          map['created_at'] != null ? DateTime.parse(map['created_at']) : null,
      updatedAt:
          map['updated_at'] != null ? DateTime.parse(map['updated_at']) : null,
    );
  }
}
