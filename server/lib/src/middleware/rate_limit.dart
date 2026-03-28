import 'dart:io';

import 'package:shelf/shelf.dart';

import '../utils/extensions.dart';

/// In-memory sliding window rate limiter middleware.
///
/// Tracks requests by IP address for paths matching [pathPrefix]
/// and returns 429 Too Many Requests when the limit is exceeded.
Middleware rateLimit({String pathPrefix = '/v1/auth'}) =>
    (final innerHandler) {
      // Map of IP -> list of request timestamps
      final requests = <String, List<DateTime>>{};

      return (final request) async {
        // Only rate-limit paths matching the prefix
        final path = '/${request.url.path}';
        if (!path.startsWith(pathPrefix)) {
          return innerHandler(request);
        }

        final env = request.env;
        final maxRequests = env.rateLimitMax;
        final windowSeconds = env.rateLimitWindowSeconds;

        final ip =
            request.headers['x-forwarded-for']?.split(',').first.trim() ??
                (request.context['shelf.io.connection_info']
                        as HttpConnectionInfo?)
                    ?.remoteAddress
                    .address ??
                'unknown';

        final now = DateTime.now();
        final windowStart = now.subtract(Duration(seconds: windowSeconds));

        // Get or create the request list for this IP
        final ipRequests = requests[ip] ??= [];

        // Remove expired entries
        ipRequests.removeWhere((t) => t.isBefore(windowStart));

        if (ipRequests.length >= maxRequests) {
          return Response(
            429,
            body: '{"error": "Too many requests. Please try again later."}',
            headers: {
              'content-type': 'application/json',
              'retry-after': windowSeconds.toString(),
            },
          );
        }

        ipRequests.add(now);

        return innerHandler(request);
      };
    };
