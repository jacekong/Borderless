import 'package:borderless/api/auth_manager.dart';
import 'package:borderless/api/logout.dart';
import 'package:borderless/theme/theme_provider.dart';
import 'package:borderless/utils/language_selection.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:restart_app/restart_app.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class AccountDrawer extends StatefulWidget {

  const AccountDrawer({super.key});

  @override
  State<AccountDrawer> createState() => _AccountDrawerState();
}

class _AccountDrawerState extends State<AccountDrawer> {
  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: Theme.of(context).colorScheme.background,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              children: [
                DrawerHeader(child: Text(AppLocalizations.of(context)!.myAccount)),
                ListTile(
                  leading: const Icon(Icons.person_2_sharp),
                  title: Text(AppLocalizations.of(context)!.myProfile),
                ),
                ListTile(
                  leading: const Icon(Icons.privacy_tip),
                  title: Text(AppLocalizations.of(context)!.privacy),
                ),
                ListTile(
                  leading: Consumer<ThemeProvider>(
                    builder: (context, themeProvider, _) {
                      if (themeProvider.themeType == ThemeType.dark) {
                        return const Icon(Icons.light_mode);
                      } else {
                        return const Icon(Icons.dark_mode);
                      }
                    }
                  ),
                  title: ElevatedButton(
                    onPressed: () { 
                      Provider.of<ThemeProvider>(context, listen: false).toggleTheme(); 
                    },
                    child: Consumer<ThemeProvider>(
                      builder: (context, themeProvider, _) {
                        if (themeProvider.themeType == ThemeType.dark) {
                          return Text(AppLocalizations.of(context)!.lightMode, style: TextStyle(color: Theme.of(context).colorScheme.secondary),);
                        } else {
                            return Text(AppLocalizations.of(context)!.darkmode, style: TextStyle(color: Theme.of(context).colorScheme.secondary),);
                        }
                      }
                    )
                  ),
                ),
                const ListTile(
                  leading: Icon(Icons.language),
                  title: LanguageSelection(),
                ),
              ],
            ),
            ListTile(
              leading: const Icon(Icons.logout),
              title: Text(AppLocalizations.of(context)!.logout),
              onTap: () {
                logout(context);
                AuthManager.logout();
                Restart.restartApp();
              },
              trailing: const Text('Boderless v1.1.0 beta', style: TextStyle(color: Colors.grey, fontSize: 8),),
            ),
            
          ],
        ),
      );
  }
}
