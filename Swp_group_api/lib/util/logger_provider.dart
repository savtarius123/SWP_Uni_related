import 'package:logger/logger.dart';
import 'package:logger/web.dart';

class LoggerProvider {
  static Logger? _instance;

  static void configureLogger(String logLevel) {
    // The logger may only be configured once at the start of the application.
    if (_instance != null) {
      return;
    }

    Level level;

    switch (logLevel.toUpperCase()) {
      case 'DEBUG':
        level = Level.debug;
        break;
      case 'INFO':
        level = Level.info;
        break;
      case 'WARN':
        level = Level.warning;
        break;
      case 'ERROR':
        level = Level.error;
        break;
      default:
        level = Level.info;
    }

    _instance = Logger(
      filter: level == Level.debug ? DebugFilter() : ProductionFilter(),
      printer: PrettyPrinter(),
      output: ConsoleOutput(),
      level: level,
    );
  }

  static Logger get instance {
    if (_instance == null) {
      throw Exception('Logger not configured');
    }

    return _instance!;
  }
}

class DebugFilter extends LogFilter {
  @override
  bool shouldLog(LogEvent event) {
    return true;
  }
}
