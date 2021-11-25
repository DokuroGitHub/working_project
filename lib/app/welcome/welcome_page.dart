import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '/constants/ui.dart';
import '/services/shared_preferences_service.dart';
import 'welcome_view_model.dart';

class WelcomePage extends ConsumerWidget {
  Future<void> onGetStarted(BuildContext context, WidgetRef ref) async {
    final welcomeViewModel = ref.read(welcomeViewModelProvider.notifier);
    await welcomeViewModel.completeWelcome();
    show(ref);
  }

  //TODO: show issWelcomeComplete
  Future show(WidgetRef ref) async {
    //TODO: cach 1
    final x = await SharedPreferences.getInstance();
    final y = SharedPreferencesService(x);
    print('cach 1: ${y.getIsWelcomeComplete().toString()}');

    //TODO: cach 2 , better one
    final sharedPreferencesService = ref.read(sharedPreferencesServiceProvider);
    print(
        'cach 2: ${sharedPreferencesService.getIsWelcomeComplete().toString()}');
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    print('WelcomePage');
    var scaffold1 = Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 20),
            ConstrainedBox(constraints: BoxConstraints(
                maxWidth: MediaQuery.of(context).size.width),
                child: Image.asset('assets/images/welcome_image.png'),
            ),
            const SizedBox(height: 30),
            Text(
              "Welcome to our \n AloShip app",
              textAlign: TextAlign.center,
              style: Theme.of(context)
                  .textTheme
                  .headline5
                  ?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            Text(
              "Freedom book an shipper of your \n requirements.",
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Theme.of(context)
                    .textTheme
                    .bodyText1
                    ?.color
                    ?.withOpacity(0.64),
              ),
            ),
            const SizedBox(height: 30),
            FittedBox(
              child: TextButton(
                  onPressed: () => onGetStarted(context, ref),
                  child: Row(
                    children: [
                      Text(
                        "Skip",
                        style: Theme.of(context).textTheme.bodyText1?.copyWith(
                          color: Theme.of(context)
                              .textTheme
                              .bodyText1
                              ?.color
                              ?.withOpacity(0.8),
                        ),
                      ),
                      const SizedBox(width: kDefaultPadding / 4),
                      Icon(
                        Icons.arrow_forward_ios,
                        size: 16,
                        color: Theme.of(context)
                            .textTheme
                            .bodyText1
                            ?.color
                            ?.withOpacity(0.8),
                      )
                    ],
                  )),
            )
          ],
        ),
      ),
    );
    var scaffold2 = Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Track your time.\nBecause time counts.',
              style: Theme.of(context).textTheme.headline4,
              textAlign: TextAlign.center,
            ),
            ElevatedButton(
              onPressed: () => onGetStarted(context, ref),
              child: Text(
                'Get Started',
                style: Theme.of(context)
                    .textTheme
                    .headline5
                    ?.copyWith(color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
    return scaffold1;
  }
}
