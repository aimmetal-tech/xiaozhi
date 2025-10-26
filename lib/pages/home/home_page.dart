import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/material.dart';
import 'package:xiaozhi/pages/chat_page.dart';
import 'package:xiaozhi/pages/discover_page.dart';
import 'package:xiaozhi/pages/shared/home_drawer.dart';
import 'package:xiaozhi/pages/user_page.dart';

class HomePageWithTabs extends ConsumerStatefulWidget {
  const HomePageWithTabs({super.key});

  @override
  ConsumerState<HomePageWithTabs> createState() => _TopTabBarState();
}

class _TopTabBarState extends ConsumerState<HomePageWithTabs>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: HomeDrawer(),
      appBar: AppBar(
        automaticallyImplyLeading: false,
        titleSpacing: 0,
        iconTheme: IconThemeData(color: Colors.grey),
        toolbarHeight: 56,
        title: Row(
          children: [
            SizedBox(width: 16),
            Builder(
              builder: (context) => IconButton(
                color: Colors.grey,
                onPressed: () => Scaffold.of(context).openDrawer(),
                icon: const Icon(Icons.menu),
              ),
            ),
            SizedBox(width: 20),
            Expanded(
              child: TabBar(
                controller: _tabController,
                // isScrollable: true,
                indicatorSize: TabBarIndicatorSize.label,
                tabs: const [
                  Tab(text: '智能对话'),
                  Tab(text: '发现·探索'),
                  Tab(text: '我的'),
                ],
              ),
            ),
          ],
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(5),
          child: Divider(),
        ),
      ),
      body: TabBarView(
        // physics: const NeverScrollableScrollPhysics(),
        controller: _tabController,
        children: [
          ChatPage(),
          DiscoverPage(),
          UserPage(),
        ],
      ),
    );
  }
}
