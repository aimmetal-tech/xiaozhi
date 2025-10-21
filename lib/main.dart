import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:xiaozhi/pages/home/home_page.dart';
import 'package:xiaozhi/style/theme_style.dart';
import 'package:xiaozhi/services/logger.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // init global logger
  initLogger();

  // load .env file
  try {
    await dotenv.load(fileName: '.env');
  } catch (e) {
    logger.f('Load .env file failed: ${e.toString()}');
  }

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
