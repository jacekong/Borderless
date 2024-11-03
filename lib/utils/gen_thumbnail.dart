import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:video_thumbnail/video_thumbnail.dart';

class VideoThumbnailUtil {

  static Future<String> generateThumbnail(String videoUrl, String postId) async {
    final Directory tempDir = await getTemporaryDirectory();
    final String tempPath = tempDir.path;
    final String thumbnailPath = '$tempPath/$postId.jpg';

    if (await File(thumbnailPath).exists()) {
      return thumbnailPath;
    }

    try {
      final thumbnail = await VideoThumbnail.thumbnailFile(
        video: videoUrl,
        thumbnailPath: thumbnailPath,
        imageFormat: ImageFormat.JPEG,
        maxHeight: 200,
        quality: 75,
      );
      return thumbnail!;
    } catch (e) {
      print('Error generating thumbnail: $e');
      return '';
    }
  }

}
