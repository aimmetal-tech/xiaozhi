import 'package:logger/logger.dart';

late Logger logger;

void initLogger() {
  logger = Logger(
    printer: PrettyPrinter(
      methodCount: 2, // 方法调用的展示数量
      errorMethodCount: 8, // Number of method calls if stacktrace is provided
      lineLength: 120, // 输出的宽度
      colors: true, // 是否采用颜色
      printEmojis: true, // 是否允许Emoji
      // 时间戳
      dateTimeFormat: DateTimeFormat.onlyTimeAndSinceStart,
    ),
  );
}
