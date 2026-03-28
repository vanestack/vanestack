import 'package:vanestack_client/vanestack_client.dart';

import 'package:jaspr_riverpod/jaspr_riverpod.dart';

import 'client.dart';

final settingsProvider = AsyncNotifierProvider.autoDispose(
  SettingsProvider.new,
);

class SettingsProvider extends AsyncNotifier<Settings> {
  @override
  Future<Settings> build() async {
    final client = ref.watch(clientProvider);
    return client.settings.get();
  }

  Future<void> updateS3(S3Settings s3Settings) async {
    final client = ref.watch(clientProvider);
    final result = await AsyncValue.guard(
      () async => client.settings.update(s3: s3Settings),
    );

    state = result;
  }

  Future<void> updateMail(MailSettings mailSettings) async {
    final client = ref.watch(clientProvider);
    final result = await AsyncValue.guard(
      () async => client.settings.update(mail: mailSettings),
    );

    state = result;
  }

  Future<void> updateOAuthProviders(OAuthProviderList oauthProviders) async {
    final client = ref.watch(clientProvider);
    final result = await AsyncValue.guard(
      () async => client.settings.update(oauthProviders: oauthProviders),
    );

    state = result;
  }

  Future<void> updateApp({
    String? appName,
    String? siteUrl,
    List<String>? redirectUrls,
  }) async {
    final client = ref.watch(clientProvider);
    final result = await AsyncValue.guard(
      () async => client.settings.update(
        appName: appName,
        siteUrl: siteUrl,
        redirectUrls: redirectUrls,
      ),
    );

    state = result;
  }
}
