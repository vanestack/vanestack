import 'package:shelf/shelf.dart';

Middleware inject(Map<String, Object> data) => (final innerHandler) {
  return (final request) async {
    return await innerHandler(request.change(context: data));
  };
};
