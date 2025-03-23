import 'package:borderless/model/user_profile.dart';

class PostCommentModel {
  final int id;
  final UserProfile sender;
  final String comment;
  final String post;
  final String timestamp;
  final int? parent;
  final bool is_visible;
  final bool is_deleted;

  PostCommentModel({
    required this.id,
    required this.sender,
    required this.comment,
    required this.post,
    required this.timestamp,
    this.parent,
    required this.is_visible,
    required this.is_deleted
  });

  factory PostCommentModel.fromJson(Map<String, dynamic> json) {
    return PostCommentModel(
      id: json['id'],
      sender: UserProfile.fromJson(json['sender']),
      comment: json['comment'],
      post: json['post'],
      timestamp: json['timestamp'],
      parent: json['parent'],
      is_visible: json['is_visible'],
      is_deleted: json['is_deleted'],
    );
  }
}
