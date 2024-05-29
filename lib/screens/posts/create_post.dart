import 'dart:io';
import 'package:borderless/api/api_service.dart';
import 'package:borderless/api/auth_manager.dart';
import 'package:borderless/model/user_profile.dart';
import 'package:borderless/provider/user_profile_provider.dart';
import 'package:chewie/chewie.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:reorderable_grid_view/reorderable_grid_view.dart';
import 'package:video_player/video_player.dart';

class CreatePost extends StatefulWidget {
  const CreatePost({super.key});

  @override
  State<CreatePost> createState() => _CreatePostState();
}

class _CreatePostState extends State<CreatePost> {
  final ImagePicker imagePicker = ImagePicker();
  final _captionController = TextEditingController();

  VideoPlayerController? _videoController;
  ChewieController? _chewieController;

  List<XFile> images = [];
  File? _video;

  _pickVideo() async {
    final video = await imagePicker.pickVideo(source: ImageSource.gallery);

    if (video == null) return;

    _video = File(video.path);

    _videoController?.dispose();
    _chewieController?.dispose();

    _videoController = VideoPlayerController.file(_video!)
    ..initialize().then((_) {
      setState(() {});
    });

    _chewieController = ChewieController(
      videoPlayerController: _videoController!,
      autoPlay: false,
      looping: false,
    );
    // _videoController?.play();
    // _videoController?.pause();
  }

  void pickImages() async {
    if (images.length > 9) {
      return;
    }

    final List<XFile> selectedImages = await imagePicker.pickMultiImage();
    if (selectedImages.isNotEmpty) {
      setState(() {
        images.addAll(selectedImages);
      });
    }

  }

  void deleteImage(int index) {
    setState(() {
      images.removeAt(index);
    });
  }

  void deleteVideo() {
    if (_videoController != null) {
      _videoController!.pause();
      _videoController!.dispose();
      _chewieController?.dispose();
      setState(() {
        _videoController = null;
        _chewieController = null;
        _video = null;
      });
    }
  }

  void onReorder(int oldIndex, int newIndex) {
    setState(() {
      if (newIndex > oldIndex) {
        newIndex -= 1;
      }
      final XFile image = images.removeAt(oldIndex);
      images.insert(newIndex, image);
    });
  }

  final String? authToken = AuthManager.getAuthToken();

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _captionController.dispose();
    _videoController?.dispose();
    _chewieController?.dispose();
    super.dispose();
  }


  @override
  Widget build(BuildContext context) {
    final userProfileProvider = Provider.of<UserProfileProvider>(context);
    final UserProfile? userProfile = userProfileProvider.userProfile;

    double screenWidth = MediaQuery.of(context).size.width;

    if (userProfile == null) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("創建新的貼文"),
      ),
      body: const Center(
        child: Text("系統出小差啦。。。"),
      ),
    );
  }
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      appBar: AppBar(
        leading: IconButton(
            onPressed: () => Navigator.pop(context), 
            icon: const Icon(Icons.cancel),
          ),
          elevation: 0,
          centerTitle: false,
          title: const Text(
            "創建新的貼文",
            style: TextStyle(fontSize: 19),
          ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            // User avatar and username,
              Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 20,
                    backgroundImage:
                        NetworkImage(userProfile.avatar), // Use NetworkImage
                  ),
                  const SizedBox(width: 8),
                  Text(
                    userProfile.username,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
            // caption
            Padding(
              padding: EdgeInsets.only(left: screenWidth * 0.05),
              child: TextField(
                autofocus: false,
                controller: _captionController,
                style:
                    TextStyle(color: Theme.of(context).colorScheme.secondary),
                onChanged: (String text) {},
                maxLines: null,
                decoration: InputDecoration(
                  focusColor: Theme.of(context).colorScheme.secondary,
                  border: const UnderlineInputBorder(),
                  enabledBorder: UnderlineInputBorder(
                    borderSide: BorderSide(
                        color: Theme.of(context).colorScheme.secondary),
                  ),
                  focusedBorder: UnderlineInputBorder(
                    borderSide: BorderSide(
                        color: Theme.of(context).colorScheme.secondary),
                  ),
                  labelText: "撰寫貼文。。。",
                  labelStyle:
                      TextStyle(color: Theme.of(context).colorScheme.secondary),
                ),
                cursorColor: Theme.of(context).colorScheme.secondary,
              ),
            ),
            Row(
              children: [
                // image pick button
                Align(
                  alignment: Alignment.centerLeft,
                  child: Padding(
                    padding: EdgeInsets.only(left: screenWidth * 0.007),
                    child: IconButton(
                        onPressed:  _videoController == null
                        ? () => pickImages()
                        : null,
                        icon: const Icon(Icons.image),
                      ),
                  ),
                ),
                // video pick button
                Align(
                  alignment: Alignment.centerLeft,
                  child: Padding(
                    padding: EdgeInsets.only(left: screenWidth * 0.007),
                    child: 
                    // IconButton(
                    //     onPressed: () {
                    //       _pickVideo();
                    //     },
                    //     icon: const Icon(Icons.video_collection_rounded),
                    // ),
                    IconButton(
                    onPressed: images.isEmpty && _videoController == null
                        ? () {
                            _pickVideo();
                          }
                        : null, // Disable if images are picked
                    icon: const Icon(Icons.video_collection_rounded),
                    color: images.isEmpty && _videoController == null
                        ? null
                        : Colors.grey, // Change color if disabled
                  ),
                  ),
                ),
              ],
            ),
            const SizedBox(
              height: 30,
            ),
            Expanded(
              child: images.isNotEmpty ? 
              ReorderableGridView.builder(
                      itemCount: images.length,
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 3, // Number of columns
                        crossAxisSpacing: 8,
                        mainAxisSpacing: 8,
                        childAspectRatio: 1, // Ratio of child width to height
                      ),
                      itemBuilder: (context, index) {
                        return GridTile(
                          key: Key(images[index].path),
                          child: Stack(
                            children: [
                              Image.file(
                                File(images[index].path),
                                fit: BoxFit.cover,
                                width: double.infinity,
                                height: double.infinity,
                              ),
                              Positioned(
                                top: 0,
                                right: 0,
                                child: IconButton(
                                  icon: Container(
                                    height: 30,
                                    width: 30,
                                    decoration: BoxDecoration(
                                      color: Colors.black,
                                      borderRadius: BorderRadius.circular(50)
                                    ),
                                    child: const Icon(Icons.cancel,
                                        color: Colors.white),
                                  ),
                                  onPressed: () => deleteImage(index),
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                      onReorder: (oldIndex, newIndex) {
                        setState(() {
                          if (newIndex > oldIndex) {
                            newIndex -= 1;
                          }
                          final XFile image = images.removeAt(oldIndex);
                          images.insert(newIndex, image);
                        });
                      },
                    )
              : _videoController != null && _videoController!.value.isInitialized
                    ? _videoController!.value.isInitialized
                        ? AspectRatio(
                            aspectRatio: _videoController!.value.aspectRatio,
                            child: Stack(children: [
                                Chewie(controller: _chewieController!,),
                                // Delete video button
                                if (_videoController != null)
                                  Positioned(
                                    top: 3,
                                    right: 3,
                                    child: Padding(
                                    padding: EdgeInsets.only(left: screenWidth * 0.007),
                                    child: IconButton(
                                        onPressed: () => deleteVideo(),
                                        icon: Container(
                                          width: 30,
                                          height: 30,
                                          decoration: BoxDecoration(
                                            borderRadius: BorderRadius.circular(50),
                                            color: Colors.black,
                                          ),
                                          child: const Icon(
                                            Icons.delete_forever, 
                                            color: Colors.white,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                          )
                        : const Center(child: CircularProgressIndicator())
                    : const Center(child: Text('選一張你喜歡的相片吧～')),

            ),
            // post button
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).colorScheme.secondary),
              onPressed: () async {
                await ApiService.uploadPost(
                    context, authToken!, _captionController.text, images, _video);
                // After successfully creating the post, pop the create post window
                _captionController.clear();
                images.clear();
                deleteVideo();
              },
              child: Padding(
                padding: const EdgeInsets.only(left: 32, right: 32),
                child: Text(
                  '發送✅',
                  style:
                      TextStyle(color: Theme.of(context).colorScheme.primary),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  } 

}
