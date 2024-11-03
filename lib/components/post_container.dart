import 'dart:io';
import 'package:borderless/api/api_service.dart';
import 'package:borderless/model/posts.dart';
import 'package:borderless/model/user_profile.dart';
import 'package:borderless/provider/user_profile_provider.dart';
import 'package:borderless/utils/format_date.dart';
import 'package:borderless/utils/gen_thumbnail.dart';
import 'package:borderless/utils/image_preview.dart';
import 'package:borderless/screens/posts/post_details.dart';
import 'package:borderless/utils/pixel_placeholder.dart';
import 'package:borderless/utils/snack_bar.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:chewie/chewie.dart';
import 'package:flutter/material.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:page_transition/page_transition.dart';
import 'package:provider/provider.dart';
import 'package:video_player/video_player.dart';

class PostContainer extends StatefulWidget {
  final Post post;

  const PostContainer({super.key, required this.post});

  @override
  State<PostContainer> createState() => _PostContainerState();
}

class _PostContainerState extends State<PostContainer>
    with AutomaticKeepAliveClientMixin {
  VideoPlayerController? videoPlayerController;
  ChewieController? chewieController;

  final Map<String, ChewieController> _chewieControllers = {};

  void _navigateToDetailPage(Post post) {
    Navigator.push(
      context,
      PageTransition(
        type: PageTransitionType.bottomToTop,
        child: PostDetails(post: post),
      ),
    );
  }

  void _deletePost(post) async {
    try {
      // Call API to delete post
      await ApiService.deletePost(context, post.id);
      // if (mounted) {
      //   Navigator.pop(context);
      // }
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

  @override
  void dispose() {
    videoPlayerController?.dispose();
    chewieController?.dispose();
    _chewieControllers.forEach((key, controller) => controller.dispose());
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    final userProfileProvider =
        Provider.of<UserProfileProvider>(context, listen: false);
    final UserProfile? userData = userProfileProvider.userProfile;

    final isLoggedInUser = widget.post.author['user_id'] == userData!.id;

    final customCacheManager = CacheManager(
      Config(
        'customCacheKey',
        stalePeriod: const Duration(days: 30),
        maxNrOfCacheObjects: 100,
      ),
    );

    return Padding(
      padding: const EdgeInsets.only(bottom: 7, top: 7, left: 15, right: 15),
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(15),
          color: Theme.of(context).colorScheme.primary,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              // ignore: prefer_const_literals_to_create_immutables
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
                                cacheManager: customCacheManager),
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
                                fontWeight: FontWeight.w700,
                              )),
                          // date created
                          Text(
                              DateFormatted()
                                  .formatTimestamp((widget.post.createdDate)),
                              style: TextStyle(color: Colors.grey[600])),
                        ],
                      ),
                    ),
                  ],
                ),
                // right dot icon
                // right dot icon,
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 15),
                  child: PopupMenuButton<String>(
                    itemBuilder: (BuildContext context) =>
                        <PopupMenuEntry<String>>[
                      PopupMenuItem<String>(
                        value: isLoggedInUser ? "delete" : "favorites",
                        child: Text(isLoggedInUser ? "刪除" : "收藏"),
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
                  ),
                )
              ],
            ),
            // caption
            Container(
              margin: const EdgeInsets.only(left: 8.0),
              child: Padding(
                padding: const EdgeInsets.only(left: 11, right: 11, bottom: 11),
                child: Text(
                  widget.post.content,
                  style: const TextStyle(fontSize: 15, fontFamily: 'Roboto'),
                ),
              ),
            ),
            // image post
            if (widget.post.postImages.isNotEmpty)
              Padding(
                padding: const EdgeInsets.all(5.0),
                child: Container(
                  margin: const EdgeInsets.only(left: 16.0),
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
                            errorWidget: (context, url, error) => const Center(
                              child: Icon(Icons.error),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
            if (widget.post.postVideo.isNotEmpty)
              Padding(
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
                      // final videoUrl = widget.post.postVideo[videoIndex].video;
                      // final videoPlayerController = VideoPlayerController.networkUrl(Uri.parse(videoUrl));
                      // final chewieController = ChewieController(
                      //   videoPlayerController: videoPlayerController,
                      //   autoPlay: false,
                      //   looping: false,
                      // );
                      // return Chewie(
                      //   controller: chewieController,
                      // );
                      final videoUrl = widget.post.postVideo[videoIndex].video;
                      final postId = widget.post.id;

                      return FutureBuilder<String>(
                        future: VideoThumbnailUtil.generateThumbnail(
                            videoUrl, postId),
                        builder: (context, snapshot) {
                          if (snapshot.connectionState ==
                              ConnectionState.waiting) {
                            return Container(
                              color: Colors.blueGrey,
                              child: const Center(
                                  child: CircularProgressIndicator()),
                            );
                          } else if (snapshot.hasError ||
                              !snapshot.hasData ||
                              snapshot.data!.isEmpty) {
                            return Container(
                              color: Colors.grey[200],
                              child: const Center(child: Icon(Icons.error)),
                            );
                          } else {
                            return GestureDetector(
                          onTap: () {
                            if (!_chewieControllers.containsKey(videoUrl)) {
                              final videoPlayerController = VideoPlayerController.networkUrl(Uri.parse(videoUrl));
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
                              Image.file(
                                File(snapshot.data!),
                                fit: BoxFit.cover,
                                width: double.infinity,
                                height: double.infinity,
                              ),
                              if (!_chewieControllers.containsKey(videoUrl) || !_chewieControllers[videoUrl]!.isPlaying)
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
                                Chewie(controller: _chewieControllers[videoUrl]!),
                            ],
                          ),
                        );
                          }
                        },
                      );
                    },
                  ),
                ),
              ),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 12.0),
              child: Divider(
                thickness: 0.05,
              ),
            ),
            // comment btn,
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                (widget.post.comments.isEmpty)
                    ? const Text('')
                    : Text(
                        widget.post.comments.length.toString(),
                        style: const TextStyle(color: Colors.grey),
                      ),
                IconButton(
                  onPressed: () {
                    _navigateToDetailPage(widget.post);
                  },
                  icon: const Icon(
                    Icons.chat_rounded,
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  @override
  bool get wantKeepAlive => true;
}
