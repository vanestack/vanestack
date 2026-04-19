import 'package:drift/drift.dart';
import 'package:vanestack/src/utils/filter_parser.dart';
import 'package:test/test.dart';

void main() {
  group('FilterParser', () {
    test('parses and filter', () {
      final parser = FilterParser(
        "(created_at >= 1760890169.015) AND (auth != 'admin')",
      );
      final (sql, params) = parser.parse();

      expect(sql, equals("(created_at >= ?) AND (auth != ?)"));
      expect(params, equals([1760890169.015, 'admin']));
    });

    test('parses simple equality filter', () {
      final parser = FilterParser("name = 'Alice'");
      final (sql, params) = parser.parse();

      expect(sql, equals("name = ?"));
      expect(params, equals(['Alice']));
    });

    test('parses numeric comparison', () {
      final parser = FilterParser("age > 25");
      final (sql, params) = parser.parse();

      expect(sql, equals("age > ?"));
      expect(params, equals([25]));
    });

    test('parses multiple AND conditions', () {
      final parser = FilterParser("age > 25 AND country = 'US'");
      final (sql, params) = parser.parse();

      expect(sql, equals("age > ? AND country = ?"));
      expect(params, equals([25, 'US']));
    });

    test('parses nested parentheses with OR', () {
      final parser = FilterParser(
        "(name = 'Alice' AND (age > 25 OR country = 'US'))",
      );
      final (sql, params) = parser.parse();

      expect(sql, equals("(name = ? AND (age > ? OR country = ?))"));
      expect(params, equals(['Alice', 25, 'US']));
    });

    test('parses quoted strings with spaces', () {
      final parser = FilterParser("name = 'John Doe'");
      final (sql, params) = parser.parse();

      expect(sql, equals("name = ?"));
      expect(params, equals(['John Doe']));
    });

    test('handles multiple nested groups', () {
      final parser = FilterParser(
        "((age > 30 AND country = 'US') OR (age < 18 AND country = 'UK'))",
      );
      final (sql, params) = parser.parse();

      expect(
        sql,
        equals("((age > ? AND country = ?) OR (age < ? AND country = ?))"),
      );
      expect(params, equals([30, 'US', 18, 'UK']));
    });

    test('parses inequality operator', () {
      final parser = FilterParser("status != 'inactive'");
      final (sql, params) = parser.parse();

      expect(sql, equals("status != ?"));
      expect(params, equals(['inactive']));
    });

    test('parses greater-than-or-equal operator', () {
      final parser = FilterParser("score >= 90");
      final (sql, params) = parser.parse();

      expect(sql, equals("score >= ?"));
      expect(params, equals([90]));
    });

    test('parses less-than-or-equal operator', () {
      final parser = FilterParser("score <= 50");
      final (sql, params) = parser.parse();

      expect(sql, equals("score <= ?"));
      expect(params, equals([50]));
    });

    test('handles empty input gracefully', () {
      final parser = FilterParser("");
      final (sql, params) = parser.parse();

      expect(sql, isEmpty);
      expect(params, isEmpty);
    });

    test('Handles LIKE operator', () {
      final parser = FilterParser("name LIKE 'J%n D%e'");
      final (sql, params) = parser.parse();

      expect(sql, equals("name LIKE ?"));
      expect(params, equals(['J%n D%e']));
    });

    test('Handles NOT LIKE operator', () {
      final parser = FilterParser("name NOT LIKE 'A%e'");
      final (sql, params) = parser.parse();

      expect(sql, equals("name NOT LIKE ?"));
      expect(params, equals(['A%e']));
    });

    test('preserves boolean literals as Dart bools', () {
      final (_, params) = FilterParser('super_user = true').parse();
      expect(params, equals([true]));
      expect(params.single, isA<bool>());

      final (_, falseParams) = FilterParser('super_user = false').parse();
      expect(falseParams, equals([false]));
      expect(falseParams.single, isA<bool>());
    });
  });

  group('toFilterVariable', () {
    test('wraps bool as Variable<bool> so postgres binds boolean', () {
      expect(toFilterVariable(true), isA<Variable<bool>>());
      expect(toFilterVariable(false), isA<Variable<bool>>());
    });

    test('wraps other primitives with the matching typed Variable', () {
      expect(toFilterVariable(42), isA<Variable<int>>());
      expect(toFilterVariable(3.14), isA<Variable<double>>());
      expect(toFilterVariable('hello'), isA<Variable<String>>());
    });
  });

  group('FilterParser field validation', () {
    test('accepts valid field names when allowedFields is set', () {
      final allowedFields = {'name', 'age', 'email'};
      final parser = FilterParser(
        "name = 'Alice' AND age > 25",
        allowedFields: allowedFields,
      );
      final (sql, params) = parser.parse();

      expect(sql, equals("name = ? AND age > ?"));
      expect(params, equals(['Alice', 25]));
    });

    test('throws FormatException for invalid field name', () {
      final allowedFields = {'name', 'age', 'email'};
      final parser = FilterParser(
        "invalid_field = 'test'",
        allowedFields: allowedFields,
      );

      expect(
        () => parser.parse(),
        throwsA(
          isA<FormatException>().having(
            (e) => e.message,
            'message',
            contains('Invalid field name in filter: invalid_field'),
          ),
        ),
      );
    });

    test('throws for SQL injection attempt with invalid field', () {
      final allowedFields = {'name', 'age'};

      // If someone tries field injection, it should be caught
      final parser = FilterParser(
        "malicious_field = 'value'",
        allowedFields: allowedFields,
      );

      expect(
        () => parser.parse(),
        throwsA(isA<FormatException>()),
      );
    });

    test('allows any field when allowedFields is null', () {
      final parser = FilterParser("any_field = 'value'");
      final (sql, params) = parser.parse();

      expect(sql, equals("any_field = ?"));
      expect(params, equals(['value']));
    });

    test('validates fields in nested expressions', () {
      final allowedFields = {'name', 'age'};
      final parser = FilterParser(
        "(name = 'Alice' AND (age > 25 OR invalid = 'test'))",
        allowedFields: allowedFields,
      );

      expect(
        () => parser.parse(),
        throwsA(
          isA<FormatException>().having(
            (e) => e.message,
            'message',
            contains('invalid'),
          ),
        ),
      );
    });

    test('validates fields with built-in collection fields', () {
      // Simulating collection attributes + built-in fields
      final allowedFields = {'id', 'created_at', 'updated_at', 'title', 'body'};
      final parser = FilterParser(
        "created_at >= 1234567890 AND title LIKE '%test%'",
        allowedFields: allowedFields,
      );
      final (sql, params) = parser.parse();

      expect(sql, equals("created_at >= ? AND title LIKE ?"));
      expect(params, equals([1234567890, '%test%']));
    });
  });
}
