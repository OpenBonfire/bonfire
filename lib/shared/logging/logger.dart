import 'package:talker/talker.dart';

final _talker = Talker();
final logger = EALogger();

class EALogger {
  void warning(String message, [Object? exception, StackTrace? stackTrace]) {
    _talker.warning(message, exception, stackTrace);
  }

  void error(String message, [Object? exception, StackTrace? stackTrace]) {
    _talker.error(message, exception, stackTrace);
  }

  void info(String message, [Object? exception, StackTrace? stackTrace]) {
    _talker.info(message, exception, stackTrace);
  }
}
