import 'package:borderless/screens/posts/friend_post.dart';
import 'package:borderless/screens/posts/public_post.dart';
import 'package:borderless/utils/page_animation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
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
            icon: Image.asset(
                  'assets/icons/chat.png',
                  width: 24,
                  height: 24,
                ),
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
                tabs: [
                  Tab(text: AppLocalizations.of(context)!.following),
                  Tab(text: AppLocalizations.of(context)!.forYou),
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
