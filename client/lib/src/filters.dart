enum SortDirection { asc, desc }

class OrderBy {
  final List<String> _fields;

  OrderBy(String fieldName, {SortDirection direction = SortDirection.asc})
    : _fields = [
        direction == SortDirection.asc ? '+$fieldName' : '-$fieldName',
      ];

  OrderBy addField(
    String fieldName, {
    SortDirection direction = SortDirection.asc,
  }) {
    final prefix = direction == SortDirection.asc ? '+' : '-';
    _fields.add('$prefix$fieldName');
    return this;
  }

  factory OrderBy.desc(String fieldName) =>
      OrderBy(fieldName, direction: SortDirection.desc);

  factory OrderBy.asc(String fieldName) =>
      OrderBy(fieldName, direction: SortDirection.asc);

  String build() {
    return _fields.join(',');
  }

  @override
  String toString() {
    return _fields.join(',');
  }
}

class Filter {
  final String? _expression;
  final List<Filter>? _children;
  final String? _operator; // AND / OR

  Filter._({String? expression, List<Filter>? children, String? operator})
    : _expression = expression,
      _children = children,
      _operator = operator;

  /// Creates a simple comparison filter like:
  /// Filter.where('age', isGreaterThan: 20)
  static Filter where(
    String field, {
    Object? isEqualTo,
    Object? isNotEqualTo,
    Object? isGreaterThan,
    Object? isLessThan,
    Object? isGreaterThanOrEqualTo,
    Object? isLessThanOrEqualTo,
    Object? like,
    Object? notLike,
  }) {
    String? expr;
    if (isEqualTo != null) {
      expr = _expr(field, '=', isEqualTo);
    } else if (isNotEqualTo != null) {
      expr = _expr(field, '!=', isNotEqualTo);
    } else if (isGreaterThan != null) {
      expr = _expr(field, '>', isGreaterThan);
    } else if (isLessThan != null) {
      expr = _expr(field, '<', isLessThan);
    } else if (isGreaterThanOrEqualTo != null) {
      expr = _expr(field, '>=', isGreaterThanOrEqualTo);
    } else if (isLessThanOrEqualTo != null) {
      expr = _expr(field, '<=', isLessThanOrEqualTo);
    } else if (like != null) {
      expr = _expr(field, 'LIKE', like);
    } else if (notLike != null) {
      expr = _expr(field, 'NOT LIKE', notLike);
    }

    if (expr == null) {
      throw ArgumentError('No valid operator provided for $field');
    }
    return Filter._(expression: expr);
  }

  /// Combines filters with AND
  static Filter and(List<Filter> filters) =>
      Filter._(children: filters, operator: 'AND');

  /// Combines filters with OR
  static Filter or(List<Filter> filters) =>
      Filter._(children: filters, operator: 'OR');

  /// Build SQL expression string recursively
  String build() {
    if (_expression != null) return _expression;
    if (_children == null || _children.isEmpty) return '';

    final built = _children
        .map((f) => f.build())
        .where((s) => s.isNotEmpty)
        .map((s) => '($s)')
        .join(' $_operator ');

    return built.isNotEmpty ? built : '';
  }

  /// Utility to produce value-safe expression
  static String _expr(String field, String op, Object value) {
    final val = _escapeValue(value);
    return '$field $op $val';
  }

  /// Escape string literals for SQL (simple approach)
  static String _escapeValue(Object value) {
    if (value is num || value is bool) return value.toString();
    return "'${value.toString().replaceAll("'", "''")}'";
  }
}
