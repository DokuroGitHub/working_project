import 'package:flutter/material.dart';
import 'package:working_project/models/my_user.dart';
import 'package:working_project/services/database_service.dart';

import 'components/body.dart';

class AccountPage extends StatefulWidget {
  const AccountPage({required this.myUser, required this.myUserId2});

  final MyUser myUser;
  final String myUserId2;

  @override
  State<AccountPage> createState() => _AccountPageState();
}

class _AccountPageState extends State<AccountPage> {

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<MyUser?>(
        stream: DatabaseService().getStreamMyUserByDocumentId(widget.myUserId2),
        builder: (context, user) => user.data != null
            ? Body(myUser: widget.myUser, myUser2: user.data!)
            : Container());
  }
}
