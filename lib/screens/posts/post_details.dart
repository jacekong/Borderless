import 'dart:convert';
import 'dart:io';
import 'package:borderless/api/api_service.dart';
import 'package:borderless/api/auth_manager.dart';
import 'package:borderless/api/websocket_api.dart';
import 'package:borderless/api/websocket_service.dart';
import 'package:borderless/components/reply_comment.dart';
import 'package:borderless/components/reply_to_user.dart';
import 'package:borderless/model/posts.dart';
import 'package:borderless/model/user_profile.dart';
import 'package:borderless/provider/user_profile_provider.dart';
import 'package:borderless/utils/expandable_text.dart';
import 'package:borderless/utils/gen_thumbnail.dart';
import 'package:borderless/utils/image_preview.dart';
import 'package:borderless/utils/format_date.dart';
import 'package:borderless/utils/pixel_placeholder.dart';
import 'package:borderless/utils/snack_bar.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:chewie/chewie.dart';
import 'package:flutter/material.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:logger/logger.dart';
import 'package:video_player/video_player.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class PostDetails extends StatefulWidget {
  final Post post;

  const PostDetails({super.key, required this.post});

  @override
  State<PostDetails> createState() => _PostDetailsState();
}

class _PostDetailsState extends State<PostDetails> {
  late final List<Map<String, dynamic>> _comments = [];
  final TextEditingController _textEditingController = TextEditingController();
  late WebSocketService _webSocketService;
  var logger = Logger();

  VideoPlayerController? videoPlayerController;
  ChewieController? chewieController;

  final Map<String, ChewieController> _chewieControllers = {};

  final String? token = AuthManager.getAuthToken();

  @override
  void initState() {
    _initWebSocket();
    _initCommentHistory();
    context.read<UserProfileProvider>().fetchCurrentUser();
    super.initState();
  }

  void _initCommentHistory() async {
    try {
      // Fetch chat history
      final commentsHistory = await ApiService.getPostComments(widget.post.id);

      setState(() {
        _comments.addAll(commentsHistory.map((comment) => {
              'comment': comment.comment,
              'avatar': comment.sender.avatar,
              'timestamp': comment.timestamp,
              'parent': comment.parent,
              'sender': comment.sender.username,
              'id': comment.id,
            }));
      });
    } catch (e) {
      logger.e('Failed to fetch chat history: $e');
    }
  }

  void _initWebSocket() {
    final wsUrl = '${WebsocketApi.wsUrl}ws/post/comments/${widget.post.id}/';
    _webSocketService = WebSocketService(
      wsUrl: wsUrl,
      token: token,
      onMessageReceived: _handleCommentsReceived,
      onError: _handleError,
      onDone: _handleWebSocketDone,
    );
    _webSocketService.initWebSocket();
  }

  void _handleCommentsReceived(Map<String, dynamic> message) {
    // final username = context.read<UserProfile>().username;
    // final avatar = context.read<UserProfile>().avatar;
    // final user_id = context.read<UserProfile>().id;

    setState(() {
      _comments.add({
        'comment': message['comment'],
        'sender': message['sender'],
        'avatar': message['avatar'],
        'timestamp': message['timestamp'],
        'parent': message['parent'],
        'id': message['id'],
      });
    });
  }

  void _handleError(dynamic error) {
    logger.e(error);
  }

  void _handleWebSocketDone() {
    logger.d('WebSocket connection closed');
  }

  void _sendMessage(String message, int? parentId) {
    // final message = _textEditingController.text.trim();
    if (message.isNotEmpty) {
      final messageData = {
        'comment': message,
        'parent': parentId
      };
      _webSocketService.sendMessage(jsonEncode(messageData));
      _textEditingController.clear();
    }
  }

  void _deletePost(post) async {
    try {
      // Call API to delete post
      await ApiService.deletePost(context, post.id);
    } catch (e) {
      // Handle error
      if (mounted) {
        CustomSnackbar.show(
          context: context,
          message: '$e',
          backgroundColor: Colors.red,
        );
      }
    }
  }

  String formatDate(String dateString) {
    final dateTime = DateTime.parse(dateString);
    final formatter = DateFormat('dd MMM, yyyy HH:mm');
    return formatter.format(dateTime.toLocal());
  }

  @override
  void dispose() {
    _textEditingController.dispose();
    _webSocketService.closeWebSocket();
    videoPlayerController?.dispose();
    chewieController?.dispose();
    _chewieControllers.forEach((key, controller) => controller.dispose());
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final userProfileProvider = Provider.of<UserProfileProvider>(context);
    final UserProfile? userData = userProfileProvider.userProfile;

    final isLoggedInUser = widget.post.author['user_id'] == userData!.id;

    final customCacheManager = CacheManager(
      Config(
        'customCacheKey',
        stalePeriod: const Duration(days: 10),
        maxNrOfCacheObjects: 100,
      ),
    );

    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.post),
      ),
      body: GestureDetector(
        onTap: () => FocusScope.of(context).requestFocus(FocusNode()),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    //avatar
                    Padding(
                      padding:
                          const EdgeInsets.only(top: 11, left: 11, bottom: 11),
                      child: CircleAvatar(
                        radius: 26,
                        child: Container(
                          height: 150,
                          width: 150,
                          decoration: const BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.blueGrey,
                          ),
                          child: CircleAvatar(
                            backgroundImage: CachedNetworkImageProvider(
                              widget.post.author['avatar'],
                            ),
                          ),
                        ),
                      ),
                    ),
                    // name and date
                    Padding(
                      padding: const EdgeInsets.only(left: 7),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        // ignore: prefer_const_literals_to_create_immutables
                        children: [
                          //name
                          // ignore: prefer_const_constructors
                          Text(widget.post.author['username'],
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                              )),
                          // date created
                          Text(formatDate(widget.post.createdDate),
                              style: TextStyle(color: Colors.grey[600])),
                        ],
                      ),
                    ),
                  ],
                ),
                // right dot icon,
                PopupMenuButton<String>(
                  itemBuilder: (BuildContext context) =>
                      <PopupMenuEntry<String>>[
                    PopupMenuItem<String>(
                      value: isLoggedInUser ? "delete" : "favorites",
                      child: Text(isLoggedInUser
                          ? AppLocalizations.of(context)!.delete
                          : "收藏"),
                    ),
                  ],
                  onSelected: (String value) {
                    // Handle menu item selection here
                    switch (value) {
                      case 'delete':
                        _deletePost(widget.post);
                        break;
                      case 'favorites':
                        '';
                    }
                  },
                  child: const Icon(Icons.more_vert),
                )
              ],
            ),
            // caption
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 8),
              child: Padding(
                padding: const EdgeInsets.only(left: 11, right: 11, bottom: 3),
                child: Text(
                  widget.post.content,
                  style: const TextStyle(fontSize: 15, fontFamily: 'Roboto'),
                ),
              ),
            ),
            // image post
            if (widget.post.postImages.isNotEmpty)
              Expanded(
                flex: 1,
                child: Padding(
                  padding: const EdgeInsets.all(5.0),
                  child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: GridView.builder(
                      cacheExtent: 9999,
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 3,
                        mainAxisSpacing: 4.0,
                        crossAxisSpacing: 4.0,
                      ),
                      itemCount: widget.post.postImages.length,
                      itemBuilder: (context, imageIndex) {
                        final imageUrl =
                            widget.post.postImages[imageIndex].images;
                        return GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => ImagePreview(
                                  imageUrls: widget.post.postImages
                                      .map((image) => image.images)
                                      .toList(),
                                  initialIndex: imageIndex,
                                ),
                              ),
                            );
                          },
                          child: Hero(
                            tag: imageUrl,
                            child: CachedNetworkImage(
                              // memCacheHeight: 200,
                              memCacheWidth: 200,
                              cacheManager: customCacheManager,
                              key: UniqueKey(),
                              imageUrl: imageUrl,
                              fit: BoxFit.cover,
                              placeholder: (context, url) => Center(
                                child: Container(
                                    color: Colors.blueGrey[500],
                                    child: const PixelPlaceholder()),
                              ), // Placeholder widget while loading
                              errorWidget: (context, url, error) =>
                                  const Center(
                                child: Icon(Icons.error),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ),
            // video,
            if (widget.post.postVideo.isNotEmpty)
              Expanded(
                flex: 1,
                child: Padding(
                  padding: const EdgeInsets.all(5.0),
                  child: Container(
                    margin: const EdgeInsets.only(left: 16.0, right: 16.0),
                    child: GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 1,
                        mainAxisSpacing: 4.0,
                        crossAxisSpacing: 4.0,
                      ),
                      itemCount: widget.post.postVideo.length,
                      itemBuilder: (context, videoIndex) {
                        final videoUrl =
                            widget.post.postVideo[videoIndex].video;
                        // final postId = widget.post.id;
                        // final videoPlayerController =
                        //     VideoPlayerController.networkUrl(Uri.parse(videoUrl));
                        // final chewieController = ChewieController(
                        //   videoPlayerController: videoPlayerController,
                        //   autoPlay: false,
                        //   looping: false,
                        // );
                        // return Chewie(
                        //   controller: chewieController,
                        // );
                        return GestureDetector(
                          onTap: () {
                            if (!_chewieControllers.containsKey(videoUrl)) {
                              final videoPlayerController =
                                  VideoPlayerController.networkUrl(
                                      Uri.parse(videoUrl));
                              final chewieController = ChewieController(
                                videoPlayerController: videoPlayerController,
                                autoPlay: false,
                                looping: false,
                              );

                              setState(() {
                                _chewieControllers[videoUrl] = chewieController;
                              });
                            } else {
                              setState(() {
                                _chewieControllers[videoUrl]!.play();
                              });
                            }
                          },
                          child: Stack(
                            children: [
                              // Image.file(
                              //   File(snapshot.data!),
                              //   fit: BoxFit.cover,
                              //   width: double.infinity,
                              //   height: double.infinity,
                              // ),
                              if (!_chewieControllers.containsKey(videoUrl) ||
                                  !_chewieControllers[videoUrl]!.isPlaying)
                                Positioned(
                                  top: 0,
                                  left: 0,
                                  right: 0,
                                  bottom: 0,
                                  child: Container(
                                    color: Colors.black.withOpacity(0.3),
                                    child: const Center(
                                      child: Icon(
                                        Icons.play_arrow,
                                        color: Colors.white,
                                        size: 50,
                                      ),
                                    ),
                                  ),
                                ),
                              if (_chewieControllers.containsKey(videoUrl))
                                Chewie(
                                    controller: _chewieControllers[videoUrl]!),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ),
            Align(
              alignment: Alignment.bottomRight,
              child: IconButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ReplyComment(
                        originalPost: {
                          'avatar': widget.post.author['avatar'],
                          'username': widget.post.author['username'],
                          'content': widget.post.content,
                          'id': ''
                        },
                        sendMessage: (message) {
                          _sendMessage(message, null);
                        },
                      ),
                    ),
                  );
                },
                icon: Image.asset(
                  'assets/icons/comment.png',
                  width: 24,
                  height: 24,
                  color: Theme.of(context).secondaryHeaderColor,
                ),
              ),
            ),
            // Comments section,
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 12.0),
              child: Divider(
                thickness: 0.1,
              ),
            ),
            Expanded(
              flex: 2,
              child: ListView.builder(
                itemCount: _comments.length,
                itemBuilder: (context, index) {
                  final comment = _comments[index];
                  // return ListTile(
                  //   titleAlignment: ListTileTitleAlignment.top,
                  //   leading: CircleAvatar(
                  //     radius: 20,
                  //     backgroundImage: NetworkImage(comment['avatar']),
                  //   ),
                  //   title: Padding(
                  //     padding: const EdgeInsets.only(bottom: 3),
                  //     child: Text(comment['sender'],
                  //         style: const TextStyle(
                  //             fontSize: 14, fontWeight: FontWeight.w600)),
                  //   ),
                  //   subtitle: Column(
                  //     crossAxisAlignment: CrossAxisAlignment.start,
                  //     children: [
                  //       ExpandableText(text: comment['comment']),
                  //       Row(
                  //         mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  //         children: [
                  //           TextButton(
                  //               onPressed: () {
                  //                 // Navigate to ReplyComment page and pass data
                  //                 Navigator.push(
                  //                   context,
                  //                   MaterialPageRoute(
                  //                     builder: (context) => ReplyToUser(
                  //                       replyTo: {
                  //                         'avatar': comment['avatar'],
                  //                         'username': comment['sender'],
                  //                         'comment': comment['comment'],
                  //                         'id': comment['id'],
                  //                       },
                  //                       sendComment: (message, id) {
                  //                         _sendMessage(message, id);
                  //                       },
                  //                     ),
                  //                   ),
                  //                 );
                  //               },
                  //               child: const Text(
                  //                 'reply',
                  //                 style: TextStyle(color: Colors.blue),
                  //               )),
                  //           Align(
                  //             alignment: Alignment.bottomRight,
                  //             child: Text(
                  //               DateFormatted()
                  //                   .formatTimestamp(comment['timestamp']),
                  //               style: TextStyle(
                  //                   color: Colors.grey[400], fontSize: 10),
                  //             ),
                  //           ),
                  //         ],
                  //       ),
                  //     ],
                  //   ),
                  // );
                  return ListTile(
  titleAlignment: ListTileTitleAlignment.top,
  leading: CircleAvatar(
    radius: 20,
    backgroundImage: NetworkImage(comment['avatar']),
  ),
  title: Padding(
    padding: const EdgeInsets.only(bottom: 3),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (comment['parent'] != null) // Check if the comment is a reply
          RichText(
            text: TextSpan(
              style: const TextStyle(fontSize: 12, color: Colors.grey),
              children: [
                const TextSpan(text: 'Reply to '),
                TextSpan(
                  text: comment['parent_username'], // Add parent's username here
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
        Text(
          comment['sender'],
          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
        ),
      ],
    ),
  ),
  subtitle: Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      ExpandableText(text: comment['comment']),
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          TextButton(
            onPressed: () {
              // Navigate to ReplyComment page and pass data
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ReplyToUser(
                    replyTo: {
                      'avatar': comment['avatar'],
                      'username': comment['sender'],
                      'comment': comment['comment'],
                      'id': comment['id'],
                    },
                    sendComment: (message, id) {
                      _sendMessage(message, id);
                    },
                  ),
                ),
              );
            },
            child: const Text(
              'reply',
              style: TextStyle(color: Colors.blue),
            ),
          ),
          Align(
            alignment: Alignment.bottomRight,
            child: Text(
              DateFormatted().formatTimestamp(comment['timestamp']),
              style: TextStyle(color: Colors.grey[400], fontSize: 10),
            ),
          ),
        ],
      ),
    ],
  ),
);

                },
              ),
            ),
            // btn send,
          ],
        ),
      ),
    );
  }
}
