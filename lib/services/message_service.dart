import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:mailer/mailer.dart';
import 'package:mailer/smtp_server.dart';

//TODO: vapidToken: dqeNW_3aQFCy1nY6BZWavW:APA91bEBr3GVOsZ1HO9ifEiyEHAvDoY7R1G9mtM0hw8vV_XNFfJRToU0EVQxhcGZCmEoxiQtnRUTlLI_OHhxGv5tXj3rBD92rS5jy37BqOrANoML9PAvHZ10GOkvAWmGTwdvQIlDW_EW

class MessageService {

  Future<void> askPermission() async {
    FirebaseMessaging messaging = FirebaseMessaging.instance;

    // use the returned token to send messages to users from your custom server
    String? token = await messaging.getToken(
        vapidKey:
            "BJ3MwOMU8cpE9TJUCrzKg0wTdV0InJxXK9RYbh85TW0Cw7l1Rrxiwfioi82g5VGU99SKWWf9pf_CR9RXnRum6xw");

    NotificationSettings settings = await messaging.requestPermission(
      alert: true,
      announcement: false,
      badge: true,
      carPlay: false,
      criticalAlert: false,
      provisional: false,
      sound: true,
    );

    print('User granted permission: ${settings.authorizationStatus}');

    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      print('Got a message whilst in the foreground!');
      print('Message data: ${message.data}');

      if (message.notification != null) {
        print('Message also contained a notification: ${message.notification}');
      }
    });
  }

  Future sendMail({String? winnerEmail, required List<String> loserEmails}) async {
    String email = 'tamthoidetrong@gmail.com';
    String token = 'ya29.a0ARrdaM9OqFi3y_y84cDYiREOs-DKZeZ81YC8-k05IuwtJJMFFYwdCZw2XNznFFfgsvy9rriPG3FI1sZyn4JsGtwxDiKJaVBYOI7H-LdFk7TldmWVsHVoegfnCWAVrAQXlafJL1DWwIYZdKSIVc-TZzsWMiyAr2E';
    final _googleSignIn = await GoogleSignIn(scopes: ['https://mail.google.com']).signIn();
    if(_googleSignIn==null){
      print('_googleSignIn null');
      return;
    }
    print('ok2');
    final GoogleSignInAuthentication googleSignInAuthentication =
    await _googleSignIn.authentication;
    if(googleSignInAuthentication.accessToken!=null) {
      token = googleSignInAuthentication.accessToken!;
    }

    List<String> recipients = [];
    if(winnerEmail!=null){
      recipients.add(winnerEmail);
    }
    List<String> recipients2 = loserEmails;

    final smtpServer = gmailSaslXoauth2(email, token);

    final message = Message()
      ..from = Address(email, 'Dokuro desu')
      ..recipients = recipients
      ..subject = 'Thông báo kết quả đăng kí ship :: 😀 :: ${DateTime.now()}'
      ..text = 'Bạn đã được chọn làm shipper cho chuyến hàng này.\n.Chúc mừng 😀';

    final message2 = Message()
      ..from = Address(email, 'Dokuro desu')
      ..recipients = recipients2
      ..subject = 'Thông báo kết quả đăng kí ship :: :: ${DateTime.now()}'
      ..text = 'Bạn đã không được chọn làm shipper cho chuyến hàng này.\nLần sau may mắn hơn nhé.';

    try {
      var connection = PersistentConnection(smtpServer);
    final sendReport = await connection.send(message);
    final sendReport2 = await connection.send(message2);
      await connection.close();

      print('Message sent: ' + sendReport.toString());
      print('Message2 sent: ' + sendReport2.toString());
    } on MailerException catch (e) {
      print('Message not sent.');
      print(e);
      for (var p in e.problems) {
        print('Problem: ${p.code}: ${p.msg}');
      }
    }
    // DONE
  }
}
