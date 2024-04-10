import 'package:borderless/model/user_profile.dart';

class PostCommentModel {
  final int id;
  final UserProfile sender;
  final String comment;
  final String post;
  final String timestamp;

  PostCommentModel({
    required this.id,
    required this.sender,
    required this.comment,
    required this.post,
    required this.timestamp,
  });

  factory PostCommentModel.fromJson(Map<String, dynamic> json) {
    return PostCommentModel(
      id: json['id'],
      sender: UserProfile.fromJson(json['sender']),
      comment: json['comment'],
      post: json['post'],
      timestamp: json['timestamp'],
    );
  }
}
