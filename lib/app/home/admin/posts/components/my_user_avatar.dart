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
      'https://media.discordapp.net/attachments/781870218192355329/795999369165930546/135564527_2670553363257472_1695878780981957578_o.png';

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
