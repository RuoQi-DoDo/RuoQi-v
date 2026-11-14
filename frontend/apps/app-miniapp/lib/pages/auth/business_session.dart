import 'package:shared_preferences/shared_preferences.dart';

const businessSignedInPreferenceKey = 'ruoqi_business_signed_in_v1';

abstract interface class BusinessSessionStore {
  Future<bool> readSignedIn();
  Future<void> writeSignedIn(bool signedIn);
}

class SharedPreferencesBusinessSessionStore implements BusinessSessionStore {
  const SharedPreferencesBusinessSessionStore();

  @override
  Future<bool> readSignedIn() async {
    final preferences = await SharedPreferences.getInstance();
    return preferences.getBool(businessSignedInPreferenceKey) ?? false;
  }

  @override
  Future<void> writeSignedIn(bool signedIn) async {
    final preferences = await SharedPreferences.getInstance();
    await preferences.setBool(businessSignedInPreferenceKey, signedIn);
  }
}
