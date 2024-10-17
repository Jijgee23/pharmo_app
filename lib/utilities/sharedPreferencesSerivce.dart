import 'package:shared_preferences/shared_preferences.dart';

class SharedPreferencesSerivce {
  getInstance() async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    return pref;
  }

  Future writeCache({required String key, required String value}) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString(key, value);
  }

  Future readCache({required String key}) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString(key);
  }

  Future clearCache() async {
    // final SharedPreferences prefs = await SharedPreferences.getInstance();
    // prefs.clear();
    SharedPreferences prefs = getInstance();
    prefs.clear();
  }
}
