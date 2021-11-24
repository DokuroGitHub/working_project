// Copyright 2021, the Chromium project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

@immutable
class Address {
  final String? details;
  final String? street;
  final String? district;
  final String? city;
  final GeoPoint? location;

  const Address({
    this.details,
    this.street,
    this.district,
    this.city,
    this.location,
  });

  factory Address.fromMap(Map<String, dynamic>? json) {
    if (json == null) {
      throw StateError('missing data');
    }
    return Address(
      details: json['details'] as String?,
      street: json['street'] as String?,
      district: json['district'] as String?,
      city: json['city'] as String?,
      location: json['location'] as GeoPoint?,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'details': details,
      'street': street,
      'district': district,
      'city': city,
      'location': location,
    };
  }
}
