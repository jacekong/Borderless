import 'package:borderless/model/chat_history.dart';
import 'package:borderless/model/chat_list.dart';

class ChatListWithHistory {
  final ChatListModel chatList;
  final List<ChatMessage> chatHistory;

  ChatListWithHistory({
    required this.chatList,
    required this.chatHistory,
  });

  factory ChatListWithHistory.fromJson(Map<String, dynamic> json) {
    return ChatListWithHistory(
      chatList: ChatListModel.fromJson(json['chat_list']),
      chatHistory: (json['chat_history'] as List)
          .map((i) => ChatMessage.fromJson(i))
          .toList(),
    );
  }
}
