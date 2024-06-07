import 'dart:convert';
import 'package:borderless/api/api_endpoint.dart';
import 'package:borderless/api/auth_manager.dart';
import 'package:borderless/screens/login.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

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

      AuthManager.logout();

      if (context.mounted) {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(
            builder: (context) => LoginScreen(onLoginSuccess: () {
                },),
          ),
          (route) => false,
        );
      }

    } else {
      throw Exception('Failed to logout: ${response.reasonPhrase}');
    }
  } catch (e) {
    // Handle exception
    if (context.mounted) {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(
          builder: (context) => LoginScreen(onLoginSuccess: () {
                },),
        ),
        (route) => false,
      );
    }
  }
}
