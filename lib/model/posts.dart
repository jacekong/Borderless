import 'package:borderless/model/post_comment.dart';
import 'package:borderless/model/post_image.dart';
import 'package:borderless/model/post_video.dart';

class Post {
  final String id;
  final String content;
  final String createdDate;
  final String modifiedDate;
  final List<PostImage> postImages;
  final List<PostVideo> postVideo;
  final Map<String, dynamic> author;
  final List<PostCommentModel> comments;

  Post({
    required this.id,
    required this.content,
    required this.createdDate,
    required this.modifiedDate,
    required this.postImages,
    required this.postVideo,
    required this.author,
    required this.comments
  });

  factory Post.fromJson(Map<String, dynamic> json) {
    final List<dynamic> imagesData = json['post_images'];
    final List<PostImage> postImages = imagesData.map((data) => PostImage.fromJson(data)).toList();
    final List<dynamic> videoData = json['post_video'];
    final List<PostVideo> postVideo = videoData.map((data) => PostVideo.fromJson(data)).toList();
    final List<dynamic> comments = json['post_comments'];
    final List<PostCommentModel> postComments = comments.map((data) => PostCommentModel.fromJson(data)).toList();
    return Post(
      id: json['post_id'],
      content: json['post_content'],
      createdDate: json['created_date'],
      modifiedDate: json['modified_date'],
      postImages: postImages,
      postVideo: postVideo,
      author: json['author'],
      comments: postComments
    );
  }
}