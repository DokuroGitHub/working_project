import 'dart:math';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '/app/sign_in/sign_in_view_model.dart';
import '/constants/keys.dart';
import '/constants/strings.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import '/routing/app_router.dart';
import '/services/shared_preferences_service.dart';

class SignInPage extends StatelessWidget {
  final signInModel = SignInViewModel();

  SignInPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SignInPageContents(
      viewModel: signInModel,
      title: AppLocalizations.of(context)!.signIn,
    );
  }
}

class SignInPageContents extends StatelessWidget {
  const SignInPageContents(
      {Key? key, required this.viewModel, this.title = 'Sign in page'})
      : super(key: key);
  final SignInViewModel viewModel;
  final String title;

  static const Key emailPasswordButtonKey = Key(Keys.emailPassword);
  static const Key googleSignInButtonKey = Key(Keys.googleSignIn);
  static const Key anonymousButtonKey = Key(Keys.anonymous);

  Future<void> _showEmailPasswordSignInPage(BuildContext context) async {
    final navigator = Navigator.of(context);
    await navigator.pushNamed(
      AppRoutes.emailPasswordSignInPage,
      arguments: () => navigator.pop(),
    );
  }

  Future<void> _showWelcomeScreenNextTime() async {
    final sharedPreferences = await SharedPreferences.getInstance();
    final sharedPreferencesService = SharedPreferencesService(sharedPreferences);
    await sharedPreferencesService.setIsNotWelcomeComplete();
    show();
  }

  //TODO: show issWelcomeComplete
  Future show()async{
    //TODO: cach 1
    final x = await SharedPreferences.getInstance();
    final y = SharedPreferencesService(x);
    print('cach 1: ${y.getIsWelcomeComplete().toString()}');
  }

  @override
  Widget build(BuildContext context) {
    print('SignInPage');
    return Scaffold(
      appBar: AppBar(
        elevation: 2.0,
        title: Text(title),
      ),
      backgroundColor: Colors.grey[200],
      body: _buildSignIn(context),
    );
  }

  Widget _buildHeader() {
    if (viewModel.isLoading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }
    return const Text(
      Strings.signIn,
      textAlign: TextAlign.center,
      style: TextStyle(color: Colors.black, fontSize: 32.0, fontWeight: FontWeight.w600),
    );
  }

  Widget _buildSignIn(BuildContext context) {
    return Center(
      child: LayoutBuilder(builder: (context, constraints) {
        return Container(
          width: min(constraints.maxWidth, 600),
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              const SizedBox(height: 32.0),
              SizedBox(
                height: 50.0,
                child: _buildHeader(),
              ),
              const SizedBox(height: 32.0),
              ElevatedButton(onPressed: viewModel.isLoading
                  ? null
                  : () => _showEmailPasswordSignInPage(context),
                  child: const Text(Strings.signInWithEmailPassword)),
              const SizedBox(height: 8),
              ElevatedButton(onPressed: viewModel.isLoading
                  ? null
                  : () => viewModel.signInWithGoogle(),
                  child: Text('Google '+AppLocalizations.of(context)!.signIn)),
              const SizedBox(height: 8),
              const Text(
                Strings.or,
                style: TextStyle(fontSize: 14.0, color: Colors.black87),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              ElevatedButton(onPressed: viewModel.isLoading ? null : viewModel.signInAnonymously,
                  child: Text(AppLocalizations.of(context)!.goAnonymous)),
              const SizedBox(height: 8),
              GestureDetector(
                onTap: (){
                  _showWelcomeScreenNextTime();
                  const snackBar = SnackBar(content: Text('Welcome screen will be showing next time!'));
                  ScaffoldMessenger.of(context).showSnackBar(snackBar);
                },
                child: const Text(
                  'show welcome screen next time',
                  style: TextStyle(fontSize: 14.0, color: Colors.black87),
                  textAlign: TextAlign.right,
                ),
              ),

            ],
          ),
        );
      }),
    );
  }
}
