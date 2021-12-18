import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:overlay_support/overlay_support.dart';
import '/app/home/home_page_for_admin.dart';
import '/app/home/home_page_for_shipper.dart';
import '/common_widgets/empty_content.dart';
import '/models/my_user.dart';
import '/services/auth_service.dart';
import '/services/database_service.dart';

import 'finish_my_user_info/finish_my_user_info_page.dart';
import 'member/home_page_for_member.dart';

class HomePageWidget extends StatefulWidget {

  @override
  State<HomePageWidget> createState() => _HomePageWidgetState();
}

class _HomePageWidgetState extends State<HomePageWidget> {

  late final FirebaseMessaging _messaging;
  late int _totalNotifications = 0;
  PushNotification? _notificationInfo;

  void registerNotification() async {
    await Firebase.initializeApp();
    _messaging = FirebaseMessaging.instance;

    //FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

    NotificationSettings settings = await _messaging.requestPermission(
      alert: true,
      badge: true,
      provisional: false,
      sound: true,
    );

    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      print('User granted permission');

      FirebaseMessaging.onMessage.listen((RemoteMessage message) {
        print(
            'Message title: ${message.notification?.title}, body: ${message.notification?.body}, data: ${message.data}');

        // Parse the message received
        PushNotification notification = PushNotification(
          title: message.notification?.title,
          body: message.notification?.body,
          dataTitle: message.data['title'] as String?,
          dataBody: message.data['body'] as String?,
        );

        setState(() {
          _notificationInfo = notification;
          _totalNotifications++;
        });

        if (_notificationInfo != null) {
          // For displaying the notification as an overlay
          showSimpleNotification(
            Text(_notificationInfo!.title!),
            leading: NotificationBadge(totalNotifications: _totalNotifications),
            subtitle: Text(_notificationInfo!.body!),
            background: Colors.cyan.shade700,
            duration: const Duration(seconds: 3),
          );
        }
      });
    } else {
      print('User declined or has not accepted permission');
    }
  }

  // For handling notification when the app is in terminated state
  Future checkForInitialMessage() async {
    await Firebase.initializeApp();
    RemoteMessage? initialMessage =
    await FirebaseMessaging.instance.getInitialMessage();

    if (initialMessage != null) {
      PushNotification notification = PushNotification(
        title: initialMessage.notification?.title,
        body: initialMessage.notification?.body,
        dataTitle: initialMessage.data['title'] as String?,
        dataBody: initialMessage.data['body'] as String?,
      );

      setState(() {
        _notificationInfo = notification;
        _totalNotifications++;
      });
    }
  }

  @override
  void initState() {
    super.initState();

    checkForInitialMessage();
    registerNotification();
  }

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
          if(snapshot.connectionState != ConnectionState.waiting){
            if(snapshot.data != null){
              MyUser myUser = snapshot.data!;
              print('HomePageWidget, myUser: $myUser');
              switch(myUser.role){
                case 'ADMIN':
                  return HomePageForAdmin(myUser: myUser);
                case 'SHIPPER':
                  return HomePageForShipper(myUser: myUser);
                default:  //TODO: case 'MEMBER':
                  return HomePageForMember(myUser: myUser);
              }
            }
            print('HomePageWidget, myUser null, FinishMyUserInfoPage');
            //TODO: FinishMyUserInfoPage
            return FinishMyUserInfoPage(user: user);
          }
          print('state: ${snapshot.connectionState}');
          return const Scaffold(
            body: EmptyContent(
                title: 'Loading...',
                message: 'Please wait'),
          );
        }
    );
  }

}

/////////////////
class NotificationBadge extends StatelessWidget {
  final int totalNotifications;

  const NotificationBadge({required this.totalNotifications});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 40.0,
      height: 40.0,
      decoration: const BoxDecoration(
        color: Colors.red,
        shape: BoxShape.circle,
      ),
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Text(
            '$totalNotifications',
            style: const TextStyle(color: Colors.white, fontSize: 20),
          ),
        ),
      ),
    );
  }
}

class PushNotification {
  PushNotification({
    this.title,
    this.body,
    this.dataTitle,
    this.dataBody,
  });

  String? title;
  String? body;
  String? dataTitle;
  String? dataBody;
}