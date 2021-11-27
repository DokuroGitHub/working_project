import 'package:cloud_firestore/cloud_firestore.dart';

class Offer {
  String? id;
  DateTime createdAt;
  String createdBy;
  String? notes;
  num price;

  Offer(
      {this.id,
        required this.createdAt,
        required this.createdBy,
        this.notes,
        required this.price,
      });

  factory Offer.fromMap(Map<String, dynamic>? json, String documentId) {
    if (json == null) {
      throw StateError('missing data for offerId: $documentId');
    }
    DateTime? createdAt = (json['createdAt'] as Timestamp?)?.toDate();
    if (createdAt == null) {
      throw StateError(
          'missing data for offerId: $documentId: createdAt null');
    }
    String? createdBy = json['createdBy'] as String?;
    if (createdBy == null) {
      throw StateError(
          'missing data for offerId: $documentId: createdBy null');
    }
    return Offer(
      id: documentId,
      createdAt: createdAt,
      createdBy: createdBy,
      notes: json['notes'] as String?,
      price: json['price'] as num? ?? 0,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'createdAt': createdAt,
      'createdBy': createdBy,
      'notes': notes,
      'price': price,
    };
  }

  @override
  String toString() => toMap().toString();
}
