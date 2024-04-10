import 'package:flutter_dotenv/flutter_dotenv.dart';

class WebsocketApi {
  static String wsUrl = dotenv.get('websocketEnpoint');
}