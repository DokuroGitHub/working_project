import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:get/get_navigation/src/root/get_material_app.dart';
import 'package:overlay_support/overlay_support.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:working_project/services/database_service.dart';
import 'package:working_project/services/message_service.dart';
import 'app/home/messages/messages_page.dart';
import 'app/welcome/welcome_page.dart';
import 'locale_service.dart';
import 'models/my_user.dart';
import 'routing/app_router.dart';
import 'services/shared_preferences_service.dart';
import 'theme_service.dart';
import 'themes.dart';

import 'app/auth_widget.dart';
import 'app/home/home_page_widget.dart';
import 'app/sign_in/sign_in_page.dart';
import 'app/welcome/welcome_view_model.dart';
import 'package:firebase_app_check/firebase_app_check.dart';

//TODO: Phát triển mạng xã hội shipper
//TODO: -d chrome --web-hostname localhost --web-port 6969
//TODO: keytool -list -v -keystore "%USERPROFILE%\.android\debug.keystore" -alias androiddebugkey -storepass android -keypass android
// Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
//   // If you're going to use other Firebase services in the background, such as Firestore,
//   // make sure you call `initializeApp` before using other Firebase services.
//   await Firebase.initializeApp();
//
//   print("Handling a background message: ${message.messageId}");
// }

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  await FirebaseAppCheck.instance.activate(
    webRecaptchaSiteKey: '6Ld49KsdAAAAADxE7yyU192iE4KH1doic2u7vIju',
  );

  //FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

  //TODO: init ProviderScope de xai cac providers
  runApp(ProviderScope(
    overrides: [
      sharedPreferencesServiceProvider.overrideWithValue(
        SharedPreferencesService(await SharedPreferences.getInstance()),
      ),
    ],
    child: MyApp(),
  ));
}

class MyApp extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return OverlaySupport(
      child: GetMaterialApp(
        title: 'Flutter Demo',
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        debugShowCheckedModeBanner: false,
        theme: Themes.light,
        darkTheme: Themes.dark,
        themeMode: ThemeService().theme,
        home: AuthWidget(
          nonSignedInBuilder: (_) => Consumer(
            builder: (context, ref, _) {
              //TODO: watch state cua WelcomeViewModel/chinh la getIsWelcomeComplete()
              final didCompleteWelcome = ref.watch(welcomeViewModelProvider);
              return didCompleteWelcome ? SignInPage() : WelcomePage();
            },
          ),
          signedInBuilder: (_) => HomePageWidget(),
        ),
        onGenerateRoute: (settings) => AppRouter.onGenerateRoute(settings),
      ),
    );
  }
}

//TODO: for test pages ///////////////////////////////////////////////
class MyAppForTestPages extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Flutter Demo',
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      debugShowCheckedModeBanner: false,
      theme: Themes.light,
      darkTheme: Themes.dark,
      themeMode: ThemeService().theme,
      home: TestPage(),
      onGenerateRoute: (settings) => AppRouter.onGenerateRoute(settings),
    );
  }
}

class TestPage extends StatefulWidget {
  const TestPage({Key? key}) : super(key: key);

  @override
  State<TestPage> createState() => _TestPageState();
}

class _TestPageState extends State<TestPage> {
  final String myUserId1 = 'peXkGVl6GvcllR7D9g5oPOm0zV62';

  final String shipmentId1 = 'W6QMVKwvFRviDIMqrosX';

  @override
  Widget build(BuildContext context) {
    print('test page');
    return StreamBuilder(
      stream: DatabaseService().getStreamMyUserByDocumentId(myUserId1),
      builder: (BuildContext context, AsyncSnapshot<MyUser?> snapshot) {
        if(snapshot.hasError){
          print('test page, snapshot has error: ${snapshot.error}');
          return Container();
        }
        if(snapshot.data!=null){
          var myUser = snapshot.data!;
          return Scaffold(
            appBar: AppBar(
              title: const Text('Test Page'),
              actions: [
                IconButton(
                  color: Theme.of(context).appBarTheme.titleTextStyle?.color,
                  icon: const Icon(Icons.wifi_tethering_sharp),
                  onPressed: (){
                    MessageService().askPermission();
                  },
                ),
                IconButton(
                  icon: const Icon(Icons.lightbulb),
                  color: Theme.of(context).appBarTheme.titleTextStyle?.color,
                  onPressed: ThemeService().switchTheme,
                ),
                PopupMenuButton<String>(
                  icon: Icon(Icons.more_vert,
                    color: Theme.of(context).appBarTheme.titleTextStyle?.color,
                  ),
                  onSelected: LocaleService().changeLocale,
                  itemBuilder: (BuildContext context) {
                    return [
                      PopupMenuItem<String>(
                        value: 'vi',
                        child: Text('Tiếng Việt',
                            style: TextStyle(
                                color: LocaleService().languageCode == 'vi'
                                    ? Colors.red
                                    : Colors.blue)),
                      ),
                      PopupMenuItem<String>(
                        value: 'en',
                        child: Text('English',
                            style: TextStyle(
                                color: LocaleService().languageCode == 'en'
                                    ? Colors.red
                                    : Colors.blue)),
                      ),
                      PopupMenuItem<String>(
                        value: 'es',
                        child: Text('Espanol',
                            style: TextStyle(
                                color: LocaleService().languageCode == 'es'
                                    ? Colors.red
                                    : Colors.blue)),
                      ),
                    ];
                  },
                ),
                const SizedBox(width: 10),
              ],
            ),

            body: MessagesPage(myUser: myUser, conversationId: '1HBfVQwh2U93b0WO0pgU',),
          );
        }
        return Center(child: Text('TestPage Loading...'));
      });
  }
}
