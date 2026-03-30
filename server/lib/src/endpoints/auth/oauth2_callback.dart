import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:shelf/shelf.dart';
import 'package:vanestack_annotation/vanestack_annotation.dart';
import 'package:vanestack_common/vanestack_common.dart';

import '../../utils/extensions.dart';
import '../../utils/logger.dart';

/// GET callback for most OAuth providers
@Route(
  path: '/v1/auth/oauth2/<provider>/callback',
  method: HttpMethod.get,
  ignoreForClient: true,
)
FutureOr<Response> oauth2Callback(Request request, String provider) async {
  final queryParams = request.url.queryParameters;
  final code = queryParams['code'];
  final state = queryParams['state'];

  return _handleCallback(request, provider, code, state, null);
}

/// POST callback for Apple (uses response_mode=form_post)
@Route(
  path: '/v1/auth/oauth2/<provider>/callback',
  method: HttpMethod.post,
  ignoreForClient: true,
)
FutureOr<Response> oauth2CallbackPost(Request request, String provider) async {
  final body = await request.readAsString();
  final params = Uri.splitQueryString(body);

  final code = params['code'];
  final state = params['state'];

  // Apple sends user info (name) only on first authorization
  String? appleUserName;
  final userJson = params['user'];
  if (userJson != null) {
    try {
      final userData = jsonDecode(userJson) as Map<String, dynamic>;
      final name = userData['name'] as Map<String, dynamic>?;
      if (name case {
        'firstName': String firstName,
        'lastName': String lastName,
      }) {
        appleUserName = '$firstName $lastName'.trim();
      }
    } catch (e) {
      authLogger.warn('Failed to parse Apple user data: $e');
    }
  }

  return _handleCallback(request, provider, code, state, appleUserName);
}

Future<Response> _handleCallback(
  Request request,
  String provider,
  String? code,
  String? state,
  String? userName,
) async {
  if (code == null) {
    throw VaneStackException('Missing code', status: HttpStatus.badRequest);
  }

  if (state == null) {
    throw VaneStackException('Missing state', status: HttpStatus.badRequest);
  }

  final settings = await request.settings();

  final (authResponse, redirectUrl) = await request.auth.handleOAuthCallback(
    provider: provider,
    code: code,
    state: state,
    settings: settings,
    userName: userName,
  );

  final redirectUri = Uri.parse(redirectUrl);

  // Use URL fragment (#) instead of query parameters so tokens
  // are not sent to servers or logged in access logs
  final fragment = Uri(
    queryParameters: {
      'access_token': authResponse.accessToken,
      'refresh_token': authResponse.refreshToken,
      'user': authResponse.user.toJsonString(),
    },
  ).query;
  final location = redirectUri.replace(fragment: fragment).toString();

  return Response.found(location);
}
