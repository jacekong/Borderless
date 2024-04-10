import 'package:borderless/api/api_service.dart';
import 'package:borderless/model/friend_request.dart';
import 'package:flutter/material.dart';

class FriendRequestProvider extends ChangeNotifier {
  List<FriendRequest> _friendRequests = [];

  List<FriendRequest> get friendRequests => _friendRequests;

  bool isLoading = true;

  Future<void> fetchFriendRequests() async {
    try {
      _friendRequests = await ApiService.fetchFriendRequests();
      isLoading = false;
      notifyListeners();
    } catch (e) {
      rethrow;
    }
  }

  // Implement accept and refuse friend request methods if needed
}
