import 'package:borderless/api/login_api.dart';
import 'package:borderless/screens/account/register.dart';
import 'package:borderless/theme/theme_provider.dart';
import 'package:borderless/utils/language_selection.dart';
import 'package:borderless/utils/notification_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:provider/provider.dart';

class LoginScreen extends StatefulWidget {
  final Function onLoginSuccess;

  const LoginScreen({super.key, required this.onLoginSuccess});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _loggingIn = false;

  // var to show or hide password
  bool _isObsecure = true;

   Future<void> _loginUser() async {
    setState(() {
      _loggingIn = true;
    });

    try {
      final isLoggedIn = await loginUser(
          context, _emailController.text, _passwordController.text);
      if (isLoggedIn) {
        widget.onLoginSuccess();
      }
    } finally {
      if (mounted) {
        setState(() {
          _loggingIn = false;
        });
      }
    }
  }

  @override
  void initState() {
     WidgetsBinding.instance.addPostFrameCallback((_) {
      NotificationController.displayNotificationRationale(context);
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: Theme.of(context).colorScheme.background,
        body: SingleChildScrollView(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            width: double.infinity,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(height: 100),
                // login
                const Text(
                  "Borderless",
                  style: TextStyle(
                      color: Colors.blue,
                      fontSize: 50,
                      fontWeight: FontWeight.w500),
                ),
                const SizedBox(
                  height: 100,
                ),
                // email
                Center(
                  child: Container(
                    decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.tertiary,
                        borderRadius: BorderRadius.circular(15)),
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: TextField(
                        cursorColor: Theme.of(context).colorScheme.secondary,
                        controller: _emailController,
                        autofocus: false,
                        style: TextStyle(color: Theme.of(context).colorScheme.secondary),
                        onChanged: (String text) {},
                        decoration: InputDecoration(
                          border: InputBorder.none,
                          prefixIcon: const Icon(Icons.person),
                          hintText: AppLocalizations.of(context)!.email,
                          hintStyle: const TextStyle(color: Colors.grey),
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(
                  height: 15,
                ),
                // password
                Center(
                  child: Container(
                    decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.tertiary,
                        borderRadius: BorderRadius.circular(15)),
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: TextField(
                        cursorColor: Theme.of(context).colorScheme.secondary,
                        controller: _passwordController,
                        autofocus: false,
                        obscureText: _isObsecure,
                        style: TextStyle(color: Theme.of(context).colorScheme.secondary),
                        onChanged: (String text) {},
                        decoration: InputDecoration(
                          prefixIcon: const Icon(Icons.lock_outline),
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
                          hintText: AppLocalizations.of(context)!.password,
                          hintStyle: const TextStyle(color: Colors.grey),
                          border: InputBorder.none
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(
                  height: 15,
                ),
                // button forget passqord and register
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    // forget password
                    TextButton(
                      style: TextButton.styleFrom(
                        foregroundColor: Colors.blue,
                      ),
                      onPressed: () {},
                      child: Text(AppLocalizations.of(context)!.forgetPassword),
                    ),
                    // register
                    TextButton(
                      style: TextButton.styleFrom(
                        foregroundColor: Colors.blue,
                      ),
                      onPressed: () {
                        // move to register page
                        //move to new creen
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const RegisterPage(),
                          ),
                        );
                      },
                      child: Text(AppLocalizations.of(context)!.register),
                    ),
                  ],
                ),
                const SizedBox(
                  height: 25,
                ),
                // button login
                Center(
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
                          // loginUser(context, _emailController.text,
                          //     _passwordController.text);
                          _loginUser();
                        },
                        child: Text(
                          _loggingIn ? '登錄中, 請稍等...' : AppLocalizations.of(context)!.login,
                          style: const TextStyle(color: Colors.white),
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 50.0),

                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: <Widget>[
                    Column(
                      children: [
                        GestureDetector(
                          onTap: () {
                            context.read<ThemeProvider>().selectLightTheme(ThemeType.light);
                          },
                          child: context.watch<ThemeProvider>().themeType == ThemeType.light 
                          ? const Icon(Icons.light_mode) :
                          const Icon(Icons.light_mode_outlined),
                        ),
                        const SizedBox(height: 7,),
                        Text(AppLocalizations.of(context)!.lightMode)
                      ],
                    ),
                    Column(
                      children: [
                        GestureDetector(
                          onTap: () {
                            context.read<ThemeProvider>().selectDarkTheme(ThemeType.dark);
                          },
                          child: context.watch<ThemeProvider>().themeType == ThemeType.dark ?
                          const Icon(Icons.dark_mode) :
                          const Icon(Icons.dark_mode_outlined),
                        ),
                        const SizedBox(height: 7,),
                        Text(AppLocalizations.of(context)!.darkmode)
                      ],
                    ),
                  ],
                ),
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 50),
                  child: LanguageSelection(),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
