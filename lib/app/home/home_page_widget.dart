import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:overlay_support/overlay_support.dart';
import 'package:working_project/services/shared_preferences_service.dart';
import 'package:working_project/utils/notification_util.dart';
import '/app/home/home_page_for_admin.dart';
import '/app/home/home_page_for_shipper.dart';
import '/common_widgets/empty_content.dart';
import '/models/my_user.dart';
import '/services/auth_service.dart';
import '/services/database_service.dart';

import 'finish_my_user_info/finish_my_user_info_page.dart';
import 'home_page_for_member.dart';

class HomePageWidget extends StatefulWidget {

  @override
  State<HomePageWidget> createState() => _HomePageWidgetState();
}

class _HomePageWidgetState extends State<HomePageWidget> {
  String _firebaseAppToken = '';
  late int _totalNotifications = 0;
  PushNotification? _notificationInfo;

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

    // Uncomment those lines after activate google services inside example/android/build.gradle
    initializeFirebaseService();

    checkForInitialMessage();

    AwesomeNotifications().createdStream.listen((receivedNotification) {
      String? createdSourceText =
      AssertUtils.toSimpleEnumString(receivedNotification.createdSource);
      Fluttertoast.showToast(msg: '$createdSourceText notification created');
    });

    AwesomeNotifications().displayedStream.listen((receivedNotification) {
      String? createdSourceText =
      AssertUtils.toSimpleEnumString(receivedNotification.createdSource);
      Fluttertoast.showToast(msg: '$createdSourceText notification displayed');
    });

    AwesomeNotifications().dismissedStream.listen((receivedAction) {
      String? dismissedSourceText = AssertUtils.toSimpleEnumString(
          receivedAction.dismissedLifeCycle);
      Fluttertoast.showToast(
          msg: 'Notification dismissed on $dismissedSourceText');
    });

    AwesomeNotifications().actionStream.listen((receivedAction) {

      if (!StringUtils.isNullOrEmpty(receivedAction.buttonKeyInput)) {
        processInputTextReceived(receivedAction);
      } else {
        processDefaultActionReceived(receivedAction);
      }
    });
  }

  void processDefaultActionReceived(ReceivedAction receivedAction) {
    Fluttertoast.showToast(msg: 'Action received, receivedAction: ${receivedAction.actionDate}');
    //TODO: redirects
  }

  void processInputTextReceived(ReceivedAction receivedAction) {
    if(receivedAction.channelKey == 'chats') {
      //TODO: reply on notification
      NotificationUtils.simulateSendResponseChatConversation(
          msg: receivedAction.buttonKeyInput,
          groupKey: 'jhonny_group'
      );
    }

    sleep(const Duration(seconds: 2)); // To give time to show
    Fluttertoast.showToast(
        msg: 'Msg: ' + receivedAction.buttonKeyInput,
        textColor: Colors.white);
  }

  @override
  void dispose() {
    AwesomeNotifications().createdSink.close();
    AwesomeNotifications().displayedSink.close();
    AwesomeNotifications().actionSink.close();
    super.dispose();
  }

  Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
    // If you're going to use other Firebase services in the background, such as Firestore,
    // make sure you call `initializeApp` before using other Firebase services.
    await Firebase.initializeApp();
    print('Handling a background message: ${message.messageId}');

    if(
    !StringUtils.isNullOrEmpty(message.notification?.title, considerWhiteSpaceAsEmpty: true) ||
        !StringUtils.isNullOrEmpty(message.notification?.body, considerWhiteSpaceAsEmpty: true)
    ){
      print('message also contained a notification: ${message.notification}');

      String? imageUrl;
      imageUrl ??= message.notification!.android?.imageUrl;
      imageUrl ??= message.notification!.apple?.imageUrl;

      Map<String, dynamic> notificationAdapter = {
        NOTIFICATION_CHANNEL_KEY: 'basic_channel',
        NOTIFICATION_ID:
        message.data[NOTIFICATION_CONTENT]?[NOTIFICATION_ID] ??
            message.messageId ??
            Random().nextInt(2147483647),
        NOTIFICATION_TITLE:
        message.data[NOTIFICATION_CONTENT]?[NOTIFICATION_TITLE] ??
            message.notification?.title,
        NOTIFICATION_BODY:
        message.data[NOTIFICATION_CONTENT]?[NOTIFICATION_BODY] ??
            message.notification?.body ,
        NOTIFICATION_LAYOUT:
        StringUtils.isNullOrEmpty(imageUrl) ? 'Default' : 'BigPicture',
        NOTIFICATION_BIG_PICTURE: imageUrl
      };

      AwesomeNotifications().createNotificationFromJsonData(notificationAdapter);
    }
    else {
      AwesomeNotifications().createNotificationFromJsonData(message.data);
    }
  }

  Future<void> _firebaseMessagingForegroundHandler(RemoteMessage message) async {
    print('Got a message whilst in the foreground!');
    print('Message data: ${message.data}');

    if (
    // This step (if condition) is only necessary if you pretend to use the
    // test page inside console.firebase.google.com
    !StringUtils.isNullOrEmpty(message.notification?.title,
        considerWhiteSpaceAsEmpty: true) ||
        !StringUtils.isNullOrEmpty(message.notification?.body,
            considerWhiteSpaceAsEmpty: true)) {
      print('Message also contained a notification: ${message.notification}');

      String? imageUrl;
      imageUrl ??= message.notification!.android?.imageUrl;
      imageUrl ??= message.notification!.apple?.imageUrl;

      // https://pub.dev/packages/awesome_notifications#notification-types-values-and-defaults
      Map<String, dynamic> notificationAdapter = {
        NOTIFICATION_CONTENT: {
          NOTIFICATION_ID: Random().nextInt(2147483647),
          NOTIFICATION_CHANNEL_KEY: 'basic_channel',
          NOTIFICATION_TITLE: message.notification!.title,
          NOTIFICATION_BODY: message.notification!.body,
          NOTIFICATION_LAYOUT:
          StringUtils.isNullOrEmpty(imageUrl) ? 'Default' : 'BigPicture',
          NOTIFICATION_BIG_PICTURE: imageUrl
        }
      };

      print('_firebaseMessagingForegroundHandler notificationAdapter here');
      AwesomeNotifications()
          .createNotificationFromJsonData(notificationAdapter);
    } else {
      print('_firebaseMessagingForegroundHandler message.data');
      bool x = await AwesomeNotifications().createNotificationFromJsonData(message.data);
      print('x: $x');
    }
  }

  Future<void> _firebaseMessagingForegroundHandler2(RemoteMessage message) async {

    print(
        'Message title: ${message.notification?.title}, body: ${message.notification?.body}, data: ${message.data}');

    if (
    // This step (if condition) is only necessary if you pretend to use the
    // test page inside console.firebase.google.com
    !StringUtils.isNullOrEmpty(message.notification?.title,
        considerWhiteSpaceAsEmpty: true) ||
        !StringUtils.isNullOrEmpty(message.notification?.body,
            considerWhiteSpaceAsEmpty: true)) {
      print('Message also contained a notification: ${message.notification}');

      String? imageUrl;
      imageUrl ??= message.notification!.android?.imageUrl;
      imageUrl ??= message.notification!.apple?.imageUrl;

      // https://pub.dev/packages/awesome_notifications#notification-types-values-and-defaults
      Map<String, dynamic> notificationAdapter = {
        NOTIFICATION_CONTENT: {
          NOTIFICATION_ID: Random().nextInt(2147483647),
          NOTIFICATION_CHANNEL_KEY: 'basic_channel',
          NOTIFICATION_TITLE: message.notification!.title,
          NOTIFICATION_BODY: message.notification!.body,
          NOTIFICATION_LAYOUT:
          StringUtils.isNullOrEmpty(imageUrl) ? 'Default' : 'BigPicture',
          NOTIFICATION_BIG_PICTURE: imageUrl
        }
      };

      print('_firebaseMessagingForegroundHandler notificationAdapter here');
      AwesomeNotifications()
          .createNotificationFromJsonData(notificationAdapter);
    } else {
      // Parse the message received
      String? title = message.notification?.title;
      String? body = message.notification?.body;
      String? dataTitle = message.data['title'] as String?;
      String? dataBody = message.data['body'] as String?;
      print('title: $title');
      print('body: $body');
      print('dataTitle: $dataTitle');
      print('dataBody: $dataBody');
      print('message: ${message.data}');

      PushNotification notification = PushNotification(
        title: title ?? '',
        body: body ?? '',
        dataTitle: dataTitle?? '',
        dataBody: dataBody ?? '',
      );

      setState(() {
        _notificationInfo = notification;
        _totalNotifications++;
      });

      if (_notificationInfo != null) {
        // For displaying the notification as an overlay
        showSimpleNotification(
          Text(_notificationInfo!.dataTitle??'dataTitle null r'),
          leading: NotificationBadge(totalNotifications: _totalNotifications),
          subtitle: Text(_notificationInfo!.dataBody??'body null r'),
          background: Colors.cyan.shade700,
          duration: const Duration(seconds: 3),
        );
      }
    }
  }

  // Platform messages are asynchronous, so we initialize in an async method.
  Future<void> initializeFirebaseService() async {
    FirebaseMessaging messaging = FirebaseMessaging.instance;

    String firebaseAppToken = await messaging.getToken(
      // https://stackoverflow.com/questions/54996206/firebase-cloud-messaging-where-to-find-public-vapid-key
      vapidKey: 'BJ3MwOMU8cpE9TJUCrzKg0wTdV0InJxXK9RYbh85TW0Cw7l1Rrxiwfioi82g5VGU99SKWWf9pf_CR9RXnRum6xw',
    ) ??
        '';

    if (StringUtils.isNullOrEmpty(firebaseAppToken,
        considerWhiteSpaceAsEmpty: true)) return;

    if (!mounted) {
      _firebaseAppToken = firebaseAppToken;
    } else {
      setState(() {
        _firebaseAppToken = firebaseAppToken;
      });
    }

    print('Firebase token: $firebaseAppToken');

    FirebaseMessaging.onMessage.listen(_firebaseMessagingForegroundHandler);

    //TODO:

    await Firebase.initializeApp();
    FirebaseMessaging _messaging = FirebaseMessaging.instance;

    //FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

    NotificationSettings settings = await _messaging.requestPermission(
      alert: true,
      badge: true,
      provisional: false,
      sound: true,
    );

    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      print('User granted permission');

      //FirebaseMessaging.onMessage.listen(_firebaseMessagingForegroundHandler2);
    } else {
      print('User declined or has not accepted permission');
    }
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
              SharedPreferencesService.setFirebaseAppToken(_firebaseAppToken);
              if(_firebaseAppToken.isNotEmpty && _firebaseAppToken!=myUser.firebaseAppToken) {
                myUser.firebaseAppToken = _firebaseAppToken;
                DatabaseService().updateMyUserOnDB(myUser.id!, myUser.toMap());
              }
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