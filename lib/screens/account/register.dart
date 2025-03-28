import 'dart:io';
import 'package:borderless/api/api_service.dart';
import 'package:borderless/screens/login.dart';
import 'package:borderless/utils/is_loading.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  File? _image;
  final picker = ImagePicker();

  bool _isObsecure = true;
  bool _isSame = false;

  // text controller
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _emailController = TextEditingController();

  // Track validation state for each field
  bool _isUsernameValid = true;
  bool _isEmailValid = true;
  bool _isPasswordValid = true;
  bool _isConfirmPasswordValid = true;

  bool checkPassword() {
    if (_passwordController.text == _confirmPasswordController.text) {
      _isSame = true;
      return _isSame;
    } else {
      _isSame = false;
      return _isSame;
    }
  }

  bool isValidEmail(String email) {
    String pattern =
        r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,4}$';
    RegExp regex = RegExp(pattern);
    return regex.hasMatch(email);
  }

  void validateFields() {
    setState(() {
      _isUsernameValid = _usernameController.text.isNotEmpty;
      _isEmailValid = _emailController.text.isNotEmpty;
      _isPasswordValid = _passwordController.text.isNotEmpty;
      _isConfirmPasswordValid = _confirmPasswordController.text.isNotEmpty;
    });
  }

  void handleSubmit() {
    validateFields();
    checkPassword();

    if (_isUsernameValid && _isEmailValid && _isPasswordValid && _isConfirmPasswordValid && checkPassword() && isValidEmail(_emailController.text)) {
      uploadImg();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('你需要完成所有字段,并确保电子邮件格式正确'),
          backgroundColor: Colors.red,
        ),
      );
    }
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
            AppLocalizations.of(context)!.createUser,
            style: TextStyle(color: Theme.of(context).colorScheme.secondary),
          ),
          actions: const []),
      body: SingleChildScrollView(
        child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          // avatar picture
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
                          )),
                    )
                  : Container(
                      height: 150,
                      width: 150,
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.tertiary,
                        borderRadius: BorderRadius.circular(100),
                      ),
                      child: Center(child: Text(AppLocalizations.of(context)!.chooseAvatar, style: const TextStyle(fontSize: 12),))
                    ),
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
            height: 100,
          ),
          // user name
          //const Text("User name"),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Center(
              child: Container(
                decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.tertiary,
                    borderRadius: BorderRadius.circular(15),
                    border: Border.all(color: _isUsernameValid ? Colors.transparent : Colors.red)
                ),
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: TextField(
                    controller: _usernameController,
                    autofocus: false,
                    cursorColor: Theme.of(context).colorScheme.secondary,
                    style: TextStyle(color: Theme.of(context).colorScheme.secondary),
                    onChanged: (String text) {},
                    decoration: InputDecoration(
                        border: InputBorder.none,
                        suffixIcon: const Icon(Icons.person),
                        //hintText: 'Username',
                        labelText: AppLocalizations.of(context)!.userName,
                        labelStyle: TextStyle(color: Theme.of(context).colorScheme.secondary),
                        //hintStyle: TextStyle(color: Colors.grey),
                        ),
                  ),
                ),
              ),
            ),
          ),
          // const SizedBox(
          //   height: 15,
          // ),
          // email
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Center(
              child: Container(
                decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.tertiary,
                    borderRadius: BorderRadius.circular(15),
                    border: Border.all(color: _isEmailValid && isValidEmail(_emailController.text) ? Colors.transparent : Colors.red)
                ),
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: TextField(
                    controller: _emailController,
                    cursorColor: Theme.of(context).colorScheme.secondary,
                    autofocus: false,
                    //obscureText: true,
                    style: TextStyle(color: Theme.of(context).colorScheme.secondary),
                    onChanged: (String text) {},
                    decoration: InputDecoration(
                        border: InputBorder.none,
                        suffixIcon: const Icon(Icons.email),
                        //hintText: 'Password',
                        labelText: AppLocalizations.of(context)!.email,
                        //hintStyle: TextStyle(color: Colors.grey),
                        labelStyle: TextStyle(color: Theme.of(context).colorScheme.secondary),
                        ),
                  ),
                ),
              ),
            ),
          ),
          // password
          // password
          //const Text("Password"),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Center(
              child: Container(
                decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.tertiary,
                    borderRadius: BorderRadius.circular(15),
                    border: Border.all(color: _isPasswordValid ? Colors.transparent : Colors.red)
                ),
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: TextField(
                    controller: _passwordController,
                    autofocus: false,
                    cursorColor: Theme.of(context).colorScheme.secondary,
                    obscureText: _isObsecure,
                    style: TextStyle(color: Theme.of(context).colorScheme.secondary),
                    onChanged: (String text) {},
                    decoration: InputDecoration(
                      border: InputBorder.none,
                        suffixIcon: IconButton(
                          onPressed: () => setState(
                              () {
                                _isObsecure = !_isObsecure;
                              },
                            ), 
                          icon: Icon(
                              _isObsecure
                                  ? Icons.visibility
                                  : Icons.visibility_off,
                            ),
                        ),
                        //hintText: 'Password',
                        labelText: AppLocalizations.of(context)!.password,
                        labelStyle: TextStyle(color: Theme.of(context).colorScheme.secondary),
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
                    border: Border.all(color: _isConfirmPasswordValid && _isSame ? Colors.transparent : Colors.red)
                ),
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: TextField(
                    controller:  _confirmPasswordController,
                    autofocus: false,
                    cursorColor: Theme.of(context).colorScheme.secondary,
                    obscureText: _isObsecure,
                    style: TextStyle(color: Theme.of(context).colorScheme.secondary),
                    onChanged: (String text) {},
                    decoration: InputDecoration(
                      border: InputBorder.none,
                        suffixIcon: IconButton(
                          onPressed: () => setState(
                              () {
                                _isObsecure = !_isObsecure;
                              },
                            ), 
                          icon: Icon(
                              _isObsecure
                                  ? Icons.visibility
                                  : Icons.visibility_off,
                            ),
                        ),
                        //hintText: 'Password',
                        labelText:AppLocalizations.of(context)!.confirmPassword,
                        labelStyle: TextStyle(color: Theme.of(context).colorScheme.secondary),
                        ),
                  ),
                ),
                
              ),
            ),
          ),
          const SizedBox(
            height: 100,
          ),
          // comfirm button
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Center(
              child: Container(
                width: double.infinity,
                decoration: BoxDecoration(
                    color: Colors.blue,
                    borderRadius: BorderRadius.circular(15)),
                child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: TextButton(
                      style: TextButton.styleFrom(
                        foregroundColor: Colors.blue,
                      ),
                      onPressed: () {
                        // _showDialog();
                        // uploadImg();
                        handleSubmit();
                      },
                      child: Text(
                        AppLocalizations.of(context)!.confirm,
                        style: const TextStyle(color: Colors.white),
                      ),
                    )),
              ),
            ),
          ),
        ]),
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

  // upload image to db server
  Future uploadImg() async {

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return const IsLoading();
      },
    );

    try {
      bool success = await ApiService.register(
        username: _usernameController.text,
        email: _emailController.text,
        password: _passwordController.text,
        image: _image,
      );

      if (success) {
        // Registration successful, navigate to login screen
        if (mounted) {

          Navigator.of(context).pop(); // Close loading dialog
        }
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('註冊成功啦,小夥伴。恭喜成為Borderless的一員'),
              backgroundColor: Colors.green,
            ),
          );
        }
        if (mounted) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => LoginScreen(
                onLoginSuccess: () {
                },
              ),
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {

        Navigator.of(context).pop();
      }

    }
  }

  // void _showDialog() {
  //   showDialog(
  //       context: context,
  //       builder: (context) {
  //         return ShowDialogPage(
  //           username: _usernameController.text,
  //           password: _passwordController.text,
  //           cancel: () => Navigator.of(context).pop(),
  //           register: uploadImg,
  //         );
  //       });
  // }

} //ec

// ignore: must_be_immutable
class ShowDialogPage extends StatelessWidget {
  final String username;
  final String password;

  VoidCallback register;
  VoidCallback cancel;

  ShowDialogPage(
      {required this.username,
      super.key,
      required this.password,
      required this.register,
      required this.cancel});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(AppLocalizations.of(context)!.confirmPassword),
      content: Container(
        height: 200,
        decoration: BoxDecoration(
            color: Colors.white, borderRadius: BorderRadius.circular(15)),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 15, bottom: 15),
              child: Row(
                children: [
                  Text(AppLocalizations.of(context)!.userName),
                  Text(username),
                ],
              ),
            ),
            Row(
              children: [
                Text(AppLocalizations.of(context)!.password),
                Text(password),
              ],
            ),
            const SizedBox(
              height: 30,
            ),
            // buttons
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                // confirm
                MaterialButton(
                  onPressed: () {
                    register();
                  },
                  color: Colors.blue,
                  child:
                      Text(AppLocalizations.of(context)!.confirmPassword, style: const TextStyle(color: Colors.white)),
                ),
                const SizedBox(width: 7),
                // discard
                MaterialButton(
                  onPressed: () {
                    cancel();
                  },
                  color: Colors.red,
                  child: const Text(
                    "取消",
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
