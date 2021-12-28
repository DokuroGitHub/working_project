import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' show Response;

import 'common/http_datasource.dart';

const String firebaseServerKey = 'AAAArOQfBYw:APA91bFXUmrdZxltT-FnD9tNileC1062xenKI2kycBUa-0EDoPykKadfAPSn9krKKQLcuGnzVn0VGxqeXPypH9zQ2anJvzW02gbNvBup9zQe0ok9PqepTl95VTMBZZkZ_uChU5hRSqSS';

class CloudMessagingService extends HttpDataSource {
  /// ************************************************************************************
  ///
  /// SINGLETON CONSTRUCTOR PATTERN
  ///
  /// ************************************************************************************

  static CloudMessagingService? _instance;
  factory CloudMessagingService() {
    _instance ??= CloudMessagingService._internalConstructor();
    return _instance!;
  }

  CloudMessagingService._internalConstructor()
      : super(
        baseAPI:'fcm.googleapis.com',
        isUsingHttps: true,
        isCertificateHttps: false
      );
  
//   /// ************************************************************************************
//   ///
//   /// FETCH DATA METHODS
//   ///
//   /// ************************************************************************************

  Future<String> _notificationModel(
      {required String firebaseServerKey, Map<String, dynamic> body = const {}}) async {
    if (firebaseServerKey.isEmpty) {
      return 'Server Key not defined';
    }

    Response? response = await fetchData(
        directory: '/fcm/send',
        headers: {
          'Authorization': 'key=$firebaseServerKey',
          'Content-Type': 'application/json'
        },
        body: jsonEncode(body));

    if (response?.statusCode == 200) {
      return response!.bodyBytes.toString();
    }

    return '';
  }

  Future<String> pushBasicNotification({
    required String firebaseAppToken,
    required int notificationId,
    required String title,
    required String body,
    Map<String, String> payload = const {}
  }) async {
    return await _notificationModel(
        firebaseServerKey: firebaseServerKey,
        body: getFirebaseExampleContent(firebaseAppToken: firebaseAppToken));
  }

  Map<String, dynamic> getFirebaseExampleContent({required String firebaseAppToken}) {
    return {
      'to': firebaseAppToken,
      'mutable_content' : true,
      'content_available': true,
      'priority': 'high',
      'data': {
        'content': {
          'id': 100,
          'channelKey': 'big_picture',
          'title': "Huston!\nThe eagle has landed!",
          'body':
          "A small step for a man, but a giant leap to Flutter's community!",
          'notificationLayout': 'BigPicture',
          'largeIcon':
          "https://media.discordapp.net/attachments/781870218192355329/798891179881529374/ErmFwCPXAAIHofL.png",
          'bigPicture': "https://www.dw.com/image/49519617_303.jpg",
          'showWhen': true,
          'autoDismissible': true,
          'privacy': 'Private'
        }
      }
    };
  }

  //TODO: ------------------------- working ----------------------------

  Future<void> sendNotifications({String? winner, required List<String> losers})async {
    if(winner!=null) {
      String result = await pushNotification(
          firebaseAppToken: winner,
          title: 'Kết quả',
          body: 'Chúc mừng bạn đã được chọn',
      );
      print('result: $result');
    }
    for(int i = 0 ; i<losers.length;i++){
      String result = await pushNotification(
          firebaseAppToken: losers[i],
          title: 'Kết quả',
          body: 'Rất tiếc, bạn đã không được chọn',
      );
      print('result: $result');
    }
  }

  Future<String> pushNotification({
    required String firebaseAppToken,
    required String title,
    required String body,
  }) async {
    return await _notificationModel(
        firebaseServerKey: firebaseServerKey,
        body: getNotificationContent(
            firebaseAppToken: firebaseAppToken,
            title: title,
            body: body,
        ));
  }

  Map<String, dynamic> getNotificationContent({
    required String firebaseAppToken,
    required String title,
    required String body,
  }) {
    return {
      'to': firebaseAppToken,
      'mutable_content' : true,
      'content_available': true,
      'priority': 'high',
      'data': {
        'content': {
          'id': 100,
          'channelKey': 'big_picture',
          'title': title,
          'body': body,
          'notificationLayout': 'BigPicture',
          'largeIcon':
          "https://accounts-cdn.9gag.com/media/avatar/25095292_100_3.jpg",
          'bigPicture': "https://www.dw.com/image/49519617_303.jpg",
          'showWhen': true,
          'autoDismissible': true,
          'privacy': 'Private'
        }
      }
    };
  }


}
