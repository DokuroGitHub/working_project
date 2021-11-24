import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:working_project/models/attachment.dart';

class Comment {
  String? documentPath;
  List<Attachment> attachments;
  DateTime createdAt;
  String createdBy;
  DateTime? deletedAt;
  DateTime? editedAt;
  String? text;

  Comment(
      {this.documentPath,
      required this.attachments,
      required this.createdAt,
      required this.createdBy,
        this.deletedAt,
      this.editedAt,
        this.text,});

  factory Comment.fromMap(Map<String, dynamic>? json, String documentPath) {
    if (json == null) {
      throw StateError('missing data for commentId: $documentPath');
    }
    var attachments = json['attachments'] as List<Map<String, dynamic>?>?;
    DateTime? createdAt = (json['createdAt'] as Timestamp?)?.toDate();
    if (createdAt == null) {
      throw StateError('missing data for commentId: $documentPath: createdAt null');
    }
    String? createdBy = json['createdBy'] as String?;
    if (createdBy == null) {
      throw StateError('missing data for commentId: $documentPath: createdBy null');
    }
    return Comment(
        documentPath: documentPath,
        attachments: _convertMapToListAttachment(attachments),
        createdAt: createdAt,
        createdBy: createdBy,
        deletedAt: (json['deletedAt'] as Timestamp?)!.toDate(),
        editedAt: (json['editedAt'] as Timestamp?)!.toDate(),
        text: json['shipmentId'] as String?);
  }

  Map<String, dynamic> toMap() {
    return {
      'attachments': _convertListAttachmentToMap(attachments),
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

List<Attachment> _convertMapToListAttachment(
    List<Map<String, dynamic>?>? json) {
  if (json == null) {
    return [];
  }
  List<Attachment> attachments = [];
  for (var value in json) {
    if (value != null) {
      attachments.add(Attachment.fromMap(value));
    }
  }
  return attachments;
}

List<Map<String, dynamic>?>? _convertListAttachmentToMap(
    List<Attachment> attachments) {
  if (attachments.isEmpty) {
    return [];
  }
  List<Map<String, dynamic>?>? map = [];
  for (var value in attachments) {
    map.add(value.toMap());
  }
  return map;
}
