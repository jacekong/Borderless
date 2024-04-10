import 'package:borderless/model/friend_request_status.dart';
import 'package:flutter/material.dart';

class FriendRequestStatusProvider extends ChangeNotifier {
  final Map<String, bool> _statusMap = {};

  FriendRequestStatus getStatus() {
    return FriendRequestStatus(_statusMap, statusMap: _statusMap);
  }

  void setFriendRequestSent(String userId, bool sent) {
    _statusMap[userId] = sent;
    notifyListeners();
  }
}
