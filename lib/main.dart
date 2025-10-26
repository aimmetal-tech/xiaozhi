import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:xiaozhi/services/logger_service.dart';
import 'package:xiaozhi/style/theme_style.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:xiaozhi/firebase_options.dart';
import 'package:xiaozhi/routes/app_router.dart';

Future<void> main() async {
  // 确保初始化
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: '.env');
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  initLogger();
  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      theme: themeData,
      routerConfig: appRouter,
    );
  }
}
