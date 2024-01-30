import 'package:logger/logger.dart';

class Logging {
  
  static final Logging _instance = Logging._internal();

  Logging._internal();

  factory Logging() => _instance;

  final logger = Logger();

  void message_verbose(String message) {
    logger.v('Level.verbose',message);
  }

  void message_debug(String message) {
    logger.d('Level.debug',message);
  }

  void message_info(String message) {
    logger.i('Level.info',message);
  }

  void message_warning(String message) {
    logger.w('Level.warning',message);
  }

  void message_error(String message) {
    logger.e('Level.error',message);
  }

}