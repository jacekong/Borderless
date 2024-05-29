import 'package:borderless/api/auth_manager.dart';
import 'package:borderless/api/logout.dart';
import 'package:borderless/theme/theme_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:restart_app/restart_app.dart';

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
                const DrawerHeader(child: Text("我的帳戶")),
                const ListTile(
                  leading: Icon(Icons.person_2_sharp),
                  title: Text("我的資料"),
                ),
                const ListTile(
                  leading: Icon(Icons.privacy_tip),
                  title: Text("隱私設置"),
                ),
                ListTile(
                  leading: const Icon(Icons.nightlight_outlined),
                  title: ElevatedButton(
                    onPressed: () { Provider.of<ThemeProvider>(context, listen: false).toggleTheme(); },
                    child: Text("夜間模式", style: TextStyle(color: Theme.of(context).colorScheme.secondary),),
                  ),
                )
              ],
            ),
            ListTile(
              leading: const Icon(Icons.logout),
              title: const Text("退出登錄"),
              onTap: () {
                logout(context);
                AuthManager.logout();
                Restart.restartApp();
              },
            ),
            
          ],
        ),
      );
  }
}
