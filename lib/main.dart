import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:xiaozhi/pages/home/home_page.dart';
import 'package:xiaozhi/services/logger_service.dart';
import 'package:xiaozhi/style/theme_style.dart';

void main() {
  // 确保初始化
  WidgetsFlutterBinding.ensureInitialized();
  dotenv.load(fileName: '.env');
  initLogger();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: themeData,
      home: HomePageWithTabs(),
    );
  }
}
