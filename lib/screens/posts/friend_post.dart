import 'package:borderless/api/api_service.dart';
import 'package:borderless/components/post_container.dart';
import 'package:borderless/model/posts.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

class FriendPost extends StatefulWidget {
  const FriendPost({super.key});

  @override
  State<FriendPost> createState() => _FriendPostState();
}

class _FriendPostState extends State<FriendPost> with TickerProviderStateMixin {
  late Future<List<Post>> _posts;

  @override
  void initState() {
    _refreshPosts();
    super.initState();
  }

  Future<void> _refreshPosts() async {
    setState(() {
      _posts = ApiService.fetchPosts();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: RefreshIndicator(
          color: Colors.green,
          onRefresh: () async {
            await _refreshPosts();
          },
          child: FutureBuilder<List<Post>>(
            future: _posts,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(
                  child: SpinKitCircle(
                    color: Colors.green,
                  ),
                );
              } else if (snapshot.hasError) {
                return Center(child: Text('Error: ${snapshot.error}'));
              } else {
                final List<Post> posts = snapshot.data ?? [];
                return posts.isNotEmpty
                    ? ListView.builder(
                        itemCount: posts.length,
                        itemBuilder: (context, index) {
                          final post = posts[index];
                          return PostContainer(post: post);
                        })
                    : Center(
                        child: TextButton(
                          onPressed: () => _refreshPosts(),
                          child: Text(
                            "點擊刷新喔～",
                            style: TextStyle(
                                color: Theme.of(context).colorScheme.secondary),
                          ),
                        ),
                      );
              }
            },
          ),
        ),
      ),
    );
  }
}
