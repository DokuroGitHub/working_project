import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:working_project/models/attachment.dart';

class Comment {
  String? id;
  String? documentPath;
  Attachment? attachment;
  DateTime createdAt;
  String createdBy;
  DateTime? deletedAt;
  DateTime? editedAt;
  String? text;

  Comment({
    this.id,
    this.documentPath,
    this.attachment,
    required this.createdAt,
    required this.createdBy,
    this.deletedAt,
    this.editedAt,
    this.text,
  });

  factory Comment.fromMap(
      Map<String, dynamic>? json, String documentId, String documentPath) {
    if (json == null) {
      throw StateError('missing data for commentId: $documentId');
    }
    DateTime? createdAt = (json['createdAt'] as Timestamp?)?.toDate();
    if (createdAt == null) {
      throw StateError(
          'missing data for commentId: $documentId: createdAt null');
    }
    String? createdBy = json['createdBy'] as String?;
    if (createdBy == null) {
      throw StateError(
          'missing data for commentId: $documentId: createdBy null');
    }
    return Comment(
        id: documentId,
        documentPath: documentPath,
        attachment: _convertMapToAttachment(json['attachment'] as Map<String, dynamic>?),
        createdAt: createdAt,
        createdBy: createdBy,
        deletedAt: (json['deletedAt'] as Timestamp?)?.toDate(),
        editedAt: (json['editedAt'] as Timestamp?)?.toDate(),
        text: json['text'] as String?);
  }

  Map<String, dynamic> toMap() {
    return {
      'attachment': _convertAttachmentToMap(attachment),
      'createdAt': createdAt,
      'createdBy': createdBy,
      'deletedAt': deletedAt,
      'editedAt': editedAt,
      'text': text
    };
  }

  @override
  String toString() => toMap().toString();
}

Attachment? _convertMapToAttachment(Map<String, dynamic>? json) {
  if (json == null) {
    return null;
  }
  return Attachment.fromMap(json);
}

Map<String, dynamic>? _convertAttachmentToMap(Attachment? attachment) {
  if (attachment == null) {
    return null;
  }
  return attachment.toMap();
}

enum CommentQuery{
  createdAtAsc,
  createdAtDesc,
}