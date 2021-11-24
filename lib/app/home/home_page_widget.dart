import 'package:flutter/material.dart';
import '/app/home/home_page_for_admin.dart';
import '/app/home/home_page_for_shipper.dart';
import '/common_widgets/empty_content.dart';
import '/models/my_user.dart';
import '/services/auth_service.dart';
import '/services/database_service.dart';

import 'finish_my_user_info/finish_my_user_info_page.dart';
import 'member/home_page_for_member.dart';

class HomePageWidget extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    var user = AuthService().getCurrentUser();
    if(user==null){
      return const Scaffold(
        body: EmptyContent(
          title: 'Something went wrong',
          message: 'Can\'t get user.',
        ),
      );
    }
    final emptyPage = Scaffold(
      body: EmptyContent(
        title: 'Something went wrong',
        message: 'Can\'t get MyUser with uid:  ${user.uid}'),
    );
    return StreamBuilder(
        stream: DatabaseService().getStreamMyUserByDocumentId(user.uid),
        builder: (context, AsyncSnapshot<MyUser?> snapshot) {
          if (snapshot.hasError) {
            print('HomePageWidget, ${snapshot.error}');
            return emptyPage;
          }
          if(snapshot.hasData){
            MyUser? myUser = snapshot.data;
            if (myUser != null) {
              print('HomePageWidget, myUser: $myUser');
              switch(myUser.role){
                case 'ADMIN':
                  return HomePageForAdmin(myUser: myUser);
                case 'SHIPPER':
                  return HomePageForShipper(myUser: myUser);
                default:  //TODO: case 'MEMBER':
                  return HomePageForMember(myUser: myUser);
              }
            }else {
              print('HomePageWidget, myUser null, FinishMyUserInfoPage');
              //TODO: FinishMyUserInfoPage
              return FinishMyUserInfoPage(user: user);
            }
          }
          return const Scaffold(
            body: EmptyContent(
                title: 'Loading...',
                message: 'Please wait a moment'),
          );
        }
    );
  }
}
