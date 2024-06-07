import 'dart:async';
import 'dart:io';
import 'package:borderless/api/auth_manager.dart';
import 'package:borderless/api/websocket_api.dart';
import 'package:borderless/api/websocket_service.dart';
import 'package:borderless/components/home.dart';
import 'package:borderless/provider/chat_history_provider.dart';
import 'package:borderless/provider/friend_request_provider.dart';
import 'package:borderless/provider/request_provider.dart';
import 'package:borderless/provider/user_profile_provider.dart';
import 'package:borderless/screens/login.dart';
import 'package:borderless/screens/posts/create_post.dart';
import 'package:borderless/theme/dark_theme.dart';
import 'package:borderless/theme/light_theme.dart';
import 'package:borderless/theme/theme_provider.dart';
import 'package:borderless/utils/notification_controller.dart';
import 'package:borderless/utils/notification_manager.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:provider/provider.dart';
import 'package:logger/logger.dart';

final navigatorKey = GlobalKey<NavigatorState>();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Always initialize Awesome Notifications
  await NotificationController.initializeLocalNotifications();
  await AuthManager.init();
  await NotificationManager.init();
  ByteData data = await PlatformAssetBundle().load('assets/ca/lets-encrypt-r3.pem');
  SecurityContext.defaultContext.setTrustedCertificatesBytes(data.buffer.asUint8List());
  await dotenv.load(fileName: ".env");
  
  runApp(
   MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => FriendRequestStatusProvider()),
        ChangeNotifierProvider(create: (_) => UserProfileProvider()),
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(create: (_) => FriendRequestProvider()),
        ChangeNotifierProvider(create: (_) => ChatHistoryProvider())
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatefulWidget {

  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
   // get websocket instance
  late WebSocketService _webSocketService;
  final String? token = AuthManager.getAuthToken();
  var logger = Logger();
  late Timer _reconnectTimer;
  bool _isConnected = false;

  void _initWebSocket(token) {
    logger.d('Notification websocket is running...');
    final wsUrl =
        '${WebsocketApi.wsUrl}ws/notifications/';
    _webSocketService = WebSocketService(
      wsUrl: wsUrl,
      token: token,
      onMessageReceived: _handleMessageReceived,
      onError: _handleError,
      onDone: _handleWebSocketDone,
    );
    _webSocketService.initWebSocket();
    _isConnected = true;
  }

  void _handleMessageReceived(Map<String, dynamic> message) async {
    final String? chatUser = NotificationManager.getUserId();
    final notification = message['notification'];
    final sender = message['sender'];
    final senderId = message['sender_id'];
    final messageType = message['message_type'];
    final avatar = message['avatar'];

    if (senderId != chatUser) {
      await NotificationController.createNewNotification(
        sender, 
        notification,
        avatar,
        messageType,
      );
    }

  }
  void _handleError(dynamic error) {
    logger.d('Notification websocket stop running...');
    logger.e(error);
    _isConnected = false;
    _reconnect(token);
  }

  void _handleWebSocketDone() {
    logger.d('WebSocket connection closed');
  }
  void _reconnect(token) {
    if (!_isConnected) {
      _reconnectTimer = Timer(const Duration(seconds: 5), () {
        _initWebSocket(token);
      });
    }
  }

  @override
  void initState() {
    _checkLoginStatus();
    super.initState();
  }

  void _checkLoginStatus() async {
    final isLoggedIn = await AuthManager.isLoggedIn();
    if (isLoggedIn) {
      _initWebSocket(token);
    }
  }

  @override
  void dispose() {
    _webSocketService.closeWebSocket();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorKey: navigatorKey,
      title: 'Borderless',
      debugShowCheckedModeBanner: false,
      theme: lightTheme,
      darkTheme: darkTheme,
      themeMode: Provider.of<ThemeProvider>(context).themeType == ThemeType.light
          ? ThemeMode.light
          : ThemeMode.dark,
      home: FutureBuilder<bool>(
        future: AuthManager.isLoggedIn(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          final isLoggedIn = snapshot.data ?? false;
          if (isLoggedIn) {
            _initWebSocket(token);
            return const Home();
          } else {
            return LoginScreen(
              onLoginSuccess: () {
              _initWebSocket(token);
            }
            );
          }
        },
      ),
      routes: {
        // '/': (context) => const Home(),
        '/create-post':(context) => const CreatePost(),
      },
    );
  }
}
