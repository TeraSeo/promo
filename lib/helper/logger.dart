import 'package:logger/logger.dart';

class Logging {
  final logger = Logger();

  void message_verbose(String message) {
    logger.v('Level.verbose',message);
  }

  void message_debug(String message) {
    logger.v('Level.debug',message);
  }

  void message_info(String message) {
    logger.v('Level.info',message);
  }

  void message_warning(String message) {
    logger.v('Level.warning',message);
  }

  void message_error(String message) {
    logger.v('Level.error',message);
  }

  void message_wtf(String message) {
    logger.v('Level.wtf',message);
  }

}