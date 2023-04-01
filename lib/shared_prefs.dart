import 'package:shared_preferences/shared_preferences.dart';

class SharedPrefs {
  static late final SharedPreferences prefs;

  static init() async {
    prefs = await SharedPreferences.getInstance();
  }

  static getFirstOpen() {
    return prefs.getBool("isFirstOpen");
  }

  static setIsFirstOpen() {
    prefs.setBool("isFirstOpen", false);
  }
}
