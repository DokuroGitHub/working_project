import 'package:flutter/material.dart';
import '/models/my_user.dart';
import '/services/database_service.dart';

class MyUserAvatar extends StatelessWidget {
  const MyUserAvatar({Key? key, required this.myUserId, required this.myUser, this.onTap})
      : super(key: key);
  final String? myUserId;
  final MyUser? myUser;
  final VoidCallback? onTap;

  final String defaultPhotoURL =
      'https://yt3.ggpht.com/yti/APfAmoEUl_jqsKc0uhb1z2aakEsBQ7ISQllbZgOgA7lc=s88-c-k-c0x00ffffff-no-rj-mo';

  Widget _circleAvatar({String? photoURL}) {
    return CircleAvatar(
      backgroundImage: NetworkImage(photoURL ?? defaultPhotoURL),
      radius: 25.0,
    );
  }

  @override
  Widget build(BuildContext context) {
    if(myUser!=null){
      //TODO: da co myUser
      return GestureDetector(
        child: Stack(children: [
          _circleAvatar(photoURL: myUser!.photoURL??defaultPhotoURL),
          if (myUser!.isActive)
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
        ]),
        onTap: onTap,
      );
    }else {
      //TODO: tim myUser tu myUserId
      return GestureDetector(
        child: StreamBuilder(
            stream: DatabaseService().getStreamMyUserByDocumentId(myUserId!),
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
                              color: Theme
                                  .of(context)
                                  .canvasColor,
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
}
