import 'package:dart_mappable/dart_mappable.dart';

part 'mail_settings.mapper.dart';

@MappableClass()
class MailSettings with MailSettingsMappable {
  final String smtpServer;
  final int smtpPort;
  final String? username;
  final String? password;
  final bool useSsl;
  final String fromAddress;
  final String fromName;
  final String? otpTemplate;
  final String? resetPasswordTemplate;

  MailSettings({
    required this.smtpServer,
    required this.fromAddress,
    required this.fromName,
    this.smtpPort = 587,
    this.username,
    this.password,
    this.useSsl = false,
    this.otpTemplate,
    this.resetPasswordTemplate,
  });
}
