import 'package:borderless/api/api_service.dart';
import 'package:borderless/model/chat_list.dart';
import 'package:borderless/model/user_profile.dart';
import 'package:borderless/provider/user_profile_provider.dart';
import 'package:borderless/screens/chat/chat_page.dart';
import 'package:borderless/utils/format_date.dart';
import 'package:flutter/material.dart';
import 'package:page_transition/page_transition.dart';
import 'package:provider/provider.dart';

class ChatListScreen extends StatefulWidget {
  const ChatListScreen({super.key});

  @override
  State<ChatListScreen> createState() => _ChatListScreenState();
}

class _ChatListScreenState extends State<ChatListScreen> {
  late Future<List<ChatListModel>> _chatlist;

  @override
  void initState() {
    _chatlist = ApiService.getChatList();
    super.initState();
  }

  Future _refreshChatlist() async {
    setState(() {
      _chatlist = ApiService.getChatList();
    });
  }
  
  @override
  Widget build(BuildContext context) {
    final userProfileProvider = Provider.of<UserProfileProvider>(context);
    final UserProfile? userProfile = userProfileProvider.userProfile;

    if (userProfile == null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text("聊天"),
        ),
        body: const Center(
          child: Text("系統出小差啦。。。"),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(userProfile.username),
      ),
      body: RefreshIndicator(
        color: Colors.green,
        onRefresh: _refreshChatlist,
        child: FutureBuilder<List<ChatListModel>>(
          future: _chatlist,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              return Center(child: Text('Error: ${snapshot.error}'));
            } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return const Center(child: Text('No chat list available'));
            } else {
              final List<ChatListModel> chatlist = snapshot.data!;
              return ListView.builder(
                itemCount: chatlist.length,
                itemBuilder: (context, index) {
                  final chat = chatlist[index];
                  return ListTile(
                    leading: CircleAvatar(
                      backgroundImage: NetworkImage(chat.user2.avatar),
                    ),
                    title: Text(chat.user2.username, style: const TextStyle(fontSize: 18)),
                    subtitle: Text(DateFormatted().formatTimestamp(chat.updatedAt), style: const TextStyle(color: Colors.grey),),
                    onTap: () {
                      Navigator.push(
                        context, 
                        PageTransition(
                          type: PageTransitionType.bottomToTop, 
                          child: ChatPage(friend: chatlist[index].user2),
                        ),
                      );
                    },
                  );
                },
              );
            }
          },
        ),
      ),
    );
  }
}

