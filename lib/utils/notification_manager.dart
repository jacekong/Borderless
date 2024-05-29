import 'package:shared_preferences/shared_preferences.dart';

class NotificationManager {
  static SharedPreferences? _prefs;

  static Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  static Future<void> saveUserId(String userId) async {
    _prefs?.setString('userId', userId);
  }

  static String? getUserId() {
    return _prefs?.getString('userId');
  }

  static Future<void> removeUserId() async {
    _prefs?.remove('userId');
  }
}
