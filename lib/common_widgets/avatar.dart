import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

const String defaultPhotoURL =
    'https://yt3.ggpht.com/yti/APfAmoEUl_jqsKc0uhb1z2aakEsBQ7ISQllbZgOgA7lc=s88-c-k-c0x00ffffff-no-rj-mo';

class Avatar extends StatelessWidget {
  const Avatar({
    this.photoUrl,
    required this.radius,
    this.borderColor,
    this.borderWidth,
  });
  final String? photoUrl;
  final double radius;
  final Color? borderColor;
  final double? borderWidth;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: _borderDecoration(),
      child: CircleAvatar(
        radius: radius,
        backgroundColor: Colors.black12,
        backgroundImage: photoUrl != null ? NetworkImage(photoUrl!) : null,
        child: photoUrl == null ? Icon(Icons.camera_alt, size: radius) : null,
      ),
    );
  }

  Decoration? _borderDecoration() {
    if (borderColor != null && borderWidth != null) {
      return BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(
          color: borderColor!,
          width: borderWidth!,
        ),
      );
    }
    return null;
  }
}
