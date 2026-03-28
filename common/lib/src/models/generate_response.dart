import 'package:dart_mappable/dart_mappable.dart';

part 'generate_response.mapper.dart';

@MappableClass()
class GenerateResponse with GenerateResponseMappable {
  final int count;

  GenerateResponse({
    required this.count,
  });
}
