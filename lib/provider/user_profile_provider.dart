import 'package:borderless/api/api_service.dart';
import 'package:borderless/api/auth_manager.dart';
import 'package:borderless/model/user_profile.dart';
import 'package:flutter/material.dart';

class UserProfileProvider extends ChangeNotifier {
  UserProfile? _userProfile;

  UserProfile? get userProfile => _userProfile;

  final String? token = AuthManager.getAuthToken();

  Future<UserProfile> fetchCurrentUser() async {
    try {
      final userProfile = await ApiService.getCurrentUserProfile();
      _userProfile = userProfile;

      notifyListeners();
      return userProfile;
      
    } catch (e) {
      rethrow;
    }
  }

  void resetUserProfile() {
    _userProfile = null;
    notifyListeners();
  }


}