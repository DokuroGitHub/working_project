import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:get/get_navigation/src/root/get_material_app.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:working_project/services/database_service.dart';
import 'package:working_project/some_unused_page.dart';
import 'app/home/member/shipments/edit_shipment/edit_shipment_page.dart';
import 'app/home/member/shipments/shipment_details/shipment_details_page.dart';
import 'app/home/member/shipments/shipments_page.dart';
import 'app/welcome/welcome_page.dart';
import 'locale_service.dart';
import 'models/my_user.dart';
import 'models/shipment.dart';
import 'routing/app_router.dart';
import 'services/shared_preferences_service.dart';
import 'theme_service.dart';
import 'themes.dart';

import 'app/auth_widget.dart';
import 'app/home/home_page_widget.dart';
import 'app/sign_in/sign_in_page.dart';
import 'app/welcome/welcome_view_model.dart';

//TODO: -d chrome --web-hostname localhost --web-port 6969
//TODO: keytool -list -v -keystore "%USERPROFILE%\.android\debug.keystore" -alias androiddebugkey -storepass android -keypass android
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
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
    return GetMaterialApp(
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
      home: const TestPage(),
      onGenerateRoute: (settings) => AppRouter.onGenerateRoute(settings),
    );
  }
}

class TestPage extends StatelessWidget {
  const TestPage({Key? key}) : super(key: key);

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
          return StreamBuilder(
              stream: DatabaseService().getStreamShipmentByDocumentId(shipmentId1),
              builder: (BuildContext context, AsyncSnapshot<Shipment?> snapshot) {
                if(snapshot.hasError){
                  print('test page, snapshot has error: ${snapshot.error}');
                  return Container();
                }
                if(snapshot.data!=null){
                  return Scaffold(
                    appBar: AppBar(
                      title: const Text('Test Page'),
                      actions: [
                        IconButton(
                          icon: const Icon(Icons.lightbulb),
                          onPressed: ThemeService().switchTheme,
                        ),
                        PopupMenuButton<String>(
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
                    body: ShipmentsPage(myUser: myUser),
                  );
                }
                return Container();
              });
        }
        return Container();
      });
  }
}
