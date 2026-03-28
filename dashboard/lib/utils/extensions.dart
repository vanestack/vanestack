extension DateTimeX on DateTime {
  int get secondsSinceEpoch {
    return millisecondsSinceEpoch ~/ 1000;
  }
}

extension StringX on String {
  String? get nullIfEmpty => trim().isEmpty ? null : this;
}
