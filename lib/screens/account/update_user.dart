import 'dart:io';
import 'package:borderless/api/api_service.dart';
import 'package:borderless/model/user_profile.dart';
import 'package:borderless/provider/user_profile_provider.dart';
import 'package:borderless/utils/is_loading.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class UpdateUser extends StatefulWidget {
  const UpdateUser({
    super.key,
  });

  @override
  State<UpdateUser> createState() => _UpdateUserState();
}

class _UpdateUserState extends State<UpdateUser> {
  File? _image;
  final picker = ImagePicker();
  late final TextEditingController _usernameController;
  late final TextEditingController _emailController;
  late final TextEditingController _bioController;

  @override
  void initState() {
    super.initState();
    final userProfileProvider =
        Provider.of<UserProfileProvider>(context, listen: false);
    final UserProfile? userProfile = userProfileProvider.userProfile;

    _usernameController = TextEditingController(text: userProfile?.username ?? '');
    _emailController = TextEditingController(text: userProfile?.email ?? '');
    _bioController = TextEditingController(text: userProfile?.bio ?? '');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      appBar: AppBar(
        leading: BackButton(color: Theme.of(context).colorScheme.secondary),
        centerTitle: true,
        backgroundColor: Theme.of(context).colorScheme.background,
        elevation: 0,
        title: Text(
          AppLocalizations.of(context)!.updateProfile,
          style: TextStyle(color: Theme.of(context).colorScheme.secondary),
        ),
        actions: const [],
      ),
      body: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Avatar picture,
            Stack(
              children: [
                _image != null
                    ? Container(
                        height: 150,
                        width: 150,
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.tertiary,
                          borderRadius: BorderRadius.circular(100),
                        ),
                        // ignore: todo
                        //TODO: dispalay avatar image here
                        child: ClipRRect(
                            borderRadius: BorderRadius.circular(100),
                            child: Image.file(
                              _image!,
                              fit: BoxFit.cover,
                            ),
                        ),
                      )
                    : Container(
                        height: 150,
                        width: 150,
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.tertiary,
                          borderRadius: BorderRadius.circular(100),
                        ),
                        child: Center(child: Text(AppLocalizations.of(context)!.changeAvatar))),
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: GestureDetector(
                    onTap: () {
                      getImage();
                    },
                    child: const Icon(Icons.camera_alt_outlined),
                  ),
                )
              ],
            ),
            const SizedBox(
              height: 20,
            ),
            // Replace this part with the avatar widget
            //...

            // Username
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Center(
                child: Container(
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.tertiary,
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: TextField(
                      controller: _usernameController,
                      autofocus: false,
                      cursorColor: Theme.of(context).colorScheme.secondary,
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.secondary,
                      ),
                      onChanged: (String text) {},
                      decoration: InputDecoration(
                        border: InputBorder.none,
                        suffixIcon: const Icon(Icons.person),
                        labelText: AppLocalizations.of(context)!.userName,
                        labelStyle: TextStyle(
                          color: Theme.of(context).colorScheme.secondary,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),

            // Email
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Center(
                child: Container(
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.tertiary,
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: TextField(
                      controller: _emailController,
                      cursorColor: Theme.of(context).colorScheme.secondary,
                      autofocus: false,
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.secondary,
                      ),
                      onChanged: (String text) {},
                      decoration: InputDecoration(
                        border: InputBorder.none,
                        labelText: AppLocalizations.of(context)!.email,
                        labelStyle: TextStyle(
                          color: Theme.of(context).colorScheme.secondary,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Center(
                child: Container(
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.tertiary,
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: TextField(
                       maxLines: null,
                      controller: _bioController,
                      cursorColor: Theme.of(context).colorScheme.secondary,
                      autofocus: false,
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.secondary,
                      ),
                      onChanged: (String text) {},
                      decoration: InputDecoration(
                        border: InputBorder.none,
                        labelText: AppLocalizations.of(context)!.bio,
                        labelStyle: TextStyle(
                          color: Theme.of(context).colorScheme.secondary,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),

            // Confirm button
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Center(
                child: Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.blue,
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: TextButton(
                      onPressed: () {
                        _updateUserData();
                      },
                      child: Text(
                        AppLocalizations.of(context)!.confirm,
                        style: const TextStyle(color: Colors.white),
                      ),
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

  // get image ftom user from gallery
  Future getImage() async {
    final image = await picker.pickImage(source: ImageSource.gallery);
    if (image == null) return;

    setState(() {
      _image = File(image.path);
    });
  }

  Future _updateUserData() async {
    // Update user data using the controller values
    final String username = _usernameController.text;
    final String email = _emailController.text;
    final String bio = _bioController.text;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return const IsLoading();
      },
    );
    try {
      bool success = await ApiService.updateUserProfile(
        context: context,
        username: username,
        email: email,
        bio: bio,
        image: _image,
      );

      if (success) {
        // Registration successful, navigate to login screen
        if (mounted) {
          Navigator.of(context).pop(); // Close loading dialog
        }
      }
    } catch (e) {
      if (mounted) {
        Navigator.of(context).pop(); // Close loading dialog
      }
    }
  }
}
