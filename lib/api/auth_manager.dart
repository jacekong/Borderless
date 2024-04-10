import 'package:shared_preferences/shared_preferences.dart';

class AuthManager {
  static SharedPreferences? _prefs;

  static Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  static Future<void> login(String authToken, String refreshToken) async {
    await _prefs!.setString('authToken', authToken);
    await _prefs!.setString('refreshToken', refreshToken);
  }

  static Future<void> logout(context) async {
    await _prefs!.remove('authToken');
    await _prefs!.remove('refreshToken');
  }

  static Future<bool> isLoggedIn() async {
    return _prefs!.getString('authToken') != null;
  }

  static String? getAuthToken() {
    return _prefs!.getString('authToken');
  }

  static String? getRefreshToken() {
    return _prefs!.getString('refreshToken');
  }


}