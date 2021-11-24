// Copyright 2021, the Chromium project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:flutter/foundation.dart';

@immutable
class ShipperInfo {
  final String? status;
  final String? vehicleDescription;
  final String? vehicleType;

  const ShipperInfo({
    this.status,
    this.vehicleDescription,
    this.vehicleType,
  });

  factory ShipperInfo.fromMap(Map<String, dynamic>? json) {
    if (json == null) {
      throw StateError('missing data for ShipperInfo');
    }
    return ShipperInfo(
      status: json['status']! as String?,
      vehicleDescription: json['vehicleDescription']! as String?,
      vehicleType: json['vehicleType']! as String?,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'status': status,
      'vehicleDescription': vehicleDescription,
      'vehicleType': vehicleType,
    };
  }
}
