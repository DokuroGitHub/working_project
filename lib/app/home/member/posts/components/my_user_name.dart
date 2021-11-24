import 'package:flutter/material.dart';

import '/models/my_user.dart';
import '/services/database_service.dart';

class MyUserName extends StatelessWidget {
  const MyUserName({Key? key, required this.myUserId, this.onTap})
      : super(key: key);
  final String myUserId;
  final VoidCallback? onTap;

  Widget _name({String? name}){
    return Text(
      name??'',
      style: const TextStyle(
        color: Colors.white,
        fontSize: 18.0,
        fontWeight: FontWeight.w600,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      child: StreamBuilder(
          stream: DatabaseService().getStreamMyUserByDocumentId(myUserId),
          builder: (BuildContext context,
              AsyncSnapshot<MyUser?> snapshot) {
            if (snapshot.hasError) {
              return _name();
            }
            if(snapshot.hasData) {
              return _name(name: snapshot.data?.name);
            }else {
              return _name();
            }
          }),
      onTap: onTap,
    );
  }
}
