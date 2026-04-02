import 'package:shelf/shelf.dart';

const _securityHeaders = {
  'X-Content-Type-Options': 'nosniff',
  'X-Frame-Options': 'DENY',
  'Referrer-Policy': 'strict-origin-when-cross-origin',
};

Middleware securityHeaders() => (final innerHandler) {
      return (final request) async {
        final response = await innerHandler(request);
        return response.change(
          headers: {...response.headers, ..._securityHeaders},
        );
      };
    };
