class Emote {
  String? id;
  String createdBy;
  String emoteCode;

  Emote({
    this.id,
    required this.createdBy,
    required this.emoteCode,
  });

  factory Emote.fromMap(Map<String, dynamic>? json, String documentId) {
    if (json == null) {
      throw StateError('missing data for emoteId: $documentId');
    }
    String? createdBy = json['createdBy'] as String?;
    if (createdBy == null) {
      throw StateError('missing data for Reply: createdBy null');
    }
    String? emoteCode = json['emoteCode'] as String?;
    if (emoteCode == null) {
      throw StateError('missing data for Reply: emoteCode null');
    }
    return Emote(id: documentId, createdBy: createdBy, emoteCode: emoteCode);
  }

  Map<String, dynamic> toMap() {
    return {'createdBy': createdBy, 'emoteCode': emoteCode};
  }

  @override
  String toString() => toMap().toString();
}
