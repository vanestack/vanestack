import 'package:dart_mappable/dart_mappable.dart';

part 's3_settings.mapper.dart';

@MappableClass()
class S3Settings with S3SettingsMappable {
  final String endpoint;
  final String bucket;
  final String region;
  final String accessKey;
  final String secretKey;
  final bool enabled;

  S3Settings({
    required this.endpoint,
    required this.bucket,
    required this.region,
    required this.accessKey,
    required this.secretKey,
    this.enabled = false,
  });
}
