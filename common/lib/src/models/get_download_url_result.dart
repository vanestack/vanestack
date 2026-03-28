import 'package:dart_mappable/dart_mappable.dart';

part 'get_download_url_result.mapper.dart';

@MappableClass()
class GetDownloadUrlResult with GetDownloadUrlResultMappable {
  final String url;

  GetDownloadUrlResult({required this.url});
}
