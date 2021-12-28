import 'package:cloud_firestore/cloud_firestore.dart';
import 'attachment.dart';

class Post {
  String? id;
  List<Attachment> attachments;
  String? text;
  DateTime createdAt;
  String createdBy;
  DateTime? editedAt;
  String? shipmentId;

  Post(
      {this.id,
      required this.attachments,
      this.text,
      required this.createdAt,
      required this.createdBy,
      this.editedAt,
      this.shipmentId});

  factory Post.fromMap(Map<String, dynamic>? json, String documentId) {
    if (json == null) {
      throw StateError('missing data for postId: $documentId');
    }
    var attachments = json['attachments'] as List<dynamic>;
    DateTime? createdAt = (json['createdAt'] as Timestamp?)?.toDate();
    if (createdAt == null) {
      throw StateError('missing data for postId: $documentId: createdAt null');
    }
    String? createdBy = json['createdBy'] as String?;
    if (createdBy == null) {
      throw StateError('missing data for postId: $documentId: createdBy null');
    }
    return Post(
        id: documentId,
        attachments: _convertMapToListAttachment(attachments),
        text: json['text'] as String?,
        createdAt: createdAt,
        createdBy: createdBy,
        editedAt: (json['editedAt'] as Timestamp?)?.toDate(),
        shipmentId: json['shipmentId'] as String?);
  }

  Map<String, dynamic> toMap() {
    return {
      'attachments': _convertListAttachmentToMap(attachments),
      'text': text,
      'createdAt': createdAt,
      'createdBy': createdBy,
      'editedAt': editedAt,
      'shipmentId': shipmentId
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

enum PostQuery{
  createdAtAsc,
  createdAtDesc,
}