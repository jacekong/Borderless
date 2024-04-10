import 'package:borderless/api/api_service.dart';
import 'package:borderless/model/user_profile.dart';
import 'package:borderless/provider/request_provider.dart';
import 'package:borderless/screens/friends/friend_request.dart';
import 'package:borderless/screens/account/user_profile_page.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';


class FriendsList extends StatefulWidget {

  const FriendsList({super.key});

  @override
  State<FriendsList> createState() => _FriendsListState();
}

class _FriendsListState extends State<FriendsList> {

  late List<UserProfile> _requests = []; // Store the list of friend requests
  late List<UserProfile> _friends = [];

  @override
  void initState() {
    super.initState();
    _fetchFriendRequests(); // Call the method to fetch friend requests when the widget is initialized
    _fetchFriendList();
  }

  Future<void> _fetchFriendRequests() async {
    final friendRequestProvider = Provider.of<FriendRequestProvider>(context, listen: false);
    try {
      // Fetch friend requests
      await friendRequestProvider.fetchFriendRequests();
      // Update the local variable with the fetched requests
      setState(() {
        _requests = friendRequestProvider.friendRequests.cast<UserProfile>();
      });
    } catch (error) {
      // Handle error
    }
  }

  Future<void> _fetchFriendList() async {
    try {
      final List<UserProfile> friends = await ApiService.getFriendList();
      setState(() {
        _friends = friends;
      });
    } catch (error) {
      // Handle error
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Friends List",style: TextStyle(fontSize: 19),),
      ),
      body: RefreshIndicator(
        color: Colors.green,
        onRefresh: () {
          return Future.wait([
            _fetchFriendRequests(),
            _fetchFriendList(),
          ]);
        },
        child: ListView(
          children: [
            // Friend Requests section
            Card(
              child: ListTile(
                title: const Text("Friend Requests"),
                leading: Stack(
                  children: [
                    const Icon(Icons.people),
                    // Badge for friend requests
                    Positioned(
                      right: 0,
                      child: GestureDetector(
                        child: Container(
                          padding: const EdgeInsets.all(2),
                          decoration: BoxDecoration(
                            color: Colors.red,
                            borderRadius: BorderRadius.circular(50),
                          ),
                          constraints: const BoxConstraints(
                            minWidth: 16,
                            minHeight: 16,
                          ),
                          child: Text(
                            _requests.length.toString(), // Replace with the actual count of friend requests
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                onTap: () {
                  Navigator.push(context, MaterialPageRoute(builder: (context) => const FriendRequestList()));
                },
              ),
            ),
            // My Friends section
            Card(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Padding(
                    padding: EdgeInsets.all(8.0),
                    child: Text(
                      "My Friends",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  // List of friends
                  ListView.builder(
                    itemCount: _friends.length,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemBuilder: (context, index) {
                      final friend = _friends[index];
                      return ListTile(
                      leading: CircleAvatar(
                        backgroundImage: NetworkImage(friend.avatar),
                      ),
                      title: Text(friend.username),
                      onTap: () {
                        // Navigate to friend's profile page
                        Navigator.push(context, MaterialPageRoute(builder: (context) => UserProfilePage(userProfile: friend)));
                      },
                    );
                    },
             
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
