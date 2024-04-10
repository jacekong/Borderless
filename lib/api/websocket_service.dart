
import 'dart:convert';
import 'package:web_socket_channel/io.dart';

class WebSocketService {
  final String wsUrl;
  final String? token;
  final Function(Map<String, dynamic>) onMessageReceived;
  final Function(dynamic) onError;
  final Function() onDone;

  late IOWebSocketChannel _channel;


  WebSocketService({
    required this.wsUrl,
    this.token,
    required this.onMessageReceived,
    required this.onError,
    required this.onDone,
  });

  void initWebSocket() {
    try {
      _channel = IOWebSocketChannel.connect(
        Uri.parse(wsUrl),
        headers: {
        'Authorization': 'Bearer $token',
      },
      );

      _channel.stream.listen(
        (message) {
          final decodedMessage = jsonDecode(message);
          onMessageReceived(decodedMessage);
        },
        onError: onError,
        onDone: onDone,
      );
    } catch (e) {
      onError(e);
    }
  }



  void sendMessage(String message) {
    _channel.sink.add(message);
  }

  void sendAudioMessage(String audioBytes) {
    _channel.sink.add(audioBytes);
  }

  void closeWebSocket() {
    _channel.sink.close();
  }
}
