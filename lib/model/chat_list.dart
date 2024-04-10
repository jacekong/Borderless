import 'package:borderless/model/user_profile.dart';

class ChatListModel {
  final int id;
  final UserProfile user1;
  final UserProfile user2;
  final String createdAt;
  final String updatedAt;

  ChatListModel({
    required this.id,
    required this.user1,
    required this.user2,
    required this.createdAt,
    required this.updatedAt,
  });

  factory ChatListModel.fromJson(Map<String, dynamic> json) {
    return ChatListModel(
      id: json['id'],
      user1: UserProfile.fromJson(json['user1']),
      user2: UserProfile.fromJson(json['user2']),
      createdAt: json['created_at'],
      updatedAt: json['updated_at'],
    );
  }
}
