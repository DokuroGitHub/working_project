import 'package:cloud_firestore/cloud_firestore.dart';

class DeletedMessage {
  String? id;
  DateTime createdAt;
  String createdBy;
  String messageId;

  DeletedMessage({
    this.id,
    required this.createdAt,
    required this.createdBy,
    required this.messageId,
  });

  factory DeletedMessage.fromMap(
      Map<String, dynamic>? json, String documentId) {
    if (json == null) {
      throw StateError('missing data for deleted_messageId: $documentId');
    }
    DateTime? createdAt = (json['createdAt'] as Timestamp?)?.toDate();
    if (createdAt == null) {
      throw StateError(
          'missing data for deleted_messageId: $documentId: createdAt null');
    }
    String? createdBy = json['createdBy'] as String?;
    if (createdBy == null) {
      throw StateError(
          'missing data for deleted_messageId: $documentId: createdBy null');
    }
    String? messageId = json['messageId'] as String?;
    if (messageId == null) {
      throw StateError(
          'missing data for deleted_messageId: $documentId: messageId null');
    }
    return DeletedMessage(
      id: documentId,
      createdAt: createdAt,
      createdBy: createdBy,
      messageId: messageId,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'createdAt': createdAt,
      'createdBy': createdBy,
      'messageId': messageId,
    };
  }

  @override
  String toString() => toMap().toString();
}
