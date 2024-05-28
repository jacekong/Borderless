import 'dart:io';
import 'package:borderless/api/api_service.dart';
import 'package:borderless/api/auth_manager.dart';
import 'package:borderless/model/user_profile.dart';
import 'package:borderless/provider/user_profile_provider.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

class CreatePost extends StatefulWidget {
  const CreatePost({super.key});

  @override
  State<CreatePost> createState() => _CreatePostState();
}

class _CreatePostState extends State<CreatePost> {
  final ImagePicker imagePicker = ImagePicker();
  final _captionController = TextEditingController();

  List<XFile> images = [];
  // List<XFile> videos = [];

  void pickImages() async {
    if (images.length > 9) {
      // Show a message or perform any action to indicate that the limit is reached
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
    super.dispose();
  }


  @override
  Widget build(BuildContext context) {
    final userProfileProvider = Provider.of<UserProfileProvider>(context);
    final UserProfile? userProfile = userProfileProvider.userProfile;

    double screenWidth = MediaQuery.of(context).size.width;

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
                        NetworkImage(userProfile!.avatar), // Use NetworkImage
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
            // image pick button
            Align(
              alignment: Alignment.centerLeft,
              child: Padding(
                padding: EdgeInsets.only(left: screenWidth * 0.007),
                child: IconButton(
                    onPressed: () => pickImages(),
                    icon: const Icon(Icons.image)),
              ),
            ),
            const SizedBox(
              height: 30,
            ),
            Expanded(
              child: ReorderableListView.builder(
                itemCount: images.length,
                itemBuilder: (context, index) {
                  return ListTile(
                    key: Key(images[index].path),
                    leading: Image.file(File(images[index].path)),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete),
                      onPressed: () => deleteImage(index),
                    ),
                  );
                },
                onReorder: onReorder,
              ),
            ),

            // post button
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).colorScheme.secondary),
              onPressed: () async {
                await ApiService.uploadPost(
                    context, authToken!, _captionController.text, images);
                // After successfully creating the post, pop the create post window
                _captionController.clear();
                images.clear();
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
