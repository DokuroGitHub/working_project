import 'dart:async';

import 'package:flutter/foundation.dart';
import '/services/auth_service.dart';

class SignInViewModel with ChangeNotifier {
  bool isLoading = false;
  dynamic error;

  Future<void> _signIn(Function() signInMethod) async {
    try {
      isLoading = true;
      notifyListeners();
      await signInMethod();
      error = null;
    } catch (e) {
      error = e;
      rethrow;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> signInAnonymously() async {
    await _signIn(AuthService().signInAnonymously);
  }

  Future<void> signInWithGoogle() async {
    await _signIn(AuthService().signInWithGoogle);
  }

}
