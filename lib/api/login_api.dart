import 'dart:convert';
import 'package:borderless/api/auth_manager.dart';
import 'package:borderless/api/api_endpoint.dart';
import 'package:borderless/components/home.dart';
import 'package:borderless/provider/user_profile_provider.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';


Future loginUser(context, String email, String password) async {
  String apiUrl = '${ApiEndpoint.endpoint}/api/token/';

  try {
    final response = await http.post(
      Uri.parse(apiUrl),
      body: json.encode({'email': email, 'password': password}),
      headers: {'Content-Type': 'application/json'},
    ).timeout(const Duration(seconds: 5));

    if (response.statusCode == 200) {
      // Login successful, parse response and store authentication token
      final accessToken = json.decode(response.body);
      final authToken = accessToken['access'];
      final refreshToken = accessToken['refresh'];

      // Store authentication token
      await AuthManager.login(authToken, refreshToken);

      final userProfileProvider = Provider.of<UserProfileProvider>(context, listen: false);
      // Reset user profile when logging out
      userProfileProvider.resetUserProfile();

      if (context.mounted) {
        return await Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) =>
                const Home(),
          ),
        );
      }
    } else {
      if (context.mounted) {
        _showDialogLogin(context);
      }
    }
  } catch (e) {
    if (context.mounted) {
      _showDialogLogin(context);
    }
  }
}

Future _showDialogLogin(context) {
  return showDialog(
    context: context,
    builder: (context) {
      return AlertDialog(
        content: SizedBox(
          height: 200,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text("Woops...🥲"),
              const SizedBox(
                height: 10,
              ),
              const Text(
                  "郵箱或密碼可能不對喔，再試一次吧～"),
              const SizedBox(
                height: 20,
              ),
              // button
              MaterialButton(
                color: Colors.blue,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(7),
                ),
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: const Text(
                  "確認",
                  style: TextStyle(color: Colors.white),
                ),
              )
            ],
          ),
        ),
      );
    },
  );
}
