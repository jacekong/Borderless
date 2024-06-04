
import 'dart:io';
import 'package:borderless/utils/snack_bar.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:photo_view/photo_view.dart';
import 'package:path/path.dart' as path;

class ImagePreview extends StatefulWidget {
  final List<String> imageUrls;
  final int initialIndex;

  const ImagePreview({
    super.key,
    required this.imageUrls,
    this.initialIndex = 0,
  });

  @override
  State<ImagePreview> createState() => _ImagePreviewState();
}

class _ImagePreviewState extends State<ImagePreview> with AutomaticKeepAliveClientMixin {
  late PageController _pageController;
  int _currentPage = 0;

   @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: widget.initialIndex);
    _currentPage = widget.initialIndex;
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Scaffold(
      body:  GestureDetector(
        onHorizontalDragUpdate: (details) {
          if (details.delta.dx > 0) {
            _pageController.previousPage(
              duration: const Duration(milliseconds: 300),
              curve: Curves.ease,
            );
          } else {
            _pageController.nextPage(
              duration: const Duration(milliseconds: 300),
              curve: Curves.ease,
            );
          }
        },
        child: Stack(
          children: [
            PageView.builder(
              controller: _pageController,
              itemCount: widget.imageUrls.length,
              onPageChanged: (index) {
                setState(() {
                  _currentPage = index;
                });
              },
              itemBuilder: (context, index) {
                return Hero(
                  tag: widget.imageUrls[index],
                  child: PhotoView(
                    minScale: PhotoViewComputedScale.contained,
                    maxScale: PhotoViewComputedScale.covered * 4,
                    imageProvider: CachedNetworkImageProvider(
                      widget.imageUrls[index],
                    ),
                    initialScale: PhotoViewComputedScale.contained,
                  ),
                );
                
              },
            ),
            Positioned(
                    left: 10,
                    top: 50,
                    child: IconButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      icon: const Icon(Icons.cancel, color: Colors.white, size: 30,)
                    )
                  ),
            Positioned(
              bottom: 16,
              left: 0,
              right: 0,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(
                  widget.imageUrls.length,
                  (index) => Container(
                    width: 5,
                    height: 5,
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: _currentPage == index
                          ? Colors.grey
                          : Colors.grey[300],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }
   @override
  bool get wantKeepAlive => true;
    
}


// single chat image
class FullScreenImage extends StatelessWidget {
  final String imageUrl;

  const FullScreenImage({super.key, required this.imageUrl});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Hero(
          tag: imageUrl, // Unique tag for hero animation
          child: Stack(
            // fit: StackFit.expand,
            children: [
              Positioned.fill(
                child: PhotoView(
                      minScale: PhotoViewComputedScale.contained,
                      maxScale: PhotoViewComputedScale.covered * 4,
                      imageProvider: CachedNetworkImageProvider(
                        imageUrl,
                      ),
                      initialScale: PhotoViewComputedScale.contained,
                    ),
              ),
                  Positioned(
                    left: 20,
                    top: 50,
                    child: IconButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      icon: const Icon(Icons.cancel, color: Colors.white, size: 30,)
                    )
                  ),
                  Positioned(
                    bottom: 20,
                    right: 20,
                    child: IconButton(
                      onPressed: () {
                        // checkPermission();
                        _saveImage(context);
                      },
                      icon: const Icon(Icons.save_alt_rounded, color: Colors.white,)
                    )
                  ),
                ]
          ),
        ),
      ),
    );
  }

  Future<bool> _requestPermission(Permission permission) async {
    if (await permission.isGranted) {
      return true;
    } else {
      var result = await permission.request();
      if (result == PermissionStatus.granted) {
        return true;
      } else {
        return false;
      }
    }
  }

  Future _saveImage(context) async {
    Directory appDirectory;
    try {
      // Retrieve the image data-
      
      final imageBytes = await _getImageBytes();

      // Save image to gallery
      if (await _requestPermission(Permission.storage)) {
        appDirectory = (await getExternalStorageDirectory())!;

        String newPath = '';
        // '/storage/emulated/0/Android/data/com.example.borderless/files

        List<String> folderDirectory = appDirectory.path.split('/');
  
        for (int x = 1; x < folderDirectory.length; x++) {
          String folder = folderDirectory[x];
          if (folder != "Android") {
            newPath += "/$folder";
          } else {
            break;
          }
        }
        newPath = "$newPath/Borderless/files";
        appDirectory = Directory(newPath);

        File file = File(
        path.join(appDirectory.path, path.basename(imageUrl)));

        await file.writeAsBytes(imageBytes);

      } else {
        return false;
      }
      
      // Show a message indicating success
      CustomSnackbar.show(
        context: context, 
        message: '已保存到相冊', 
        backgroundColor: Colors.green,
      );
    } catch (e) {

      // Show an error message if saving fails
      CustomSnackbar.show(
        context: context, 
        message: '下載失敗: $e', 
        backgroundColor: Colors.red,
      );
    }
  }
  Future<List<int>> _getImageBytes() async {
    final response = await http.get(Uri.parse(imageUrl)); // Fetch image data
    
    if (response.statusCode == 200) {
      return response.bodyBytes; // Return image bytes
    } else {
      throw Exception('Failed to load image');
    }
  }

  
}