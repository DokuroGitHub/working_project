import 'package:cloud_firestore/cloud_firestore.dart';
import 'attachment.dart';
import 'reply.dart';

class FeedBack {
  String? id;
  List<Attachment> attachments;
  DateTime createdAt;
  String createdBy;
  num rating;
  Reply? reply;
  String? text;

  FeedBack(
      {this.id,
      required this.attachments,
      required this.createdAt,
      required this.createdBy,
      required this.rating,
      this.reply,
      this.text});

  factory FeedBack.fromMap(Map<String, dynamic>? json, String documentId) {
    if (json == null) {
      throw StateError('missing data for feedbackId: $documentId');
    }
    var attachments = json['attachments'] as List<dynamic>?;
    DateTime? createdAt = (json['createdAt'] as Timestamp?)?.toDate();
    if (createdAt == null) {
      throw StateError(
          'missing data for feedbackId: $documentId: createdAt null');
    }
    String? createdBy = json['createdBy'] as String?;
    if (createdBy == null) {
      throw StateError(
          'missing data for feedbackId: $documentId: createdBy null');
    }
    int? rating = json['rating'] as int?;
    if (rating == null) {
      throw StateError('missing data for postId: $documentId: rating null');
    }
    return FeedBack(
        id: documentId,
        attachments: _convertMapToListAttachment(attachments),
        createdAt: createdAt,
        createdBy: createdBy,
        rating: json['rating'] as num? ?? 0,
        reply: _convertMapToReply(json['reply'] as Map<String, dynamic>?),
        text: json['text'] as String?);
  }

  Map<String, dynamic> toMap() {
    return {
      'attachments': _convertListAttachmentToMap(attachments),
      'createdAt': createdAt,
      'createdBy': createdBy,
      'rating': rating,
      'reply': _convertReplyToMap(reply),
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

Map<String, dynamic>? _convertReplyToMap(Reply? reply) {
  if (reply == null) {
    return null;
  }
  return reply.toMap();
}

Reply? _convertMapToReply(Map<String, dynamic>? json) {
  if (json == null) {
    return null;
  }
  return Reply.fromMap(json);
}

enum FeedBackQuery{
  createdAtAsc,
  createdAtDesc,
  ratingAsc,
  ratingDesc,
}