import 'dart:convert';
import 'dart:io';

import 'package:vanestack_common/vanestack_common.dart';
import 'package:http/http.dart';

enum OAuthProviderConfig {
  microsoft(
    authHost: 'login.microsoftonline.com',
    authPath: '/consumers/oauth2/v2.0/authorize',
    tokenUrl: 'https://login.microsoftonline.com/consumers/oauth2/v2.0/token',
    userInfoUrl: 'https://graph.microsoft.com/oidc/userinfo',
    scope: 'openid profile email',
  ),
  discord(
    authHost: 'discord.com',
    authPath: '/api/oauth2/authorize',
    tokenUrl: 'https://discord.com/api/oauth2/token',
    userInfoUrl: 'https://discord.com/api/users/@me',
    scope: 'identify email',
  ),
  spotify(
    authHost: 'accounts.spotify.com',
    authPath: '/authorize',
    tokenUrl: 'https://accounts.spotify.com/api/token',
    userInfoUrl: 'https://api.spotify.com/v1/me',
    scope: 'user-read-email user-read-private',
  ),
  reddit(
    authHost: 'www.reddit.com',
    authPath: '/api/v1/authorize',
    tokenUrl: 'https://www.reddit.com/api/v1/access_token',
    userInfoUrl: 'https://oauth.reddit.com/api/v1/me',
    scope: 'identity',
  ),
  twitch(
    authHost: 'id.twitch.tv',
    authPath: '/oauth2/authorize',
    tokenUrl: 'https://id.twitch.tv/oauth2/token',
    userInfoUrl: 'https://api.twitch.tv/helix/users',
    scope: 'openid user:read:email',
  ),
  slack(
    authHost: 'slack.com',
    authPath: '/oauth/v2/authorize',
    tokenUrl: 'https://slack.com/api/oauth.v2.access',
    userInfoUrl: 'https://slack.com/api/users.identity',
    scope: 'openid profile email',
  ),
  apple(
    authHost: 'appleid.apple.com',
    authPath: '/auth/authorize',
    tokenUrl: 'https://appleid.apple.com/auth/token',
    userInfoUrl: 'https://appleid.apple.com/auth/userinfo',
    scope: 'openid email name',
  ),
  linkedin(
    authHost: 'www.linkedin.com',
    authPath: '/oauth/v2/authorization',
    tokenUrl: 'https://www.linkedin.com/oauth/v2/accessToken',
    userInfoUrl: 'https://api.linkedin.com/v2/me',
    scope: 'r_liteprofile r_emailaddress',
  ),
  facebook(
    authHost: 'www.facebook.com',
    authPath: '/v18.0/dialog/oauth',
    tokenUrl: 'https://graph.facebook.com/v18.0/oauth/access_token',
    userInfoUrl: 'https://graph.facebook.com/me?fields=id,name,email,picture',
    scope: 'public_profile email',
  ),
  google(
    authHost: 'accounts.google.com',
    authPath: '/o/oauth2/v2/auth',
    tokenUrl: 'https://oauth2.googleapis.com/token',
    userInfoUrl: 'https://openidconnect.googleapis.com/v1/userinfo',
    scope: 'openid email profile',
  ),
  github(
    authHost: 'github.com',
    authPath: '/login/oauth/authorize',
    tokenUrl: 'https://github.com/login/oauth/access_token',
    userInfoUrl: 'https://api.github.com/user',
    scope: 'read:user user:email',
  );

  final String authHost;
  final String authPath;
  final String tokenUrl;
  final String userInfoUrl;
  final String scope;

  const OAuthProviderConfig({
    required this.authHost,
    required this.authPath,
    required this.tokenUrl,
    required this.userInfoUrl,
    required this.scope,
  });
}

Future<Map<String, dynamic>> exchangeCodeForToken(
  OAuthProviderConfig provider,
  String code,
  String clientId,
  String clientSecret,
  String redirectUri,
) async {
  final response = await post(
    Uri.parse(provider.tokenUrl),
    headers: {'Accept': 'application/json'},
    body: {
      'client_id': clientId,
      'client_secret': clientSecret,
      'code': code,
      'redirect_uri': redirectUri,
      'grant_type': 'authorization_code',
    },
  );

  if (response.statusCode != 200) {
    throw VaneStackException(
      'Failed to exchange code for token.',
      status: HttpStatus.internalServerError,
    );
  }

  return jsonDecode(response.body);
}

Future<SocialUser> fetchSocialUser(
  OAuthProviderConfig provider,
  Map<String, dynamic> tokenData,
) async {
  // Apple returns user info in the id_token, not via a userinfo endpoint
  if (provider == OAuthProviderConfig.apple) {
    final idToken = tokenData['id_token'] as String?;
    if (idToken == null) {
      throw VaneStackException(
        'Missing id_token from Apple',
        status: HttpStatus.badRequest,
      );
    }

    final parts = idToken.split('.');
    if (parts.length != 3) {
      throw VaneStackException(
        'Invalid id_token format',
        status: HttpStatus.badRequest,
      );
    }

    final payload = _decodeJwtPayload(parts[1]);

    final emailVerified = payload['email_verified'];
    return SocialUser(
      provider: provider.name,
      providerId: payload['sub']?.toString(),
      email: payload['email'] as String?,
      name:
          null, // Apple only sends name on first auth, via form post user field
      emailVerified: emailVerified == true || emailVerified == 'true',
    );
  }

  final userRes = await get(
    Uri.parse(provider.userInfoUrl),
    headers: {'Authorization': 'Bearer ${tokenData["access_token"]}'},
  );

  final data = jsonDecode(userRes.body);

  bool emailVerified = false;

  if (provider == OAuthProviderConfig.github) {
    final userEmailsRes = await get(
      Uri.parse('https://api.github.com/user/emails'),
      headers: {'Authorization': 'Bearer ${tokenData["access_token"]}'},
    );

    final emails = jsonDecode(userEmailsRes.body) as List<dynamic>;

    if (emails.isNotEmpty) {
      final email = emails.firstWhere(
        (e) => e['primary'] == true,
        orElse: () => emails.first,
      );
      data['email'] = email['email'];
      emailVerified = email['verified'] == true;
    }
  } else {
    // Google: email_verified, Discord: verified, Reddit: has_verified_email
    // Facebook: only returns confirmed emails, so treat as verified
    emailVerified =
        data['email_verified'] == true ||
        data['verified'] == true ||
        data['has_verified_email'] == true ||
        provider == OAuthProviderConfig.facebook;
  }

  return SocialUser(
    provider: provider.name,
    providerId: data['id']?.toString(),
    email: data['email'] ?? '',
    name: data['name'] ?? data['login'] ?? '',
    emailVerified: emailVerified,
  );
}

Map<String, dynamic> _decodeJwtPayload(String payload) {
  final normalized = base64Url.normalize(payload);
  final decoded = utf8.decode(base64Url.decode(normalized));
  return jsonDecode(decoded) as Map<String, dynamic>;
}

class SocialUser {
  final String provider; // google, github, discord…
  final String? providerId; // provider's ID
  final String? email;
  final String? name;
  final bool emailVerified;

  SocialUser({
    required this.provider,
    this.providerId,
    this.email,
    this.name,
    this.emailVerified = false,
  });

  @override
  String toString() {
    return 'SocialUser(provider: $provider, providerId: $providerId, email: $email, name: $name, emailVerified: $emailVerified)';
  }
}
