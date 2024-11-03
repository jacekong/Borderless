// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:io';
import 'package:borderless/utils/gen_thumbnail.dart';
import 'package:borderless/utils/page_animation.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:page_transition/page_transition.dart';
import 'package:provider/provider.dart';
import 'package:borderless/api/api_service.dart';
import 'package:borderless/api/auth_manager.dart';
import 'package:borderless/components/account_drawer.dart';
import 'package:borderless/model/posts.dart';
import 'package:borderless/model/user_profile.dart';
import 'package:borderless/provider/user_profile_provider.dart';
import 'package:borderless/screens/posts/post_details.dart';
import 'package:borderless/utils/pixel_placeholder.dart';

class Settings extends StatefulWidget {
  const Settings({
    super.key,
  });

  @override
  State<Settings> createState() => _SettingsState();
}

class _SettingsState extends State<Settings>
    with AutomaticKeepAliveClientMixin {
  late Future<List<Post>> _posts;
  final String? authToken = AuthManager.getAuthToken();

  @override
  void initState() {
    super.initState();
    _posts = ApiService.fetchLoggedInUserPosts();
    Provider.of<UserProfileProvider>(context, listen: false).fetchCurrentUser();
  }

  Future<void> _refreshPosts() async {
    setState(() {
      _posts = ApiService.fetchLoggedInUserPosts();
      Provider.of<UserProfileProvider>(context, listen: false)
          .fetchCurrentUser();
    });
  }

  void _navigateToDetailPage(Post post) {
    Navigator.push(
      context,
      PageTransition(
        type: PageTransitionType.bottomToTop,
        child: PostDetails(post: post),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      appBar: AppBar(
        title: const Text(
          "我的帳戶",
          style: TextStyle(fontSize: 19),
        ),
      ),
      body: RefreshIndicator(
        color: Colors.green,
        onRefresh: () async {
          await _refreshPosts();
        },
        child: Consumer<UserProfileProvider>(
            builder: (context, userProfileProvider, _) {
          final UserProfile? userProfile = userProfileProvider.userProfile;
          if (userProfile != null) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // column with username and id,
                        // 1. username,
                        Padding(
                          padding:
                              const EdgeInsets.only(left: 20.0, bottom: 7.0),
                          child: Text(
                            userProfile.username,
                            style: TextStyle(
                                color: Theme.of(context).colorScheme.secondary,
                                fontSize: 20,
                                fontWeight: FontWeight.normal),
                          ),
                        ),
                        // 2. id,
                        Padding(
                          padding: const EdgeInsets.only(left: 20.0),
                          child: Text(
                            '@${userProfile.id}',
                            style: const TextStyle(
                                color: Colors.grey,
                                fontSize: 12,
                                fontWeight: FontWeight.w500),
                          ),
                        ),
                      ],
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: CircleAvatar(
                        radius: 30,
                        backgroundImage: NetworkImage(
                            userProfile.avatar), // Use NetworkImage
                      ),
                    ),
                  ],
                ),
                const SizedBox(
                  height: 15,
                ),
                // bio,
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Text("Bio: ${userProfile.bio}"),
                ),
                // edit profile,
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.of(context)
                          .push(PageAnimation.craeteUpdateProfileRoute());
                    },
                    child: Text(
                      "更新資料",
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.secondary,
                      ),
                    ),
                  ),
                ),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 12.0),
                  child: Divider(
                    thickness: 0.1,
                  ),
                ),
                FutureBuilder<List<Post>>(
                  future: _posts,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Expanded(
                        child: Center(
                            child: SpinKitCircle(
                          color: Colors.green,
                        )),
                      );
                    } else if (snapshot.hasError) {
                      return Center(
                          child:
                              Text('Error fetching posts: ${snapshot.error}'));
                    } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                      return Expanded(
                        child: GestureDetector(
                          onTap: () => _refreshPosts(),
                          child: const Center(
                            child: Icon(
                              Icons.escalator_warning_rounded,
                              size: 30,
                            ),
                          ),
                        ),
                      );
                    } else {
                      // Display user posts
                      return Expanded(
                        child: GridView.builder(
                          shrinkWrap: true,
                          padding: const EdgeInsets.all(20),
                          gridDelegate:
                              const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 3,
                            crossAxisSpacing: 10,
                            mainAxisSpacing: 10,
                          ),
                          itemCount: snapshot.data!.length,
                          itemBuilder: (context, index) {
                            final post = snapshot.data![index];
                            return GestureDetector(
                              onTap: () {
                                _navigateToDetailPage(post);
                              },
                              child: post.postImages
                                      .isNotEmpty // Check if post has images
                                  ? CachedNetworkImage(
                                      memCacheWidth: 200,
                                      imageUrl: post.postImages[0].images,
                                      placeholder: (context, url) => Container(
                                        color: Colors.blueGrey,
                                        child: const Center(
                                            child: PixelPlaceholder()),
                                      ),
                                      errorWidget: (context, url, error) =>
                                          const Icon(Icons.error),
                                      fit: BoxFit.cover,
                                    )
                                    : post.postVideo.isNotEmpty
                                        ? FutureBuilder<String>(
                                            future: VideoThumbnailUtil.generateThumbnail(post.postVideo[0].video, post.id),
                                            builder: (context, snapshot) {
                                              if (snapshot.connectionState == ConnectionState.waiting) {
                                                return Container(
                                                  color: Colors.blueGrey,
                                                  child: const Center(child: CircularProgressIndicator()),
                                                );
                                              } else if (snapshot.hasError || !snapshot.hasData) {
                                                return Container(
                                                  color: Colors.grey[200],
                                                  child: Center(
                                                    child: Text(
                                                      post.content,
                                                      softWrap: true,
                                                      overflow: TextOverflow.fade,
                                                      style: const TextStyle(color: Colors.grey, fontSize: 7),
                                                    ),
                                                  ),
                                                );
                                              } else {
                                                return Stack(
                                                  children: [
                                                    Image.file(
                                                            File(snapshot.data!),
                                                            fit: BoxFit.cover,
                                                            width: double.infinity,
                                                            height: double.infinity,
                                                          ),
                                                    Positioned(
                                                          top: 0,
                                                          left: 0,
                                                          right: 0,
                                                          bottom: 0,
                                                          child: Center(
                                                            child: Opacity(
                                                              opacity: 0.7,
                                                              child: Container(
                                                                width: 30,
                                                                height: 30,
                                                                decoration: BoxDecoration(
                                                                  color: Colors.black,
                                                                  borderRadius: BorderRadius.circular(50),
                                                                ),
                                                                child: const Icon(
                                                                  Icons.play_arrow,
                                                                  color: Colors.white,
                                                                ),
                                                              ),
                                                            ),
                                                          ),
                                                        ),
                                                  ]
                                                );
                                              }
                                            },
                                          )
                                  :
                                  Container(
                                      // Placeholder when no images are available
                                      color: Colors.grey[200],
                                      child: Center(
                                        child: Text(
                                          softWrap: true,
                                          overflow: TextOverflow.fade,
                                          post.content,
                                          style: const TextStyle(
                                            color: Colors.grey,
                                            fontSize: 7,
                                          ),
                                        ),
                                      ),
                                    ),
                            );
                          },
                        ),
                      );
                    }
                  },
                ),
              ],
            );
          } else {
            return const Center(
                child: Text('系統崩潰啦。。。')); // or any other loading indicator
          }
        }),
      ),
      endDrawer: const AccountDrawer(),
    );
  }

  @override
  bool get wantKeepAlive => true;
}
