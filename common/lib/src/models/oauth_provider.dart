import 'package:dart_mappable/dart_mappable.dart';

part 'oauth_provider.mapper.dart';

@MappableClass()
class OAuthProvider with OAuthProviderMappable {
  final String clientId;
  final String clientSecret;
  final bool enabled;

  const OAuthProvider({
    required this.clientId,
    required this.clientSecret,
    this.enabled = true,
  });
}

@MappableClass()
class OAuthProviderList with OAuthProviderListMappable {
  /// Comma separated client IDs for Google OAuth provider
  final OAuthProvider? google;

  final OAuthProvider? apple;
  final OAuthProvider? facebook;
  final OAuthProvider? github;
  final OAuthProvider? linkedin;
  final OAuthProvider? slack;
  final OAuthProvider? spotify;
  final OAuthProvider? reddit;
  final OAuthProvider? twitch;
  final OAuthProvider? discord;

  const OAuthProviderList({
    this.google,
    this.apple,
    this.facebook,
    this.github,
    this.linkedin,
    this.slack,
    this.spotify,
    this.reddit,
    this.twitch,
    this.discord,
  });
}
