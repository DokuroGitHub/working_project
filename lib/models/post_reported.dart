import 'package:cloud_firestore/cloud_firestore.dart';

class PostReported {
  String? id;
  DateTime createdAt;
  String createdBy;
  String postId;
  String status;
  String? text;
  String type;

  PostReported(
      {this.id,
      required this.createdAt,
      required this.createdBy,
      required this.postId,
      required this.status,
      this.text,
      required this.type});

  factory PostReported.fromMap(Map<String, dynamic>? json, String documentId) {
    if (json == null) {
      throw StateError('missing data for post_reportedId: $documentId');
    }
    DateTime? createdAt = (json['createdAt'] as Timestamp?)?.toDate();
    if (createdAt == null) {
      throw StateError(
          'missing data for post_reportedId: $documentId: createdAt null');
    }
    String? createdBy = json['createdBy'] as String?;
    if (createdBy == null) {
      throw StateError(
          'missing data for post_reportedId: $documentId: createdBy null');
    }
    String? postId = json['postId'] as String?;
    if (postId == null) {
      throw StateError(
          'missing data for post_reportedId: $documentId: postId null');
    }
    String? status = json['status'] as String?;
    if (status == null) {
      throw StateError(
          'missing data for post_reportedId: $documentId: status null');
    }
    String? type = json['type'] as String?;
    if (type == null) {
      throw StateError(
          'missing data for post_reportedId: $documentId: type null');
    }
    return PostReported(
      id: documentId,
      createdAt: createdAt,
      createdBy: createdBy,
      postId: postId,
      status: status,
      text: json['text'] as String?,
      type: type,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'createdAt': createdAt,
      'createdBy': createdBy,
      'postId': postId,
      'status': status,
      'text': text,
      'type': type,
    };
  }

  @override
  String toString() => toMap().toString();
}
