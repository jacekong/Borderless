import 'package:borderless/api/api_service.dart';
import 'package:borderless/model/user_profile.dart';
import 'package:borderless/screens/account/user_details.dart';
import 'package:flutter/material.dart';
import 'package:page_transition/page_transition.dart';

class SearchFriend extends StatefulWidget {
  const SearchFriend({super.key});

  @override
  State<SearchFriend> createState() => _SearchFriendState();
}

class _SearchFriendState extends State<SearchFriend> {
  final TextEditingController _searchController = TextEditingController();

  List<UserProfile> _searchResults = [];

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    _searchUser(_searchController.text);
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: const Text('找朋友', style: TextStyle(fontSize: 19),),
        ),
        body: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Container(
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.tertiary,
                  borderRadius: BorderRadius.circular(7)
                ),
                child: TextField(
                  onTapOutside: ((event) {
              FocusScope.of(context).unfocus();
            }),
                  cursorColor: Theme.of(context).colorScheme.secondary,
                  style: TextStyle(color: Theme.of(context).colorScheme.secondary),
                  controller: _searchController,
                  decoration: InputDecoration(
                    hoverColor: Theme.of(context).colorScheme.secondary,
                    hintText: '通過用戶名或ID查詢',
                    hintStyle: TextStyle(color: Theme.of(context).colorScheme.secondary),
                    prefixIcon: const Icon(Icons.search),
                    prefixIconColor: Theme.of(context).colorScheme.secondary,
                    border: InputBorder.none,  
                  ),
                ),
              ),
            ),
            Expanded(
              child: ListView.builder(
                itemCount: _searchResults.length,
                itemBuilder: (context, index) {
                  return ListTile(
                    title: Text(_searchResults[index].username),
                    leading: CircleAvatar(
                      backgroundImage:
                          NetworkImage(_searchResults[index].avatar),
                    ),
                    onTap: () {
                      // Navigator.push(
                      //   context,
                      //   MaterialPageRoute(
                      //     builder: (context) =>
                      //         USerDetailPage(user: _searchResults[index]),
                      //   ),
                      // );
                      Navigator.push(context, PageTransition(type: PageTransitionType.bottomToTop, child: UserDetailPage(user: _searchResults[index]),));
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _searchUser(String query) async {
    if (query.isNotEmpty) {
      try {
        final List<UserProfile> searchResults = await ApiService.searchUser(query);
        setState(() {
          _searchResults = searchResults;
        });
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('無法找到用戶: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } else {
      // Clear the search results if the query is empty
      setState(() {
        _searchResults.clear();
      });
    }
  }
  
}
