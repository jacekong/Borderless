import 'package:borderless/api/api_service.dart';
import 'package:borderless/model/chat_list.dart';
import 'package:borderless/model/chatlist_with_msg.dart';
import 'package:borderless/model/user_profile.dart';
import 'package:borderless/provider/user_profile_provider.dart';
import 'package:borderless/screens/chat/chat_page.dart';
import 'package:borderless/screens/friends/friends_list.dart';
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
  late Future<Map<String, dynamic>> _chatlist;
  List<ChatListWithHistory> chatHistories = [];

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

  String getLatestMessage(ChatListWithHistory chatHistory) {
    if (chatHistory.chatHistory.isEmpty) {
      return 'No messages yet';
    }
    // Get the latest message
    final latestMessage = chatHistory.chatHistory.reduce((a, b) {
      final aTimestamp = DateTime.parse(a.timestamp);
      final bTimestamp = DateTime.parse(b.timestamp);
      return aTimestamp.isAfter(bTimestamp) ? a : b;
    });
    return latestMessage.message;
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
        child: FutureBuilder<Map<String, dynamic>>(
          future: _chatlist,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(child: CircularProgressIndicator(color: Theme.of(context).colorScheme.secondary,));
            } else if (snapshot.hasError) {
              return Center(child: Text('Error: ${snapshot.error}'));
            } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      PageTransition(
                        type: PageTransitionType.bottomToTop,
                        child: const FriendsList(),
                      ),
                    );
                  },
                  child: const Center(child: Text('去跟朋友問個好吧～')));
            } else {
              final chatLists = snapshot.data!['chatLists'] as List<ChatListModel>;
              final chatHistories = snapshot.data!['chatHistories'] as List<ChatListWithHistory>;
              return ListView.builder(
                itemCount: chatLists.length,
                itemBuilder: (context, index) {
                  final chat = chatLists[index];
                  final chatHistory = chatHistories.firstWhere((history) => history.chatList.id == chat.id);
                  final latestMessage = getLatestMessage(chatHistory);
                  return ListTile(
                    leading: CircleAvatar(
                      backgroundImage: NetworkImage(chat.user2.avatar),
                    ),
                    title: Text(chat.user2.username,
                        style: const TextStyle(fontSize: 18)),
                    subtitle: Text(latestMessage, style: const TextStyle(
                      fontSize: 12,
                      overflow: TextOverflow.ellipsis,
                      color: Colors.grey
                    ),),
                    trailing: Text(
                      DateFormatted().formatTimestamp(chat.updatedAt),
                      style: const TextStyle(color: Colors.grey, fontSize: 8),
                    ),
                    onTap: () {
                      Navigator.push(
                        context,
                        PageTransition(
                          type: PageTransitionType.bottomToTop,
                          child: ChatPage(friend: chat.user2),
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
