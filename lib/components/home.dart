import 'package:borderless/api/auth_manager.dart';
import 'package:borderless/screens/friends/friends_list.dart';
import 'package:borderless/screens/friends/search_friend.dart';
import 'package:flutter/material.dart';
import 'package:borderless/screens/posts/home_page.dart';
import 'package:borderless/screens/account/settings.dart';

class Home extends StatefulWidget {
  
  const Home({
    super.key,
  });

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  // User is logged in, retrieve auth token
  final authToken = AuthManager.getAuthToken();
  final refreshToken = AuthManager.getRefreshToken();
   // navigate the bottom bar
  int _selectedIndex = 0;

  void _bottomNavigator(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _selectedIndex,
        children: const[
          HomePage(),
          SearchFriend(),
          FriendsList(),
          Settings(),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _bottomNavigator,
        selectedItemColor: Theme.of(context).colorScheme.secondary,
        unselectedItemColor: Colors.grey.shade500,
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: ''
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.search),
            label: ''
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_add_rounded),
            label: ''
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            label: ''
          ),
        ],
      ),
    );
  }
}