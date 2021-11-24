import 'package:cloud_firestore/cloud_firestore.dart';
import 'address.dart';
import 'shipper_info.dart';

class MyUser {
  String? id;
  Address? address;
  DateTime? birthDate;
  DateTime createdAt;
  String? email;
  bool isActive;
  bool isBlocked;
  DateTime lastSignInAt;
  String? name;
  String? phoneNumber;
  String? photoURL;
  String role;
  String? selfIntroduction;
  ShipperInfo? shipperInfo;

  MyUser({
    this.id,
    this.address,
    this.birthDate,
    required this.createdAt,
    this.email,
    required this.isActive,
    required this.isBlocked,
    required this.lastSignInAt,
    this.name,
    this.phoneNumber,
    this.photoURL,
    required this.role,
    this.selfIntroduction,
    this.shipperInfo,
  });

  factory MyUser.fromMap(Map<String, dynamic>? json, String documentId) {
    if (json == null) {
      throw StateError('missing data for userId: $documentId');
    }
    DateTime? createdAt = (json['createdAt'] as Timestamp?)?.toDate();
    if (createdAt == null) {
      throw StateError('missing data for userId: $documentId: createdAt null');
    }
    bool? isActive = json['isActive'] as bool?;
    if (isActive == null) {
      throw StateError('missing data for userId: $documentId: isActive null');
    }
    bool? isBlocked = json['isBlocked'] as bool?;
    if (isBlocked == null) {
      throw StateError('missing data for userId: $documentId: isBlocked null');
    }
    DateTime? lastSignInAt = (json['lastSignInAt'] as Timestamp?)?.toDate();
    if (lastSignInAt == null) {
      throw StateError(
          'missing data for userId: $documentId: lastSignInAt null');
    }
    String? role = json['role'] as String?;
    if (role == null) {
      throw StateError('missing data for userId: $documentId: role null');
    }
    return MyUser(
      id: documentId,
      address: _convertMapToAddress(json['address'] as Map<String, dynamic>?),
      birthDate: (json['birthDate'] as Timestamp?)?.toDate(),
      createdAt: createdAt,
      email: json['email'] as String?,
      isActive: isActive,
      isBlocked: isBlocked,
      lastSignInAt: lastSignInAt,
      name: json['name'] as String?,
      phoneNumber: json['phoneNumber'] as String?,
      photoURL: json['photoURL'] as String?,
      role: role,
      selfIntroduction: json['selfIntroduction'] as String?,
      shipperInfo: _convertMapToShipperInfo(
          json['shipperInfo'] as Map<String, dynamic>?),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'address': _convertAddressToMap(address),
      'birthDate': birthDate,
      'createdAt': createdAt,
      'email': email,
      'isActive': isActive,
      'isBlocked': isBlocked,
      'lastSignInAt': lastSignInAt,
      'name': name,
      'phoneNumber': phoneNumber,
      'photoURL': photoURL,
      'role': role,
      'selfIntroduction': selfIntroduction,
      'shipperInfo': _convertShipperInfoToMap(shipperInfo),
    };
  }

  @override
  String toString() => toMap().toString()+', id: $id';
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

Map<String, dynamic>? _convertShipperInfoToMap(ShipperInfo? shipperInfo) {
  if (shipperInfo == null) {
    return null;
  }
  return shipperInfo.toMap();
}

ShipperInfo? _convertMapToShipperInfo(Map<String, dynamic>? json) {
  if (json == null) {
    return null;
  }
  return ShipperInfo.fromMap(json);
}
