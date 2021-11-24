import 'package:cloud_firestore/cloud_firestore.dart';

class Reply {
  DateTime createdAt;
  String text;

  Reply({
    required this.createdAt,
    required this.text,
  });

  factory Reply.fromMap(Map<String, dynamic>? json) {
    if (json == null) {
      throw StateError('missing data for Reply');
    }
    DateTime? createdAt = (json['createdAt'] as Timestamp?)?.toDate();
    if (createdAt == null) {
      throw StateError('missing data for Reply: createdAt null');
    }
    String? text = json['text'] as String?;
    if (text == null) {
      throw StateError('missing data for Reply: text null');
    }
    return Reply(
        createdAt: createdAt,
        text: text
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'createdAt': createdAt,
      'text': text
    };
  }

  @override
  String toString() => toMap().toString();
}