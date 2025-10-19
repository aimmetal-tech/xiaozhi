import 'package:flutter/material.dart';

final myTheme = ThemeData(
  // 应用程序颜色方案
  colorScheme: ColorScheme.fromSeed(
    seedColor: Colors.blue,
    brightness: Brightness.light,
  ),
  // IconButton默认样式
  iconButtonTheme: IconButtonThemeData(
    style: IconButton.styleFrom(foregroundColor: Colors.white),
  ),
  // 文本默认样式
  textTheme: TextTheme(
    headlineLarge: TextStyle(
      fontFamily: 'MiSans',
      fontWeight: FontWeight.w600,
      fontSize: 30,
    ),
    titleLarge: TextStyle(
      fontFamily: 'MiSans',
      fontWeight: FontWeight.w600,
      fontSize: 22,
    ),
    bodyMedium: TextStyle(
      fontFamily: 'MiSans',
      fontWeight: FontWeight.w500,
      fontSize: 18,
    ),
    bodySmall: TextStyle(
      fontFamily: 'MiSans',
      fontWeight: FontWeight.w400,
      fontSize: 15,
    ),
    labelSmall: TextStyle(
      fontFamily: 'MiSans',
      fontWeight: FontWeight.w300,
      fontSize: 15,
    ),
  ),
);
