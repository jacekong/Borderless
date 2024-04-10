import 'package:borderless/api/api_service.dart';
import 'package:borderless/model/chat_history.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

class ChatHistoryProvider extends ChangeNotifier {
  // setter, set the message to be none
  List<ChatMessage> _chatMssages = [];
  List<ImageMessage> _imageMessages = [];
  List<AudioMessage> _audioMessages = [];

  // getter
  List<ChatMessage> get chatMessages => _chatMssages;
  List<ImageMessage> get imageMessages => _imageMessages;
  List<AudioMessage> get audioMessages => _audioMessages;

  Future<void> fetchChatMessages(String userId) async {
    try {
      final List<ChatMessage> chatHistory =
          await ApiService.getUserTextChatHistory(userId);

      _chatMssages = chatHistory;

      notifyListeners();

    } catch (e) {
      Fluttertoast.showToast(
          msg: "Something went wrong, please try again",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.CENTER,
          timeInSecForIosWeb: 1,
          backgroundColor: Colors.red,
          textColor: Colors.white,
          fontSize: 16.0);
    }

  }
  Future<void> fetchImageMessages(String userId) async {
      try {
        final List<ImageMessage> chatHistory =
            await ApiService.getUserImageChatHistory(userId);

        _imageMessages = chatHistory;

        notifyListeners();

      } catch (e) {
        Fluttertoast.showToast(
            msg: "Something went wrong, please try again",
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.CENTER,
            timeInSecForIosWeb: 1,
            backgroundColor: Colors.red,
            textColor: Colors.white,
            fontSize: 16.0);
      }
    }

    Future<void> fetchAudioMessages(String userId) async {
      try {
        final List<AudioMessage> chatHistory =
            await ApiService.getUserAudioChatHistory(userId);

        _audioMessages = chatHistory;

        notifyListeners();

      } catch (e) {
        Fluttertoast.showToast(
            msg: "Something went wrong, please try again",
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.CENTER,
            timeInSecForIosWeb: 1,
            backgroundColor: Colors.red,
            textColor: Colors.white,
            fontSize: 16.0);
      }
    }
}
