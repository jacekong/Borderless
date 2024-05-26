import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:borderless/api/api_endpoint.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthManager {
  static SharedPreferences? _prefs;

  static Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
    _startTokenRefreshTimer();
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

  static bool isTokenExpired(String token) {
    return JwtDecoder.isExpired(token);
  }

  static Future<void> refreshTokenIfNeeded() async {
    String apiUrl = '${ApiEndpoint.endpoint}/api/token/';
    String? accessToken = getAuthToken();
    if (accessToken != null && isTokenExpired(accessToken)) {
      String? refreshToken = getRefreshToken();
      if (refreshToken != null) {
        final response = await http.post(
        Uri.parse(apiUrl),
        body: json.encode({'refresh':refreshToken}),
        headers: {'Content-Type': 'application/json'},
      );
      if (response.statusCode == 200) {
        final body = json.decode(response.body);
        final accessToken = body['access'];
        String newAccessToken = accessToken;
        print('Access token refreshed: $newAccessToken');
        await _prefs!.setString('authToken', newAccessToken);
      }
      } else {
        print('something went wrong');
      }
    }
  }

  static void _startTokenRefreshTimer() {
    print('Starting refresh timer');
    const refreshInterval = Duration(minutes: 1); // Interval for token refresh (e.g., every 5 minutes)
    Timer.periodic(refreshInterval, (timer) async {
      await refreshTokenIfNeeded();
    });
  }


}