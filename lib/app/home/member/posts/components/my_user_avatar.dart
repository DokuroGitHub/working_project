import 'package:flutter/material.dart';
import '/models/my_user.dart';
import '/services/database_service.dart';

class MyUserAvatar extends StatelessWidget {
  const MyUserAvatar({Key? key, required this.myUserId, this.onTap})
      : super(key: key);
  final String myUserId;
  final VoidCallback? onTap;

  final String defaultPhotoURL =
      'https://scontent.fdad1-2.fna.fbcdn.net/v/t1.30497-1/p100x100/143086968_2856368904622192_1959732218791162458_n.png?_nc_cat=1&ccb=1-5&_nc_sid=7206a8&_nc_ohc=xxuCSnWhe_UAX9Uml8x&tn=ydMBgSqsmF5ZJOjR&_nc_ht=scontent.fdad1-2.fna&oh=00f1644507795114064f220c2267cfb1&oe=61AD6051';

  Widget _circleAvatar({String? photoURL}) {
    return CircleAvatar(
      backgroundImage: NetworkImage(photoURL ?? defaultPhotoURL),
      radius: 25.0,
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      child: StreamBuilder(
          stream: DatabaseService().getStreamMyUserByDocumentId(myUserId),
          builder: (BuildContext context, AsyncSnapshot<MyUser?> snapshot) {
            if (snapshot.hasError) {
              return _circleAvatar();
            }
            if (snapshot.hasData) {
              //TODO: avatar + dot isOnline
              return Stack(children: [
                _circleAvatar(photoURL: snapshot.data?.photoURL),
                if (snapshot.data!.isActive)
                  Positioned(
                    right: 0,
                    bottom: 0,
                    child: Container(
                      height: 16,
                      width: 16,
                      decoration: BoxDecoration(
                        color: Colors.greenAccent,
                        shape: BoxShape.circle,
                        border: Border.all(
                            color: Theme.of(context).canvasColor,
                            width: 2),
                      ),
                    ),
                  ),
              ]);
            } else {
              return _circleAvatar();
            }
          }),
      onTap: onTap,
    );
  }
}
