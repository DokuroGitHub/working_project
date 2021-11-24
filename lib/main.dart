import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:get/get_navigation/src/root/get_material_app.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:working_project/some_unused_page.dart';
import 'app/welcome/welcome_page.dart';
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