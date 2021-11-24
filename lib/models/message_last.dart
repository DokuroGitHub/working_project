// Copyright 2021, the Chromium project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

@immutable
class MessageLast {
  final String text;
  final DateTime updatedAt;
  final String? updatedBy;

  const MessageLast({
    required this.text,
    required this.updatedAt,
    this.updatedBy,
  });

  factory MessageLast.fromMap(Map<String, dynamic>? json) {
    if (json == null) {
      throw StateError('missing data');
    }
    String? text = json['text'] as String?;
    if (text == null) {
      throw StateError('missing data for messageLast: text null');
    }
    DateTime? updatedAt = (json['updatedAt'] as Timestamp?)?.toDate();
    if (updatedAt == null) {
      throw StateError('missing data for messageLast: updatedAt null');
    }
    return MessageLast(
      text: text,
      updatedAt: updatedAt,
      updatedBy: json['updatedBy'] as String?,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'text': text,
      'updatedAt': updatedAt,
      'updatedBy': updatedBy,
    };
  }
}
