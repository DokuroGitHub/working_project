class Attachment {
  String? thumbURL;
  String fileURL;
  String type;

  Attachment({
    this.thumbURL,
    required this.fileURL,
    required this.type,
  });

  factory Attachment.fromMap(Map<String, dynamic>? json) {
    if (json == null) {
      throw StateError('missing data for Attachment');
    }
    String? fileURL = json['fileURL'] as String?;
    if(fileURL == null){
      throw StateError('missing data for Attachment fileURL null');
    }
    String? type = json['type'] as String?;
    if(type == null){
      throw StateError('missing data for Attachment type null');
    }
    return Attachment(
        thumbURL: json['thumbURL'] as String?,
        fileURL: fileURL,
        type: type
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'thumbURL': thumbURL,
      'fileURL': fileURL,
      'type': type
    };
  }

  @override
  String toString() => toMap().toString();
}