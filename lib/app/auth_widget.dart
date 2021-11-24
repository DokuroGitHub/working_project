import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '/common_widgets/empty_content.dart';

class AuthWidget extends StatelessWidget {
  const AuthWidget({
    Key? key,
    required this.signedInBuilder,
    required this.nonSignedInBuilder,
  }) : super(key: key);
  final WidgetBuilder nonSignedInBuilder;
  final WidgetBuilder signedInBuilder;

  @override
  Widget build(BuildContext context) {
    print('auth widget');
    return StreamBuilder(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, AsyncSnapshot<User?> user) {
          if (user.hasError) {
            return const Scaffold(
              body: EmptyContent(
                title: 'Something went wrong',
                message: 'Can\'t load data right now.',
              ),
            );
          } else {
            if (user.data != null) {
              print(user.data);
              return signedInBuilder(context);
            }
            return nonSignedInBuilder(context);
          }
        }
    );
  }
}
