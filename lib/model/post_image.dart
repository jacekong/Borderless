class PostImage {
  final String images;

  PostImage({
    required this.images,
  });

  factory PostImage.fromJson(Map<String, dynamic> json) {
    return PostImage(
      images: json['images'],
    );
  }
}
