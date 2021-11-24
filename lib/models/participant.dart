import 'package:cloud_firestore/cloud_firestore.dart';

class Participant {
  String? id;
  DateTime createdAt;
  String createdBy;
  String myUserId;
  String? nickname;
  String role;
  DateTime updatedAt;

  Participant(
      {this.id,
      required this.createdAt,
      required this.createdBy,
      required this.myUserId,
      this.nickname,
      required this.role,
      required this.updatedAt});

  factory Participant.fromMap(Map<String, dynamic>? json, String documentId) {
    if (json == null) {
      throw StateError('missing data for participantId: $documentId');
    }
    DateTime? createdAt = (json['createdAt'] as Timestamp?)?.toDate();
    if (createdAt == null) {
      throw StateError(
          'missing data for participantId: $documentId: createdAt null');
    }
    String? createdBy = json['createdBy'] as String?;
    if (createdBy == null) {
      throw StateError(
          'missing data for participantId: $documentId: createdBy null');
    }
    String? myUserId = json['myUserId'] as String?;
    if (myUserId == null) {
      throw StateError(
          'missing data for participantId: $documentId: myUserId null');
    }
    String? role = json['role'] as String?;
    if (role == null) {
      throw StateError(
          'missing data for participantId: $documentId: role null');
    }
    DateTime? updatedAt = (json['updatedAt'] as Timestamp?)?.toDate();
    if (updatedAt == null) {
      throw StateError(
          'missing data for participantId: $documentId: updatedAt null');
    }
    return Participant(
      id: documentId,
      createdAt: createdAt,
      createdBy: createdBy,
      myUserId: myUserId,
      nickname: json['nickname'] as String?,
      role: role,
      updatedAt: updatedAt,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'createdAt': createdAt,
      'createdBy': createdBy,
      'myUserId': myUserId,
      'nickname': nickname,
      'role': role,
      'updatedAt': updatedAt,
    };
  }

  @override
  String toString() => toMap().toString();
}
