/// The entrypoint for the **client** app.
///
/// This file is compiled to javascript and executed on the client when loading the page.
library;

// Client-specific Jaspr import.
import 'package:jaspr/client.dart';
import 'package:jaspr_riverpod/jaspr_riverpod.dart';
import 'package:vanestack_client/vanestack_client.dart';

import '../utils/auth_storage.dart';
import 'app.dart';
import 'providers/client.dart';
import 'utils/jwt.dart';

Future<void> main() async {
  final client = VaneStackClient(
    baseUrl: Uri(
      scheme: Uri.base.scheme,
      host: Uri.base.host,
      port: Uri.base.port,
    ).toString(),
    authStorage: LocalAuthStorage(),
  );

  await client.initialize();
  final accessToken = client.accessToken;
  if (accessToken != null && isJwtExpired(accessToken)) {
    try {
      await client.auth.refresh().timeout(Duration(seconds: 10));
    } catch (e) {
      // If refreshing fails, the user will just have to log in again. Don't
      // block the app from loading.
      print('Failed to refresh access token.');
    }
  }

  runApp(
    ProviderScope(
      overrides: [
        clientProvider.overrideWithValue(client),
      ],
      child: App(),
    ),
  );
}
