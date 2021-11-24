import 'package:cloud_firestore/cloud_firestore.dart';
import 'attachment.dart';
import 'parcel.dart';

import 'address.dart';

class Shipment {
  String? id;
  Address? addressFrom;
  Address? addressTo;
  List<Attachment> attachments;
  num cod;
  DateTime createdAt;
  String createdBy;
  String? notes;
  Parcel? parcel;
  String? postId;
  String service;
  String? shipperId;
  List<String> shippersEnrolled;
  String status;
  String type;

  Shipment({
    this.id,
    this.addressFrom,
    this.addressTo,
    required this.attachments,
    required this.cod,
    required this.createdAt,
    required this.createdBy,
    this.notes,
    this.parcel,
    this.postId,
    required this.service,
    this.shipperId,
    required this.shippersEnrolled,
    required this.status,
    required this.type
  });

  factory Shipment.fromMap(Map<String, dynamic>? json, String documentId) {
    if (json == null) {
      throw StateError('missing data for shipmentId: $documentId');
    }
    DateTime? createdAt = (json['createdAt'] as Timestamp?)?.toDate();
    if(createdAt == null){
      throw StateError('missing data for shipmentId: $documentId: createdAt null');
    }
    String? createdBy = json['createdBy'] as String?;
    if(createdBy == null){
      throw StateError('missing data for shipmentId: $documentId: createdBy null');
    }
    String? service = json['service'] as String?;
    if(service == null){
      throw StateError('missing data for shipmentId: $documentId: service null');
    }
    String? status = json['status'] as String?;
    if(status == null){
      throw StateError('missing data for shipmentId: $documentId: status null');
    }
    String? type = json['type'] as String?;
    if(type == null){
      throw StateError('missing data for shipmentId: $documentId: type null');
    }
    return Shipment(
      id: documentId,
        addressFrom: _convertMapToAddress(json['addressFrom'] as Map<String, dynamic>?),
        addressTo: _convertMapToAddress(json['addressTo'] as Map<String, dynamic>?),
        attachments: _convertMapToListAttachment(json['attachments'] as List<dynamic>),
        cod: json['cod'] as num? ?? 0,
        createdAt: createdAt,
        createdBy:createdBy,
        notes: json['notes'] as String?,
        parcel: _convertMapToParcel(json['parcel'] as Map<String, dynamic>?),
        postId: json['postId'] as String?,
        service:service,
        shipperId: json['shipperId'] as String?,
        shippersEnrolled: _convertMapToListString(json['shippersEnrolled'] as List<dynamic>?),
        status:status,
        type: type
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'addressFrom': _convertAddressToMap(addressFrom),
      'addressTo': _convertAddressToMap(addressTo),
      'attachments': _convertListAttachmentToMap(attachments),
      'cod': cod,
      'createdAt': createdAt,
      'createdBy':createdBy,
      'notes': notes,
      'parcel': _convertParcelToMap(parcel),
      'postId': postId,
      'service':service,
      'shipperId': shipperId,
      'shippersEnrolled':shippersEnrolled,
      'status':status,
      'type': type
    };
  }

  @override
  String toString() => toMap().toString();
}

Map<String, dynamic>? _convertAddressToMap(Address? address) {
  if (address == null) {
    return null;
  }
  return address.toMap();
}

Address? _convertMapToAddress(Map<String, dynamic>? json) {
  if (json == null) {
    return null;
  }
  return Address.fromMap(json);
}


List<String> _convertMapToListString(
    List<dynamic>? json) {
  if (json == null) {
    return [];
  }
  List<String> shippersEnrolled = [];
  for (var value in json) {
    if (value != null) {
      shippersEnrolled.add(value as String);
    }
  }
  return shippersEnrolled;
}

Map<String, dynamic>? _convertParcelToMap(Parcel? parcel) {
  if (parcel == null) {
    return null;
  }
  return parcel.toMap();
}

Parcel? _convertMapToParcel(Map<String, dynamic>? json) {
  if (json == null) {
    return null;
  }
  return Parcel.fromMap(json);
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