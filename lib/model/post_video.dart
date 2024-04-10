class PostVideo {
  final String video;

  PostVideo({
    required this.video,
  });

  factory PostVideo.fromJson(Map<String, dynamic> json) {
    return PostVideo(
      video: json['video'],
    );
  }
}