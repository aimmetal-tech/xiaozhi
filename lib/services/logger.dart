import 'package:logger/logger.dart';

/// 全局logger实例
late Logger logger;

/// 初始化全局logger
void initLogger() {
  logger = Logger(
    printer: PrettyPrinter(
      methodCount: 2, // 方法调用堆栈的数量
      errorMethodCount: 8, // 错误方法调用堆栈的数量
      lineLength: 120, // 行的最大长度
      colors: true, // 是否使用颜色输出
      printEmojis: true, // 是否打印emoji
      dateTimeFormat: DateTimeFormat.dateAndTime, // 是否打印时间戳
    ),
    level: Level.debug, // 日志级别
  );
}
