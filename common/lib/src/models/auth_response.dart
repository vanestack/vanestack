import 'package:dart_mappable/dart_mappable.dart';

import 'user.dart';

part 'auth_response.mapper.dart';

@MappableClass()
class AuthResponse with AuthResponseMappable {
  final String accessToken;
  final String refreshToken;
  final User user;

  AuthResponse({
    required this.accessToken,
    required this.refreshToken,
    required this.user,
  });
}
