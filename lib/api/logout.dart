import 'dart:convert';
import 'package:borderless/api/api_endpoint.dart';
import 'package:borderless/api/auth_manager.dart';
import 'package:borderless/provider/user_profile_provider.dart';
import 'package:borderless/screens/login.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';

import 'package:shared_preferences/shared_preferences.dart';

Future<void> logout(context) async {
  try {
    final String? refreshToken = AuthManager.getRefreshToken();
    final response = await http.post(
      Uri.parse('${ApiEndpoint.endpoint}/logout/'),
      headers: {
          'Content-Type': 'application/json',
        },
      body: json.encode({'refresh': refreshToken}),
    );

    if (response.statusCode == 200) {

      final prefs = await SharedPreferences.getInstance();

      await prefs.remove('authToken');
      await prefs.remove('refreshToken');

      // Get an instance of UserProfileProvider
      final userProfileProvider = Provider.of<UserProfileProvider>(context, listen: false);
      // Reset user profile when logging out
      userProfileProvider.resetUserProfile();
      
      if (context.mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => const LoginScreen(),
          ),
        );
      }

    } else {
      throw Exception('Failed to logout: ${response.reasonPhrase}');
    }
  } catch (e) {
    // Handle exception
    if (context.mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => const LoginScreen(),
        ),
      );
    }
  }
}
