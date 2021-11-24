import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:state_notifier/state_notifier.dart';
import '/services/shared_preferences_service.dart';

final welcomeViewModelProvider =
StateNotifierProvider<WelcomeViewModel, bool>((ref) {
  final sharedPreferencesService = ref.watch(sharedPreferencesServiceProvider);
  return WelcomeViewModel(sharedPreferencesService);
});

class WelcomeViewModel extends StateNotifier<bool> {
  WelcomeViewModel(this.sharedPreferencesService) : super(sharedPreferencesService.getIsWelcomeComplete());
  final SharedPreferencesService sharedPreferencesService;

  Future<void> completeWelcome() async {
    await sharedPreferencesService.setIsWelcomeComplete();
    state = true;
  }
}
