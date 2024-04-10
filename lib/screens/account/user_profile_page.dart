// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:borderless/api/api_service.dart';
import 'package:borderless/screens/chat/chat_page.dart';
import 'package:borderless/screens/posts/post_details.dart';
import 'package:borderless/utils/pixel_placeholder.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import 'package:borderless/model/posts.dart';
import 'package:borderless/model/user_profile.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

class UserProfilePage extends StatefulWidget {
  final UserProfile userProfile;
  
  const UserProfilePage({
    super.key,
    required this.userProfile,
  });

  @override
  State<UserProfilePage> createState() => _UserProfilePageState();
}

class _UserProfilePageState extends State<UserProfilePage> {
  late Future<List<Post>> _posts;

  void _navigateToDetailPage(Post post) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PostDetails(post: post),
      ),
    );
  }

  @override
  void initState() {
    _posts = ApiService.getCheckUserPosts(widget.userProfile.id);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
        backgroundColor: Theme.of(context).colorScheme.background,
        appBar: AppBar(
          title: const Text(
            "。。。",
            style: TextStyle(fontSize: 19),
          ),
        ),
        body: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // row,
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
                            padding: const EdgeInsets.only(left: 20.0, bottom: 7.0),
                            child: Text(
                              widget.userProfile.username,
                              style: TextStyle(
                                  color: Theme.of(context).colorScheme.secondary,
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold),
                            ),
                          ),
                          // 2. id,
                          Padding(
                            padding: const EdgeInsets.only(left: 20.0),
                            child: Text(
                              '@${widget.userProfile.id}',
                              style: const TextStyle(
                                  color: Colors.grey,
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold),
                            ),
                          ),
                        ],
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: CircleAvatar(
                          radius: 30,
                          backgroundImage:
                              NetworkImage(widget.userProfile.avatar), // Use NetworkImage
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 15,),
                  // bio,
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Text("bio: ${widget.userProfile.bio}"),
                  ),
            
                  // edit profile,
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.push(context, MaterialPageRoute(builder: (context) => ChatPage(friend: widget.userProfile)));
                      }, 
                      child: Text("簡訊", style: TextStyle(color: Theme.of(context).colorScheme.secondary,),),
                    ),
                  ),
                  FutureBuilder<List<Post>>(
                    future: _posts,
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(
                            child: SpinKitCircle(
                          color: Colors.green,
                        ));
                      } else if (snapshot.hasError) {
                        return Center(
                            child: Text('Error fetching posts: ${snapshot.error}'));
                      } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                        return const Center(
                          child: Text('No posts available'),
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
                                    : Container(
                                        // Placeholder when no images are available
                                        color: Colors.grey[200],
                                        child: const Center(
                                          child: Text(
                                            'No Image',
                                            style: TextStyle(color: Colors.grey),
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
              ),
            );
            }
}


         
        
      

