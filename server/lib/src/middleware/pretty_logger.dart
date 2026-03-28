import 'package:vanestack_common/vanestack_common.dart' show LogLevel;
import 'package:shelf/shelf.dart';

import '../utils/logger.dart';

final _logger = httpLogger;

Middleware prettyLogger() {
  return (Handler innerHandler) {
    return (Request request) async {
      final watch = Stopwatch()..start();

      final response = await innerHandler(request);

      watch.stop();

      // Skip dashboard/admin requests
      if (request.url.path.startsWith('_')) {
        return response;
      }

      final path = request.url.path.isEmpty ? '/' : '/${request.url.path}';

      LogLevel level;
      if (response.statusCode >= 500) {
        level = LogLevel.error;
      } else if (response.statusCode >= 400) {
        level = LogLevel.warn;
      } else {
        level = LogLevel.info;
      }

      final message =
          '${request.method} ${response.statusCode} ${watch.elapsedMilliseconds}ms $path';

      switch (level) {
        case LogLevel.error:
          _logger.error(message);
        case LogLevel.warn:
          _logger.warn(message);
        default:
          _logger.info(message);
      }

      return response;
    };
  };
}
