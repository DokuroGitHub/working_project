import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '/services/shared_preferences_service.dart';

class CheckWelcomeWidget extends StatefulWidget {
  const CheckWelcomeWidget({
    Key? key,
    required this.welcomedBuilder,
    required this.nonWelcomedBuilder,
  }) : super(key: key);

  final WidgetBuilder welcomedBuilder;
  final WidgetBuilder nonWelcomedBuilder;

  @override
  State<CheckWelcomeWidget> createState() => _CheckWelcomeWidgetState();
}

class _CheckWelcomeWidgetState extends State<CheckWelcomeWidget> {

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
        stream: SharedPreferences.getInstance().asStream(),
        builder: (__,
            AsyncSnapshot<SharedPreferences?> sharedPreferences) {
          if (sharedPreferences.data != null) {
            if (SharedPreferencesService(sharedPreferences.data!)
                .getIsWelcomeComplete()) {
              return widget.welcomedBuilder(context);
            }
          }
          return widget.nonWelcomedBuilder(context);
        });
  }
}
