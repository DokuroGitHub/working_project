import 'package:cloud_firestore/cloud_firestore.dart';
import 'attachment.dart';

class Message {
  String? id;
  List<Attachment> attachments;
  DateTime createdAt;
  String createdBy;
  String? replyToMessageId;
  String? text;

  Message(
      {this.id,
        required this.attachments,
        required this.createdAt,
        required this.createdBy,
        this.replyToMessageId,
        this.text,});

  factory Message.fromMap(Map<String, dynamic>? json, String documentId) {
    if (json == null) {
      throw StateError('missing data for messageId: $documentId');
    }
    var attachments = json['attachments'] as List<dynamic>;
    DateTime? createdAt = (json['createdAt'] as Timestamp?)?.toDate();
    if (createdAt == null) {
      throw StateError('missing data for commentId: $documentId: createdAt null');
    }
    String? createdBy = json['createdBy'] as String?;
    if (createdBy == null) {
      throw StateError('missing data for commentId: $documentId: createdBy null');
    }
    return Message(
        id: documentId,
        attachments: _convertMapToListAttachment(attachments),
        createdAt: createdAt,
        createdBy: createdBy,
        replyToMessageId: json['replyToMessageId'] as String?,
        text: json['text'] as String?);
  }

  Map<String, dynamic> toMap() {
    return {
      'attachments': _convertListAttachmentToMap(attachments),
      'createdAt': createdAt,
      'createdBy': createdBy,
      'replyToMessageId':replyToMessageId,
      'text': text
    };
  }

  @override
  String toString() => toMap().toString();
}

List<Attachment> _convertMapToListAttachment(
    List<dynamic>? json) {
  if (json == null) {
    return [];
  }
  List<Attachment> attachments = [];
  for (var value in json) {
    if (value != null) {
      attachments.add(Attachment.fromMap(value as Map<String, dynamic>?));
    }
  }
  return attachments;
}

List<Map<String, dynamic>> _convertListAttachmentToMap(
    List<Attachment> attachments) {
  if (attachments.isEmpty) {
    return [];
  }
  List<Map<String, dynamic>> map = [];
  for (var value in attachments) {
    map.add(value.toMap());
  }
  return map;
}
