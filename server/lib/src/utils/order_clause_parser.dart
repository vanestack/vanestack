class OrderClauseParser {
  final String input;

  /// Optional set of allowed field names for validation.
  /// If provided, field names not in this set will throw FormatException.
  final Set<String>? allowedFields;

  OrderClauseParser(this.input, {this.allowedFields});

  /// Returns a tuple: (sqlFragment, List<(String field, String direction)>)
  (String, List<(String, String)>) parse() {
    if (input.trim().isEmpty) return ('', []);

    final fields = input
        .split(',')
        .map((s) => s.trim())
        .where((s) => s.isNotEmpty)
        .toList();

    final parts = <String>[];
    final parsed = <(String, String)>[];

    for (final f in fields) {
      final first = f[0];
      String direction = 'ASC';
      String field = f;

      if (first == '-') {
        direction = 'DESC';
        field = f.substring(1);
      } else if (first == '+') {
        direction = 'ASC';
        field = f.substring(1);
      }

      // Safety: ensure it's a valid SQL identifier (letters, numbers, underscore)
      if (!RegExp(r'^[A-Za-z_][A-Za-z0-9_]*$').hasMatch(field)) {
        throw FormatException('Invalid field name: $field');
      }

      // Validate field name against allowed fields
      if (allowedFields != null && !allowedFields!.contains(field)) {
        throw FormatException('Invalid field name in order clause: $field');
      }

      parts.add('$field $direction');
      parsed.add((field, direction));
    }

    final sql = parts.isNotEmpty ? 'ORDER BY ${parts.join(', ')}' : '';
    return (sql, parsed);
  }
}
