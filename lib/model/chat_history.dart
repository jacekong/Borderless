import 'package:borderless/model/user_profile.dart';

class ChatMessage {
  final UserProfile sender;
  final UserProfile receiver;
  final String message;
  final String timestamp;

  ChatMessage({
    required this.sender,
    required this.receiver,
    required this.message,
    required this.timestamp,
  });

  factory ChatMessage.fromJson(Map<String, dynamic> json) {
    return ChatMessage(
      sender: UserProfile.fromJson(json['sender']),
      receiver: UserProfile.fromJson(json['receiver']),
      message: json['message'],
      timestamp: json['timestamp'],
    );
  }
}

class ImageMessage {
  final UserProfile sender;
  final UserProfile receiver;
  final String images;
  final String timestamp;

  ImageMessage({
    required this.sender,
    required this.receiver,
    required this.images,
    required this.timestamp,
  });

  factory ImageMessage.fromJson(Map<String, dynamic> json) {
    return ImageMessage(
      sender: UserProfile.fromJson(json['sender']),
      receiver: UserProfile.fromJson(json['receiver']),
      images: json['images'],
      timestamp: json['timestamp'],
    );
  }
}

class AudioMessage {
  final UserProfile sender;
  final UserProfile receiver;
  final String audio;
  final String duration;
  final String timestamp;

  AudioMessage({
    required this.sender,
    required this.receiver,
    required this.audio,
    required this.duration,
    required this.timestamp,
  });

  factory AudioMessage.fromJson(Map<String, dynamic> json) {
    return AudioMessage(
      sender: UserProfile.fromJson(json['sender']),
      receiver: UserProfile.fromJson(json['receiver']),
      audio: json['audio_file'],
      duration: json['duration'],
      timestamp: json['timestamp'],
    );
  }
}
