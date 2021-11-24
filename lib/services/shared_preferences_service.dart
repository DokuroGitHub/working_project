import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

final sharedPreferencesServiceProvider =
Provider<SharedPreferencesService>((ref) => throw UnimplementedError());

class SharedPreferencesService {
  SharedPreferencesService(this.sharedPreferences);
  final SharedPreferences sharedPreferences;

  //TODO: for welcome screen 1 time
  static const String isWelcomeCompleteKey = 'isWelcomeCompleteKey';
  //TODO: for auto fill login
  static const String userEmailKey = "userEmailKey";
  static const String userPasswordKey = "userPasswordKey";

  //TODO: save data
  Future<bool> setIsWelcomeComplete() => sharedPreferences.setBool(isWelcomeCompleteKey, true);

  Future<bool> setIsNotWelcomeComplete() => sharedPreferences.setBool(isWelcomeCompleteKey, false);

  Future<bool> setUserEmail(String getUserEmail) =>
      sharedPreferences.setString(userEmailKey, getUserEmail);

  Future<bool> setUserPassword(String getUserPassword) =>
      sharedPreferences.setString(userPasswordKey, getUserPassword);

  //TODO: get data
  bool getIsWelcomeComplete() => sharedPreferences.getBool(isWelcomeCompleteKey) ?? false;

  String? getUserEmail()=> sharedPreferences.getString(userEmailKey);

  String? getUserPassword() => sharedPreferences.getString(userPasswordKey);

}
