import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

const String defaultPhotoURL =
    'https://scontent.fdad1-2.fna.fbcdn.net/v/t1.30497-1/p100x100/143086968_2856368904622192_1959732218791162458_n.png?_nc_cat=1&ccb=1-5&_nc_sid=7206a8&_nc_ohc=xxuCSnWhe_UAX9Uml8x&tn=ydMBgSqsmF5ZJOjR&_nc_ht=scontent.fdad1-2.fna&oh=00f1644507795114064f220c2267cfb1&oe=61AD6051';

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
