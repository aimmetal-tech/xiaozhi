import 'package:flutter/material.dart';
import 'package:xiaozhi/pages/home/home_page.dart';
import 'package:xiaozhi/style/theme_style.dart';

void main() {
  // 确保初始化
  WidgetsFlutterBinding.ensureInitialized();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: myTheme,
      home: HomePage(),
    );
  }
}
