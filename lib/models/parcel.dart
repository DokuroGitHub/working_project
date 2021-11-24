// Copyright 2021, the Chromium project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.
import 'package:flutter/foundation.dart';

@immutable
class Parcel {
  final String? code;
  final String? description;
  final num? height;
  final num? length;
  final String? nameFrom;
  final String? nameTo;
  final String? phoneFrom;
  final String? phoneTo;
  final num? weight;
  final num? width;

  const Parcel({
    this.code,
    this.description,
    this.height,
    this.length,
    this.nameFrom,
    this.nameTo,
    this.phoneFrom,
    this.phoneTo,
    this.weight,
    this.width,
  });

  factory Parcel.fromMap(Map<String, dynamic>? json) {
    if (json == null) {
      throw StateError('missing data for Parcel');
    }
    return Parcel(
      code: json['code']! as String?,
      description: json['description']! as String?,
      height: json['height']! as num?,
      length: json['length']! as num?,
      nameFrom: json['nameFrom']! as String?,
      nameTo: json['nameTo']! as String?,
      phoneFrom: json['phoneFrom']! as String?,
      phoneTo: json['phoneTo']! as String?,
      weight: json['weight']! as num?,
      width: json['width']! as num?,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'code': code,
      'description': description,
      'height': height,
      'length': length,
      'nameFrom': nameFrom,
      'nameTo': nameTo,
      'phoneFrom': phoneFrom,
      'phoneTo': phoneTo,
      'weight': weight,
      'width': width,
    };
  }
}
