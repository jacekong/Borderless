import 'package:borderless/screens/posts/friend_post.dart';
import 'package:borderless/screens/posts/public_post.dart';
import 'package:borderless/utils/page_animation.dart';
import 'package:flutter/material.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with TickerProviderStateMixin {
  late TabController _tabController;
  int selectedIndex = 0;

  // late Future<List<Post>> _posts;

  @override
  void initState() {
    // _refreshPosts();
    _tabController = TabController(length: 2, vsync: this);
    super.initState();
  }

  // Future<void> _refreshPosts() async {
  //   setState(() {
  //     _posts = ApiService.fetchPosts();
  //   });
  // }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      appBar: AppBar(
        leading: IconButton(
          onPressed: () =>
              Navigator.of(context).push(PageAnimation.createPostRoute()),
          icon: const Icon(Icons.camera_alt_outlined),
        ),
        title: const Text('Borderless'),
        actions: [
          IconButton(
            onPressed: () {
              Navigator.of(context).push(PageAnimation.createChatRoute());
            },
            icon: const Icon(Icons.chat_bubble_outline),
          ),
        ],
      ),
      body: Column(
        children: [
          // tab bar
          Align(
            alignment: Alignment.topLeft,
            child: TabBar(
                controller: _tabController,
                labelColor: Colors.green,
                labelStyle: const TextStyle(fontWeight: FontWeight.normal),
                unselectedLabelColor: Colors.grey,
                indicatorColor: Colors.green,
                isScrollable: true,
                tabAlignment: TabAlignment.start,
                dividerColor: Colors.transparent,
                tabs: const [
                  Tab(text: "朋友動態"),
                  Tab(text: "廣場"),
                ]),
          ),
          // tab bar view
          const SizedBox(
            height: 5,
          ),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: const [
                FriendPost(),
                PublicPost(),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
