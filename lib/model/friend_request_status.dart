class FriendRequestStatus {
  final Map<String, bool> statusMap;

  FriendRequestStatus(Map<String, bool> map, {required this.statusMap});

  bool isFriendRequestSent(String userId) {
    return statusMap.containsKey(userId) ? statusMap[userId]! : false;
  }
}