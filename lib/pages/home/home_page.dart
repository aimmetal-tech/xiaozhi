import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:xiaozhi/pages/chat_page.dart';
import 'package:xiaozhi/pages/shared/drawer_page.dart';

const List<Map<String, dynamic>> testButton = [
  {'title': 'AI对话', 'route': ChatPage()},
];

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme; // 配色方案
    final textTheme = Theme.of(context).textTheme; // 字体样式

    return Scaffold(
      appBar: AppBar(
        backgroundColor: colorScheme.primary,
        title: Text(
          '小智·HIPER',
          style: textTheme.headlineLarge!.copyWith(color: Colors.white),
        ),
        actions: [
          IconButton(onPressed: () {}, icon: Icon(Icons.search, size: 30)),
        ],
        centerTitle: true,
      ),
      drawer: HomeDrawer(),
      drawerEdgeDragWidth: MediaQuery.of(context).size.width,
      body: GridView.builder(
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          mainAxisSpacing: 20,
          crossAxisSpacing: 20,
          childAspectRatio: 1.0,
        ),
        itemCount: testButton.length,
        itemBuilder: (context, index) {
          final randomColor = Colors.primaries[index % Colors.primaries.length].shade400;
          return SizedBox.expand(
            child: ElevatedButton(
              style: ButtonStyle(
                // WidgetStateProperty.all: 所有状态都用同一个值
                backgroundColor: WidgetStateProperty.all(randomColor),
                padding: WidgetStateProperty.all(EdgeInsets.zero),
                shape: WidgetStateProperty.all(
                  const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
                ),
              ),
              onPressed: () {
                Navigator.of(context).push(
                  CupertinoPageRoute(
                    builder: (context) => testButton[index]['route'],
                  ),
                );
              },
              child: Text(
                testButton[index]['title'],
                style: TextStyle(color: Colors.white, fontSize: 25),
              ),
            ),
          );
        },
      ),
    );
  }
}
