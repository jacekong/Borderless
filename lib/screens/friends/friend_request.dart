import 'package:borderless/api/api_service.dart';
import 'package:borderless/provider/request_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class FriendRequestList extends StatefulWidget {
  const FriendRequestList({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _FriendRequestListState createState() => _FriendRequestListState();
}

class _FriendRequestListState extends State<FriendRequestList> {

  @override
  void initState() {
    super.initState();
    Provider.of<FriendRequestProvider>(context, listen: false).fetchFriendRequests();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.friendRequest),
        centerTitle: true,
      ),
      body: Consumer<FriendRequestProvider>(
      builder: (context, friendRequestProvider, _) {
        // Check if friend requests are still loading
        if (friendRequestProvider.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        // Check if there are no friend requests
        if (friendRequestProvider.friendRequests.isEmpty) {
          return Center(child: Text(AppLocalizations.of(context)!.noRequest));
        }

        return ListView.builder(
          itemCount: friendRequestProvider.friendRequests.length,
          itemBuilder: (context, index) {
            final friendRequest = friendRequestProvider.friendRequests[index];
            final sender = friendRequest.sender;

            return ListTile(
              leading: CircleAvatar(
                backgroundImage: NetworkImage(sender.avatar),
              ),
              title: Text(sender.username),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  ElevatedButton(
                    onPressed: () {
                      // Accept friend request
                      ApiService.acceptFriendRequest(context,sender.id);
                      // print("Friend request accepted: ${sender.id}");
                    },
                    child: Text('接受', style: TextStyle(color: Theme.of(context).colorScheme.secondary),),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton(
                    onPressed: () {
                      // Refuse friend request
                      // Implement your logic here
                    },
                    child: const Text('拒絕', style: TextStyle(color: Colors.red),),
                  ),
                ],
              ),
            );
          },
        );
      },
    ),
    );
  }
}
