//Now i'm going to make a custom button for the different action like the comment button, share ...
import 'package:flutter/material.dart';

//the button wil take 3 parameter : the icon , the action title and the color of the icon
Widget actionButton(IconData icon, String actionTitle, Color iconColor,{VoidCallback? onTap}) {
  return Expanded(
    child: FlatButton.icon(
      onPressed: onTap,
      icon: Icon(
        icon,
        color: iconColor,
      ),
      label: Text(
        actionTitle,
        style: const TextStyle(
          color: Colors.white,
        ),
      ),
    ),
  );
}