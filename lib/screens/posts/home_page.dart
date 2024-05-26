import 'package:borderless/screens/chat/chat_list.dart';
import 'package:borderless/screens/posts/create_post.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:borderless/api/api_service.dart';
import 'package:borderless/components/post_container.dart';
import 'package:borderless/model/posts.dart';

class HomePage extends StatefulWidget {

  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {

  late Future<List<Post>> _posts;

  @override
  void initState() {
    super.initState();
    _refreshPosts();
  }

  Future<void> _refreshPosts() async {
    setState(() {
      _posts = ApiService.fetchPosts();
    });
  }
  

  @override
  Widget build(BuildContext context) {

    return Center(
      child: RefreshIndicator(
        color: Colors.green,
        onRefresh: () async {
          await _refreshPosts();
        },
        child: Scaffold(
          backgroundColor: Theme.of(context).colorScheme.background,
          appBar: AppBar(
            leading: IconButton(
              onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const CreatePost())), 
              icon: const Icon(Icons.camera_alt_outlined),
            ),
            title: const Text('Borderless'),
            actions: [
              IconButton(
                onPressed: () {
                  Navigator.push(context, MaterialPageRoute(builder: (context) => const ChatListScreen()));
                }, 
                icon: const Icon(Icons.chat_bubble_outline), 
              ),
            ],
          ),
          body: FutureBuilder<List<Post>>(
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
                return posts.isNotEmpty ? ListView.builder(
                  itemCount: posts.length,
                  itemBuilder: (context, index) {
                    final post = posts[index];
                    return PostContainer(
                      post: post
                    );
                  }
                ) : Center(child: TextButton(
                  onPressed: () => Navigator.push(context, PageRouteBuilder(
                      pageBuilder: (_, __, ___) => const CreatePost(),
                      transitionDuration: const Duration(milliseconds: 500),
                      transitionsBuilder: (_, a, __, c) => FadeTransition(opacity: a, child: c),
                    ),
                  ),
                  child: Text("創建新的貼文", style: TextStyle(color: Theme.of(context).colorScheme.secondary),)
                ));
              }
            },
            
          ),
          
        ),
      ),
    );
  }
  
}
