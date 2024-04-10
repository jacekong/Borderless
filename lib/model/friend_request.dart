import 'package:borderless/model/user_profile.dart';

class FriendRequest {
  final UserProfile sender;
  final UserProfile receiver;
  final bool isActive;
  final DateTime timestamp;

  FriendRequest({
    required this.sender,
    required this.receiver,
    required this.isActive,
    required this.timestamp,
  });

  factory FriendRequest.fromJson(Map<String, dynamic> json) {
    return FriendRequest(
      sender: UserProfile.fromJson(json['sender']),
      receiver: UserProfile.fromJson(json['receiver']),
      isActive: json['is_active'],
      timestamp: DateTime.parse(json['timestamp']),
    );
  }
}
