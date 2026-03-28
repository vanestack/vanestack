import 'package:shelf/shelf.dart';

final _defaultHeaders = {
  'Access-Control-Allow-Origin': '*',
  'Access-Control-Allow-Methods': 'GET, POST, PUT, PATCH, DELETE, OPTIONS',
  'Access-Control-Allow-Headers':
      'Origin, Content-Type, Accept, Authorization, cache-control',
};

Middleware cors() => (final innerHandler) {
  return (final request) async {
    if (request.method == 'OPTIONS') {
      return Response.ok(null, headers: _defaultHeaders);
    }

    final response = await innerHandler(request);

    return response.change(headers: {...response.headers, ..._defaultHeaders});
  };
};
