import 'package:dart_mappable/dart_mappable.dart';

class SecondsDateTimeMapper extends SimpleMapper<DateTime> {
  const SecondsDateTimeMapper();

  @override
  DateTime decode(dynamic value) {
    if (value is int) {
      return DateTime.fromMillisecondsSinceEpoch(value * 1000);
    }
    throw MapperException.unexpectedType(value.runtimeType, 'int');
  }

  @override
  dynamic encode(DateTime value) {
    return value.millisecondsSinceEpoch ~/ 1000;
  }
}
