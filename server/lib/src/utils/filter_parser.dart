import 'package:drift/drift.dart';

/// Wraps a parsed filter parameter in a typed [Variable] so drift binds the
/// correct SQL type — critical on postgres, where a bool column compared with
/// a bigint parameter raises `operator does not exist: boolean = bigint`.
Variable toFilterVariable(Object? value) {
  if (value is bool) return Variable<bool>(value);
  if (value is int) return Variable<int>(value);
  if (value is double) return Variable<double>(value);
  if (value is String) return Variable<String>(value);
  return Variable(value);
}

class FilterParser {
  final String input;

  /// Optional set of allowed field names for validation.
  /// If provided, field names not in this set will throw FormatException.
  final Set<String>? allowedFields;

  int _pos = 0;
  late final RegExp _tokenPattern = RegExp(
    r"\s*(\(|\)|AND|OR|NOT|LIKE|true|false|[A-Za-z_][A-Za-z0-9_]*|!=|>=|<=|=|>|<|'[^']*'|\d*\.\d+|\d+)\s*",
    caseSensitive: false,
  );

  FilterParser(this.input, {this.allowedFields});

  (String, List<Object?>) parse() {
    final (sql, params) = _parseExpr();
    return (sql, params);
  }

  (String, List<Object?>) _parseExpr() {
    final parts = <String>[];
    final params = <Object?>[];

    while (_pos < input.length) {
      final token = _nextToken();
      if (token == null) break;

      if (token == '(') {
        final (subSql, subParams) = _parseExpr();
        parts.add('($subSql)');
        params.addAll(subParams);
      } else if (token == ')') {
        break;
      } else if (token.toUpperCase() == 'AND' || token.toUpperCase() == 'OR') {
        parts.add(token.toUpperCase());
      } else {
        // Expect a field op value pattern like: age > 25
        final field = token;

        // Validate field name against allowed fields
        if (allowedFields != null && !allowedFields!.contains(field)) {
          throw FormatException('Invalid field name in filter: $field');
        }

        var op = _nextToken()?.toUpperCase() ?? '=';

        if (op == 'NOT') {
          final next = _nextToken()?.toUpperCase();
          op = 'NOT $next';
        }

        final valueToken = _nextToken();
        if (valueToken == null) break;

        Object? value = valueToken;
        if (valueToken.startsWith("'")) {
          // String literal: strip quotes
          value = valueToken.substring(1, valueToken.length - 1);
        } else if (valueToken.toLowerCase() == 'true') {
          value = true;
        } else if (valueToken.toLowerCase() == 'false') {
          value = false;
        } else if (RegExp(r'^\d+\.\d+$').hasMatch(valueToken)) {
          // Floating-point number
          value = double.parse(valueToken);
        } else if (RegExp(r'^\d+$').hasMatch(valueToken)) {
          // Integer
          value = int.parse(valueToken);
        }

        parts.add('$field $op ?');
        params.add(value);
      }
    }

    return (parts.join(' '), params);
  }

  String? _nextToken() {
    final match = _tokenPattern.matchAsPrefix(input, _pos);
    if (match == null) return null;
    _pos = match.end;
    return match.group(1);
  }
}
