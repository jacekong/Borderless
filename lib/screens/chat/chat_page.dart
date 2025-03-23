// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';
import 'dart:io';
import 'package:audioplayers/audioplayers.dart';
import 'package:borderless/utils/notification_manager.dart';
import 'package:cached_network_image/cached_network_image.dart';
// import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:logger/logger.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import 'package:borderless/api/api_service.dart';
import 'package:borderless/api/auth_manager.dart';
import 'package:borderless/api/websocket_api.dart';
import 'package:borderless/api/websocket_service.dart';
import 'package:borderless/model/user_profile.dart';
import 'package:borderless/provider/chat_history_provider.dart';
import 'package:borderless/provider/user_profile_provider.dart';
import 'package:borderless/utils/audio_controller.dart';
import 'package:borderless/utils/format_date.dart';
import 'package:borderless/utils/image_preview.dart';
import 'package:record/record.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class ChatPage extends StatefulWidget {
  final UserProfile friend;
  const ChatPage({
    super.key,
    required this.friend,
  });

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final TextEditingController _textEditingController = TextEditingController();
  late final List<Map<String, dynamic>> _messages = [];
  var logger = Logger();
  final ScrollController _scrollController = ScrollController();

  UserProfile? userData;

  final String? token = AuthManager.getAuthToken();
  late WebSocketService _webSocketService;

  bool temp = false;
  bool audio = false;
  bool isShowSticker = false;

  final FocusNode focusNode = FocusNode();
  late String recordFilePath;

  AudioController audioController = Get.put(AudioController());
  AudioPlayer audioPlayer = AudioPlayer();
  String audioURL = "";

  late bool isRecording;

  // pick image
  XFile? _image;
  final picker = ImagePicker();

  // DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();

  // audio recorder
  final recorder = AudioRecorder();

  Future<bool> checkPermission() async {
    if (!await Permission.microphone.isGranted) {
      PermissionStatus status = await Permission.microphone.request();
      if (status != PermissionStatus.granted) {
        return false;
      }
    }
    return true;
  }

  void startRecord() async {
    // bool hasPermission = await checkPermission();
    // if (hasPermission) {
    //   recordFilePath = await getFilePath();
    //   RecordMp3.instance.start(recordFilePath, (type) {
    //     setState(() {});
    //   });
    // } else {}
    // setState(() {});
    if (await recorder.hasPermission()) {
      recordFilePath = await getFilePath();
    
    // Start recording with a specific configuration
    await recorder.start(
      const RecordConfig(
        encoder: AudioEncoder.aacLc, // Choose the appropriate encoder
        bitRate: 128000, // Optional bit rate
        sampleRate: 44100, // Optional sample rate
      ),
      path: recordFilePath, // The file path where the recording will be saved
    );
    setState(() {});
  }
    setState(() {});
  }

  void stopRecord() async {
    // bool stop = RecordMp3.instance.stop();
    // audioController.end.value = DateTime.now();
    // audioController.calcDuration();
    // var ap = AudioPlayer();
    // await ap.play(AssetSource("sound2.mp3"));
    // ap.onPlayerComplete.listen((a) {});
    // if (stop) {
    //   audioController.isRecording.value = false;
    //   audioController.isSending.value = true;
    //   await uploadAudio();
    //   setState(() {});
    // }
    final path = await recorder.stop();
    audioController.end.value = DateTime.now();
    audioController.calcDuration();
    var ap = AudioPlayer();
    await ap.play(AssetSource("sound2.mp3"));
    ap.onPlayerComplete.listen((a) {});

    if (path != null) {
      audioController.isRecording.value = false;
      audioController.isSending.value = true;
      await uploadAudio();
      setState(() {});
    }
  }

  int i = 0;

  Future<String> getFilePath() async {
    Directory storageDirectory = await getApplicationDocumentsDirectory();
    String sdPath =
        "${storageDirectory.path}/record${DateTime.now().microsecondsSinceEpoch}.acc";
    var d = Directory(sdPath);
    if (!d.existsSync()) {
      d.createSync(recursive: true);
    }
    return "$sdPath/test_${i++}.mp3";
  }

  @override
  void initState() {
    _initWebSocket();
    _initChatHistory();
    _initImageChatHistory();
    _initAudioChatHistory();
    focusNode.addListener(onFocusChange);
    _initializeUserData();
    userData;
    NotificationManager.saveUserId(widget.friend.id);
    // Schedule the initialization of ChatHistoryProvider after the build phase
    Future.delayed(Duration.zero, () {
      Provider.of<ChatHistoryProvider>(context, listen: false);
      // Now you can use chatHistoryProvider to interact with the provider
    });
    super.initState();
  }

  Future<void> _initializeUserData() async {
    userData = await Provider.of<UserProfileProvider>(context, listen: false)
        .fetchCurrentUser();
    setState(() {}); // Trigger a rebuild after userData is initialized
  }

  void _initChatHistory() async {
    try {
      // Fetch chat history
      // final chatHistory = await ApiService.getUserChatHistory(widget.friend.id);
      final chatHistoryProvider =
          Provider.of<ChatHistoryProvider>(context, listen: false);
      // Fetch chat history
      await chatHistoryProvider.fetchChatMessages(widget.friend.id);

      // Add chat history messages to _messages list
      setState(() {
        _messages.addAll(chatHistoryProvider.chatMessages.map((chatMessage) => {
              'message': chatMessage.message,
              'sender': chatMessage.sender.id,
              'timestamp': chatMessage.timestamp,
            }));
      });
    } catch (e) {
      logger.e('Failed to fetch chat history: $e');
    }
  }

  void _initImageChatHistory() async {
    try {
      // Fetch chat history
      // final chatHistory = await ApiService.getUserChatHistory(widget.friend.id);
      final chatHistoryProvider =
          Provider.of<ChatHistoryProvider>(context, listen: false);
      // Fetch chat history
      await chatHistoryProvider.fetchImageMessages(widget.friend.id);

      // Add chat history messages to _messages list
      setState(() {
        _messages
            .addAll(chatHistoryProvider.imageMessages.map((chatMessage) => {
                  'images': chatMessage.images,
                  'sender': chatMessage.sender.id,
                  'timestamp': chatMessage.timestamp,
                  'message_type': 'image'
                }));
      });
    } catch (e) {
      logger.e('Failed to fetch chat history: $e');
    }
  }

  void _initAudioChatHistory() async {
    try {
      // Fetch chat history
      final chatHistoryProvider =
          Provider.of<ChatHistoryProvider>(context, listen: false);
      // Fetch chat history
      await chatHistoryProvider.fetchAudioMessages(widget.friend.id);

      // Add chat history messages to _messages list
      setState(() {
        _messages
            .addAll(chatHistoryProvider.audioMessages.map((chatMessage) => {
                  'audio': chatMessage.audio,
                  'sender': chatMessage.sender.id,
                  'duration': chatMessage.duration,
                  'timestamp': chatMessage.timestamp,
                  'message_type': 'audio'
                }));
      });
    } catch (e) {
      logger.e('Failed to fetch chat history: $e');
    }
  }

  void _initWebSocket() {
    final wsUrl = '${WebsocketApi.wsUrl}ws/chat/${widget.friend.id}/';
    _webSocketService = WebSocketService(
      wsUrl: wsUrl,
      token: token,
      onMessageReceived: _handleMessageReceived,
      onError: _handleError,
      onDone: _handleWebSocketDone,
    );
    _webSocketService.initWebSocket();
  }

  // receive messages from websockets
  void _handleMessageReceived(Map<String, dynamic> message) async {
    // get message type
    final messageType = message['message_type'];
    final senderId = message['sender'];
    final timestamp = message['timestamp'];

    if (messageType == 'text') {
      final textMessage = message['message'];
      final senderId = message['sender'];
      setState(() {
        _messages.add({
          'message': textMessage,
          'sender': senderId,
          'timestamp': timestamp,
          'message_type': 'text',
        });
      });
    } else if (messageType == 'audio') {
      String audioFile = message['audio'];
      // print('----------------audio file: $audioFile-----------------');
      final duration = message['duration'];
      setState(() {
        _messages.add({
          'audio': audioFile,
          'sender': senderId,
          'duration': duration,
          'timestamp': timestamp,
          'message_type': 'audio',
        });
      });
    } else if (messageType == 'image') {
      String imageUrl = message['images'];
      setState(() {
        _messages.add({
          'images': imageUrl,
          'sender': senderId,
          'timestamp': timestamp,
          'message_type': 'image',
        });
      });
    }
    // // sort mesages by timestamp
    // _messages.sort((a, b) => a['timestamp'].compareTo(b['timestamp']));
  }

  void _handleError(dynamic error) {
    logger.e(error);
  }

  void _handleWebSocketDone() {
    logger.d('WebSocket connection closed');
  }

  // send voice message
  uploadAudio() async {
    File audioFile = File(recordFilePath);
    List<int> audioBytes = await audioFile.readAsBytes();
    final duration = audioController.total;
    var timestamp = DateTime.now().toString();

    try {
      final messageData = {
        'audio': audioBytes,
        'sender': userData!.id,
        'duration': duration,
        'timestamp': timestamp,
        'message_type': 'audio'
      };

      final encodedMessage = jsonEncode(messageData);

      _webSocketService.sendAudioMessage(encodedMessage);
    } catch (e) {
      setState(() {
        audioController.isSending.value = false;
      });
      Fluttertoast.showToast(msg: e.toString());
    }
  }

  // send text messages
  void _sendMessage(sender, messageType) {
    var timestamp = DateTime.now().toString();
    final message = _textEditingController.text.trim();
    if (message.isNotEmpty) {
      final messageData = {
        'message': message,
        'sender': sender,
        'message_type': messageType,
        'timestamp': timestamp
      };
      _webSocketService.sendMessage(jsonEncode(messageData));
      _textEditingController.clear();
    }
  }

  void onFocusChange() {
    if (focusNode.hasFocus) {
      // Hide sticker when keyboard appear
      setState(() {
        isShowSticker = false;
      });
    }
  }

  Future<bool> checkPhotosPermission() async {
    if (!await Permission.photos.isGranted) {
      PermissionStatus status = await Permission.photos.request();
      if (status != PermissionStatus.granted) {
        return false;
      }
    }
    return true;
  }

  // open phone's gallery
  void openGallery() async {
    // var timestamp = DateTime.now().toString();
    // bool hasPermission = await checkPhotosPermission();
    // if (hasPermission) {
      final image = await picker.pickImage(source: ImageSource.gallery);
      // if image is not null
      if (image != null) {
        setState(() {
          _image = XFile(image.path);
          // _messages.add({
          //   'images': _image,
          //   'sender': userData!.id,
          //   'timestamp': timestamp,
          //   'message_type': 'image'
          // });
        });
        sendCahtImage();
      } else {
        return;
      }
    // }
    return;
  }

  // send image in chat
  void sendCahtImage() async {
    // Implement logic to send the selected image
    if (_image != null) {
      // Image is selected, implement logic to send it
      await ApiService.sendImageMessage(context, widget.friend.id, _image);
    } else {
      // No image selected, handle accordingly
      return;
    }
  }

  @override
  void dispose() {
    _textEditingController.dispose();
    _webSocketService.closeWebSocket();
    audioPlayer.dispose();
    recorder.dispose();
    NotificationManager.removeUserId();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final userProfileProvider = Provider.of<UserProfileProvider>(context);
    final UserProfile? userData = userProfileProvider.userProfile;

    double screenWidth = MediaQuery.of(context).size.width;

    // _messages.sort((a, b) => a['timestamp'].compareTo(b['timestamp']));

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            // avatart,
            CircleAvatar(
              radius: 20,
              backgroundImage:
                  NetworkImage(widget.friend.avatar), // Use NetworkImage
            ),
            // cloumn,
            // 1. username,
            // 2. id,
            const SizedBox(
              width: 15,
            ),
            Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 1. username,
                Text(
                  widget.friend.username,
                  style: const TextStyle(fontSize: 20),
                ),
                // 2. id,
                Text(
                  '@${widget.friend.id}',
                  style: TextStyle(fontSize: 12, color: Colors.grey[500]),
                ),
              ],
            )
          ],
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              reverse: true,
              controller: _scrollController,
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                _messages.sort((a, b) => DateTime.parse(a['timestamp'])
                    .compareTo(DateTime.parse(b['timestamp'])));
                // reverse the index of the list
                final reversedIndex = _messages.length - 1 - index;
                final message = _messages[reversedIndex];
                final senderId = message['sender'];
                final isLoggedUserMessage = senderId == userData!.id;

                // _messages.sort((a, b) => a['timestamp'].compareTo(b['timestamp']));

                if (message['message_type'] == 'audio') {
                  // Render audio widget
                  return Align(
                    alignment: isLoggedUserMessage
                        ? Alignment.centerRight
                        : Alignment.centerLeft,
                    child: isLoggedUserMessage ? Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(bottom: 8.0),
                          child: Text(
                            DateFormatted().formatTimestamp(message['timestamp']),
                            style: const TextStyle(
                              color: Colors.grey,
                              fontSize: 7,
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: _audio(
                            message: message['audio'],
                            index: index,
                            // time: DateTime.parse(message['timestamp']),
                            isCurrentUser: isLoggedUserMessage,
                            duration: message['duration'],
                          ),
                        ),
                      
                      ],
                    ) : Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          CircleAvatar(
                                  radius: 20,
                                  backgroundImage: NetworkImage(
                                      widget.friend.avatar), // Use NetworkImage
                                ),
                                // const SizedBox(
                                //   width: 7,
                                // ),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: _audio(
                              message: message['audio'],
                              index: index,
                              // time: DateTime.parse(message['timestamp']),
                              isCurrentUser: isLoggedUserMessage,
                              duration: message['duration'],
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(bottom:8.0),
                            child: Text(
                              DateFormatted().formatTimestamp(message['timestamp']),
                              style: const TextStyle(
                                color: Colors.grey,
                                fontSize: 7,
                              ),
                            ),
                          ),
                            ],
                          )
                        ],
                      ),
                    ),
                  );
                } else if (message['message_type'] == 'image') {
                  return Align(
                    alignment: isLoggedUserMessage
                        ? Alignment.centerRight
                        : Alignment.centerLeft,
                    child: isLoggedUserMessage
                        ? Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Padding(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 8.0),
                                child: Text(
                                  DateFormatted()
                                      .formatTimestamp(message['timestamp']),
                                  style: const TextStyle(
                                    color: Colors.grey,
                                    fontSize: 7,
                                  ),
                                ),
                              ),
                              Padding(
                                padding:
                                    const EdgeInsets.only(right: 10, bottom: 7, top:5),
                                child: SizedBox(
                                  width: 150,
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(15),
                                    child: _buildImageWidget(
                                        context, message['images']),
                                  ),
                                ),
                              ),
                              const SizedBox(
                                height: 5,
                              ),
                            ],
                          )
                        : Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                CircleAvatar(
                                  radius: 20,
                                  backgroundImage: NetworkImage(
                                      widget.friend.avatar), // Use NetworkImage
                                ),
                                // const SizedBox(
                                //   width: 7,
                                // ),
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.only(
                                              left: 10, bottom: 7, top:5),
                                      child: SizedBox(
                                        width: 150,
                                        child: ClipRRect(
                                          borderRadius: BorderRadius.circular(15),
                                          child: _buildImageWidget(
                                              context, message['images']),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(
                                      height: 5,
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 8.0),
                                      child: Text(
                                        DateFormatted().formatTimestamp(
                                            message['timestamp']),
                                        style: const TextStyle(
                                          color: Colors.grey,
                                          fontSize: 7,
                                        ),
                                      ),
                                    ),
                                  ],
                                )
                              ],
                            ),
                        ),
                  );
                } else {
                  return BuildTextMessageWidget(
                      isLoggedUserMessage: isLoggedUserMessage,
                      widget: widget,
                      screenWidth: screenWidth,
                      message: message);
                }
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Container(
              padding: const EdgeInsets.only(left: 5),
              decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(20)),
              child: Row(
                children: [
                  IconButton(
                    onPressed: () {
                      openGallery();
                    },
                    icon: Icon(Icons.photo, color: Colors.grey[700]),
                  ),
                  GestureDetector(
                    child: const Icon(Icons.mic, color: Colors.blue),
                    onLongPress: () async {
                      var audioPlayer = AudioPlayer();
                      await audioPlayer.play(AssetSource("sound2.mp3"));
                      audioPlayer.onPlayerComplete.listen((a) {
                        audioController.start.value = DateTime.now();
                        startRecord();
                        audioController.isRecording.value = true;
                      });
                    },
                    onLongPressEnd: (details) {
                      stopRecord();
                    },
                  ),
                  const SizedBox(
                    width: 10,
                  ),
                  // send message
                  Expanded(
                    child: TextField(
                      focusNode: focusNode,
                      cursorColor: Colors.black,
                      maxLines: null,
                      controller: _textEditingController,
                      style: const TextStyle(color: Colors.black),
                      decoration: InputDecoration(
                          focusColor: Theme.of(context).colorScheme.secondary,
                          hoverColor: Theme.of(context).colorScheme.secondary,
                          border: InputBorder.none,
                          hintText: audioController.isRecording.value
                              ? "正在錄音..."
                              : AppLocalizations.of(context)!.typeMessage,
                          hintStyle: const TextStyle(color: Colors.black)),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(
                      Icons.send,
                      color: Colors.blue,
                    ),
                    onPressed: () {
                      _sendMessage(userData!.id, 'text');
                    },
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildImageWidget(context, String imageUrl) {
    // cache image mesage
    final customCacheManager = CacheManager(
      Config(
        'customCacheKey',
        stalePeriod: const Duration(days: 30),
        maxNrOfCacheObjects: 100,
      ),
    );

    return GestureDetector(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => FullScreenImage(imageUrl: imageUrl)),
          );
        },
        child: CachedNetworkImage(
          memCacheWidth: 300,
          imageUrl: imageUrl,
          fadeInCurve: Curves.linear,
          cacheManager: customCacheManager,
          fadeInDuration: const Duration(microseconds: 300),
        ));
  }

  Widget _audio({
    required String message,
    required int index,
    // required String time,
    required String duration,
    required bool isCurrentUser,
  }) {
    return Container(
      width: MediaQuery.of(context).size.width * 0.5,
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: isCurrentUser ? Colors.blue : Colors.grey[300],
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          GestureDetector(
            onTap: () {
              audioController.onPressedPlayButton(index, message);
              // changeProg(duration: duration);
            },
            onSecondaryTap: () {
              audioPlayer.stop();
              audioController.completedPercentage.value = 0.0;
            },
            child: Obx(
              () => (audioController.isRecordPlaying &&
                      audioController.currentId == index)
                  ? Icon(
                      Icons.cancel,
                      color: isCurrentUser ? Colors.white : Colors.pink,
                    )
                  : Icon(
                      Icons.play_arrow,
                      color: isCurrentUser ? Colors.white : Colors.pink,
                    ),
            ),
          ),
          Obx(
            () => Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 0),
                child: Stack(
                  clipBehavior: Clip.none,
                  alignment: Alignment.center,
                  children: [
                    LinearProgressIndicator(
                        minHeight: 5,
                        backgroundColor: Colors.grey,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          isCurrentUser ? Colors.white : Colors.pink,
                        ),
                        value: (audioController.isRecordPlaying &&
                                audioController.currentId == index)
                            ? audioController.completedPercentage.value
                            : audioController.totalDuration.value.toDouble()),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(
            width: 10,
          ),
          Text(
            duration,
            style: TextStyle(
                fontSize: 12,
                color: isCurrentUser ? Colors.white : Colors.grey),
          ),
        ],
      ),
    );
  }
}

class BuildTextMessageWidget extends StatelessWidget {
  const BuildTextMessageWidget({
    super.key,
    required this.isLoggedUserMessage,
    required this.widget,
    required this.screenWidth,
    required this.message,
  });

  final bool isLoggedUserMessage;
  final ChatPage widget;
  final double screenWidth;
  final Map<String, dynamic> message;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment:
          isLoggedUserMessage ? Alignment.centerRight : Alignment.centerLeft,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Container(
          margin: isLoggedUserMessage
              ? EdgeInsets.only(left: screenWidth * 0.3)
              : EdgeInsets.only(right: screenWidth * 0.3),
          child: isLoggedUserMessage
              ? Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      DateFormatted().formatTimestamp(message['timestamp']),
                      style: const TextStyle(
                        color: Colors.grey,
                        fontSize: 7,
                      ),
                    ),
                    Flexible(
                      child: Container(
                        margin: const EdgeInsets.only(left: 5),
                        padding: const EdgeInsets.symmetric(
                            vertical: 13, horizontal: 10),
                        decoration: BoxDecoration(
                            color: Colors.blue,
                            borderRadius: BorderRadius.circular(15)),
                        child: SelectableText(
                          message['message'],
                          style: const TextStyle(color: Colors.white),
                          cursorColor: Theme.of(context).colorScheme.secondary,
                          maxLines: null,
                        ),
                      ),
                    ),
                  ],
                )
              : Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    CircleAvatar(
                      radius: 20,
                      backgroundImage: NetworkImage(
                          widget.friend.avatar), // Use NetworkImage
                    ),
                    const SizedBox(
                      width: 7,
                    ),
                    Flexible(
                      child: Container(
                        margin: const EdgeInsets.only(right: 5),
                        padding: const EdgeInsets.symmetric(
                            vertical: 13, horizontal: 10),
                        decoration: BoxDecoration(
                            color: Colors.grey[300],
                            borderRadius: BorderRadius.circular(15)),
                        child: SelectableText(
                          message['message'],
                          style: const TextStyle(color: Colors.black),
                          cursorColor: Theme.of(context).colorScheme.secondary,
                          maxLines: null,
                        ),
                      ),
                    ),
                    Text(
                      DateFormatted().formatTimestamp(message['timestamp']),
                      style: const TextStyle(
                        color: Colors.grey,
                        fontSize: 7,
                      ),
                    ),
                  ],
                ),
        ),
      ),
    );
  }
}
