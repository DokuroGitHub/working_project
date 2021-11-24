import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:working_project/models/message_last.dart';

class Conversation {
  String? id;
  DateTime createdAt;
  String? createdBy;
  String? description;
  List<String> members;
  MessageLast? messageLast;
  String? photoURL;
  String? title;

  Conversation({
    this.id,
    required this.createdAt,
    this.createdBy,
    this.description,
    this.messageLast,
    required this.members,
    this.photoURL,
    this.title,
  });

  factory Conversation.fromMap(Map<String, dynamic>? json, String documentId) {
    if (json == null) {
      throw StateError('missing data for conversationId: $documentId');
    }
    DateTime? createdAt = (json['createdAt'] as Timestamp?)?.toDate();
    if (createdAt == null) {
      throw StateError(
          'missing data for conversationId: $documentId: createdAt null');
    }
    return Conversation(
      id: documentId,
      createdAt: createdAt,
      createdBy: json['createdBy'] as String?,
      description: json['description'] as String?,
      messageLast: _convertMapToLastMassage(
          json['messageLast'] as Map<String, dynamic>?),
      members: json['members']!=null? (json['members'] as List?)!.cast<String>() : [],
      photoURL: json['photoURL'] as String?,
      title: json['title'] as String?,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'createdAt': createdAt,
      'createdBy': createdBy,
      'description': description,
      'messageLast': _convertLastMessageToMap(messageLast),
      'members': members,
      'photoURL': photoURL,
      'title': title,
    };
  }

  @override
  String toString() => toMap().toString();
}

Map<String, dynamic>? _convertLastMessageToMap(MessageLast? messageLast) {
  if (messageLast == null) {
    return null;
  }
  return messageLast.toMap();
}

MessageLast? _convertMapToLastMassage(Map<String, dynamic>? json) {
  if (json == null) {
    return null;
  }
  return MessageLast.fromMap(json);
}
