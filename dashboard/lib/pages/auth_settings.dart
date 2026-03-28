import 'package:vanestack_client/vanestack_client.dart';
import 'package:vanestack_common/vanestack_common.dart';
import 'package:jaspr/dom.dart';
import 'package:jaspr/jaspr.dart';
import 'package:jaspr_riverpod/jaspr_riverpod.dart';
import 'package:universal_web/web.dart';

import '../components/alert_dialog.dart';
import '../components/error_alert.dart';
import '../components/progress_indicator.dart';
import '../providers/client.dart';
import '../providers/settings.dart';
import '../utils/toast.dart';

class AuthSettingsPage extends StatefulComponent {
  const AuthSettingsPage({super.key});

  @override
  State<StatefulComponent> createState() => _AuthSettingsPageState();
}

class _AuthSettingsPageState extends State<AuthSettingsPage> {
  final appleSecretDialogKey = GlobalNodeKey<HTMLFormElement>();
  final inputData = {};

  // Apple client secret generation form data
  final appleSecretData = <String, String>{
    'clientId': '',
    'teamId': '',
    'keyId': '',
    'privateKey': '',
    'duration': '15777000',
  };

  final providers = [
    'apple',
    'google',
    'facebook',
    'microsoft',
    'discord',
    'spotify',
    'reddit',
    'twitch',
    'slack',
    'linkedin',
    'github',
  ];

  String capitalize(String s) => s[0].toUpperCase() + s.substring(1);

  OAuthProvider? getProviderByName(OAuthProviderList providers, String name) {
    return switch (name) {
      'google' => providers.google,
      'github' => providers.github,
      'discord' => providers.discord,
      'apple' => providers.apple,
      'facebook' => providers.facebook,
      'linkedin' => providers.linkedin,
      'slack' => providers.slack,
      'spotify' => providers.spotify,
      'reddit' => providers.reddit,
      'twitch' => providers.twitch,
      _ => null,
    };
  }

  Future<bool> save(String providerName) async {
    final form = document.getElementById('form-$providerName') as HTMLFormElement;
    if (!form.checkValidity()) {
      form.reportValidity();
      return false;
    }

    final settings = await context.read(settingsProvider.future);

    final data = Map<String, Object?>.from({
      ...settings.oauthProviders.toJson(),
      providerName: Map<String, Object?>.from({
        ...?getProviderByName(settings.oauthProviders, providerName)?.toJson(),
        ...?inputData[providerName],
      }),
    });

    final oauthProviders = OAuthProviderListMapper.fromJson(data);

    await context.read(settingsProvider.notifier).updateOAuthProviders(oauthProviders);

    showToast(
      title: 'Settings saved successfully',
      category: ToastCategory.success,
    );

    return true;
  }

  Future<bool> generateAppleSecret() async {
    final form = document.getElementById('form-apple-secret') as HTMLFormElement;
    if (!form.checkValidity()) {
      form.reportValidity();
      return false;
    }

    final client = context.read(clientProvider);

    try {
      final secret = await client.settings.generateAppleClientSecret(
        clientId: appleSecretData['clientId']!,
        teamId: appleSecretData['teamId']!,
        keyId: appleSecretData['keyId']!,
        privateKey: appleSecretData['privateKey']!,
        duration: int.parse(appleSecretData['duration']!),
      );

      // Set the generated secret in the Apple provider settings
      inputData.putIfAbsent('apple', () => {})['client_secret'] = secret;

      // Also update the input field value
      final secretInput = document.getElementById('apple-client-secret') as HTMLInputElement?;
      if (secretInput != null) {
        secretInput.value = secret;
      }

      showToast(
        title: 'Client secret generated successfully',
        category: ToastCategory.success,
      );

      return true;
    } on VaneStackException catch (e) {
      showToast(
        title: 'Failed to generate client secret',
        description: e.message,
        category: ToastCategory.error,
      );
      return false;
    } finally {
      appleSecretDialogKey.currentNode?.reset();
    }
  }

  @override
  Component build(BuildContext context) {
    final settings = context.watch(settingsProvider);

    return settings.when(
      data: (data) {
        return div(
          classes: 'grid grid-cols-1 sm:grid-cols-2 md:grid-cols-3 lg:grid-cols-5 gap-3 p-4"',
          [
            for (final name in providers)
              Builder(
                builder: (context) {
                  final provider = getProviderByName(data.oauthProviders, name);
                  return button(
                    onClick: () {
                      final modal = document.getElementById('dialog-$name') as HTMLDialogElement;
                      modal.showModal();
                    },
                    classes:
                        'relative group border rounded-2xl p-4 flex flex-col items-center shadow-sm hover:shadow-md transition-shadow duration-300 cursor-pointer',
                    [
                      if (provider?.enabled ?? false)
                        div(
                          classes:
                              'absolute top-2 right-2 w-4 h-4 bg-success/50 group-hover:bg-success rounded-full flex items-center justify-center transition-colors duration-300',
                          [i(classes: 'icon-check text-primary-foreground scale-70', [])],
                        ),

                      img(
                        classes: 'w-6 h-6 opacity-60 group-hover:opacity-100 transition-opacity duration-300',
                        src: "https://cdn.jsdelivr.net/gh/simple-icons/simple-icons/icons/${name.toLowerCase()}.svg",
                      ),
                      span(classes: 'mt-3 text-xs', [
                        Component.text(capitalize(name)),
                      ]),
                    ],
                  );
                },
              ),
            for (final name in providers)
              Builder(
                builder: (context) {
                  final provider = getProviderByName(data.oauthProviders, name);
                  return AlertDialog(
                    id: 'dialog-$name',
                    title: Component.text('${capitalize(name)} Settings'),
                    content: form(
                      id: 'form-$name',
                      classes: 'grid gap-4 border-t border-border',
                      [
                        label(classes: 'label mt-4', [
                          input(
                            name: '$name-enabled',
                            classes: 'input',
                            type: InputType.checkbox,
                            attributes: {'role': 'switch'},
                            checked: provider?.enabled,
                            onInput: (v) => inputData.putIfAbsent(
                              name,
                              () => {},
                            )['enabled'] = v,
                          ),
                          Component.text('Enabled'),
                        ]),
                        label(classes: 'label grid gap-2', [
                          span(
                            classes: 'text-[10px] text-muted-foreground font-bold uppercase',
                            [
                              Component.text(
                                name == 'apple'
                                    ? 'Client IDs (comma-separated)'
                                    : name == 'google'
                                    ? 'Client IDs (comma-separated)'
                                    : 'Client ID',
                              ),
                            ],
                          ),
                          input(
                            value: provider?.clientId,
                            name: '$name-client-id',
                            classes: 'input',
                            type: InputType.text,
                            onInput: (v) => inputData.putIfAbsent(
                              name,
                              () => {},
                            )['client_id'] = v,
                            attributes: {'required': ''},
                          ),
                          if (name == 'google')
                            span(
                              classes: 'text-[11px] text-muted-foreground',
                              [
                                Component.text(
                                  'If you have multiple client IDs, such as one for Web, iOS and Android, concatenate all of the client IDs with a comma but make sure the web\'s client ID is first in the list.',
                                ),
                              ],
                            ),
                          if (name == 'apple')
                            span(
                              classes: 'text-[11px] text-muted-foreground',
                              [
                                Component.text(
                                  'Enter your Service ID and Bundle ID separated by a comma, with the Service ID first (e.g. com.yourapp.web,com.yourapp.ios).',
                                ),
                              ],
                            ),
                        ]),
                        label(classes: 'label grid gap-2', [
                          span(
                            classes: 'text-[10px] text-muted-foreground font-bold uppercase',
                            [Component.text('Client Secret')],
                          ),
                          input(
                            id: '$name-client-secret',
                            value: provider?.clientSecret,
                            name: '$name-client-secret',
                            classes: 'input',
                            type: InputType.password,
                            onInput: (v) => inputData.putIfAbsent(
                              name,
                              () => {},
                            )['client_secret'] = v,
                            attributes: {'required': ''},
                          ),
                        ]),
                        if (name == 'apple')
                          button(
                            type: ButtonType.button,
                            classes: 'btn-outline text-sm',
                            onClick: () {
                              final modal = document.getElementById('dialog-apple-secret') as HTMLDialogElement;
                              modal.showModal();
                            },
                            [
                              i(classes: 'icon-key mr-2', []),
                              Component.text('Generate client secret'),
                            ],
                          ),
                      ],
                    ),
                    onSubmit: () => save(name),
                    button: (saving) => Component.fragment([
                      saving ? const ProgressIndicator() : i([], classes: 'icon-check'),
                      Component.text('Save'),
                    ]),
                  );
                },
              ),
            // Apple client secret generation dialog
            AlertDialog(
              key: appleSecretDialogKey,
              id: 'dialog-apple-secret',
              title: Component.text('Generate Apple client secret'),
              content: form(
                key: appleSecretDialogKey,
                id: 'form-apple-secret',
                classes: 'grid gap-4 border-t border-border pt-4',
                [
                  div(classes: 'grid grid-cols-2 gap-4', [
                    label(classes: 'label grid gap-2', [
                      span(
                        classes:
                            'text-[10px] text-muted-foreground font-bold uppercase after:content-["*"] after:text-destructive after:ml-0.5',
                        [Component.text('Service ID')],
                      ),
                      input(
                        name: 'apple-secret-client-id',
                        classes: 'input',
                        type: InputType.text,
                        onInput: (v) => appleSecretData['clientId'] = v as String,
                        attributes: {'required': ''},
                      ),
                    ]),
                    label(classes: 'label grid gap-2', [
                      span(
                        classes:
                            'text-[10px] text-muted-foreground font-bold uppercase after:content-["*"] after:text-destructive after:ml-0.5',
                        [Component.text('Team ID')],
                      ),
                      input(
                        name: 'apple-secret-team-id',
                        classes: 'input',
                        type: InputType.text,
                        onInput: (v) => appleSecretData['teamId'] = v as String,
                        attributes: {'required': ''},
                      ),
                    ]),
                  ]),
                  div(classes: 'grid grid-cols-2 gap-4', [
                    label(classes: 'label grid gap-2', [
                      span(
                        classes:
                            'text-[10px] text-muted-foreground font-bold uppercase after:content-["*"] after:text-destructive after:ml-0.5',
                        [Component.text('Key ID')],
                      ),
                      input(
                        name: 'apple-secret-key-id',
                        classes: 'input',
                        type: InputType.text,
                        onInput: (v) => appleSecretData['keyId'] = v as String,
                        attributes: {'required': ''},
                      ),
                    ]),
                    label(classes: 'label grid gap-2', [
                      span(
                        classes:
                            'text-[10px] text-muted-foreground font-bold uppercase after:content-["*"] after:text-destructive after:ml-0.5',
                        [Component.text('Duration (in seconds)')],
                      ),
                      input(
                        name: 'apple-secret-duration',
                        classes: 'input',
                        type: InputType.number,
                        value: '15777000',
                        onInput: (v) => appleSecretData['duration'] = v as String,
                        attributes: {
                          'required': '',
                          'max': '15777000',
                        },
                      ),
                    ]),
                  ]),
                  label(classes: 'label grid gap-2', [
                    span(
                      classes:
                          'text-[10px] text-muted-foreground font-bold uppercase after:content-["*"] after:text-destructive after:ml-0.5',
                      [Component.text('Private key')],
                    ),
                    textarea(
                      name: 'apple-secret-private-key',
                      classes: 'textarea min-h-[200px] font-mono text-xs',
                      onInput: (v) => appleSecretData['privateKey'] = v,
                      attributes: {
                        'required': '',
                        'placeholder': '-----BEGIN PRIVATE KEY-----\n...\n-----END PRIVATE KEY-----',
                      },
                      [],
                    ),
                  ]),
                  p(classes: 'text-xs text-muted-foreground', [
                    Component.text(
                      'The key is not stored on the server and is used only for generating the signed JWT.\n\nDuration is capped at 6 months as per Apple guidelines. You will need to regenerate the secret after it expires.',
                    ),
                  ]),
                ],
              ),
              onSubmit: generateAppleSecret,
              button: (saving) => Component.fragment([
                saving ? const ProgressIndicator() : i([], classes: 'icon-key'),
                Component.text('Generate and set secret'),
              ]),
            ),
          ],
        );
      },
      loading: () => div(classes: 'flex justify-center items-center h-44', [
        const ProgressIndicator(),
      ]),
      error: (error, stack) => ErrorAlert(title: 'Failed to load settings'),
    );
  }
}
