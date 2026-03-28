import 'package:vanestack/src/utils/order_clause_parser.dart';
import 'package:test/test.dart';

void main() {
  group('OrderClauseParser', () {
    test('parses single field ascending (default)', () {
      final parser = OrderClauseParser('name');
      final (sql, parsed) = parser.parse();

      expect(sql, equals('ORDER BY name ASC'));
      expect(parsed, equals([('name', 'ASC')]));
    });

    test('parses single field descending with minus prefix', () {
      final parser = OrderClauseParser('-created_at');
      final (sql, parsed) = parser.parse();

      expect(sql, equals('ORDER BY created_at DESC'));
      expect(parsed, equals([('created_at', 'DESC')]));
    });

    test('parses single field ascending with plus prefix', () {
      final parser = OrderClauseParser('+score');
      final (sql, parsed) = parser.parse();

      expect(sql, equals('ORDER BY score ASC'));
      expect(parsed, equals([('score', 'ASC')]));
    });

    test('parses multiple fields', () {
      final parser = OrderClauseParser('name, -created_at, +score');
      final (sql, parsed) = parser.parse();

      expect(sql, equals('ORDER BY name ASC, created_at DESC, score ASC'));
      expect(
        parsed,
        equals([('name', 'ASC'), ('created_at', 'DESC'), ('score', 'ASC')]),
      );
    });

    test('handles empty input', () {
      final parser = OrderClauseParser('');
      final (sql, parsed) = parser.parse();

      expect(sql, isEmpty);
      expect(parsed, isEmpty);
    });

    test('handles whitespace-only input', () {
      final parser = OrderClauseParser('   ');
      final (sql, parsed) = parser.parse();

      expect(sql, isEmpty);
      expect(parsed, isEmpty);
    });

    test('throws FormatException for invalid SQL identifier', () {
      final parser = OrderClauseParser('invalid-field');

      expect(
        () => parser.parse(),
        throwsA(
          isA<FormatException>().having(
            (e) => e.message,
            'message',
            contains('Invalid field name'),
          ),
        ),
      );
    });

    test('throws FormatException for SQL injection attempt', () {
      final parser = OrderClauseParser('name; DROP TABLE users');

      expect(() => parser.parse(), throwsA(isA<FormatException>()));
    });
  });

  group('OrderClauseParser field validation', () {
    test('accepts valid field names when allowedFields is set', () {
      final allowedFields = {'name', 'created_at', 'score'};
      final parser = OrderClauseParser(
        'name, -created_at',
        allowedFields: allowedFields,
      );
      final (sql, parsed) = parser.parse();

      expect(sql, equals('ORDER BY name ASC, created_at DESC'));
      expect(parsed, equals([('name', 'ASC'), ('created_at', 'DESC')]));
    });

    test('throws FormatException for invalid field name', () {
      final allowedFields = {'name', 'age'};
      final parser = OrderClauseParser(
        'invalid_field',
        allowedFields: allowedFields,
      );

      expect(
        () => parser.parse(),
        throwsA(
          isA<FormatException>().having(
            (e) => e.message,
            'message',
            contains('Invalid field name in order clause: invalid_field'),
          ),
        ),
      );
    });

    test('throws for second invalid field in list', () {
      final allowedFields = {'name', 'age'};
      final parser = OrderClauseParser(
        'name, -invalid_field',
        allowedFields: allowedFields,
      );

      expect(
        () => parser.parse(),
        throwsA(
          isA<FormatException>().having(
            (e) => e.message,
            'message',
            contains('invalid_field'),
          ),
        ),
      );
    });

    test('allows any field when allowedFields is null', () {
      final parser = OrderClauseParser('any_field, -another_field');
      final (sql, parsed) = parser.parse();

      expect(sql, equals('ORDER BY any_field ASC, another_field DESC'));
      expect(
        parsed,
        equals([('any_field', 'ASC'), ('another_field', 'DESC')]),
      );
    });

    test('validates fields with built-in collection fields', () {
      final allowedFields = {'id', 'created_at', 'updated_at', 'title'};
      final parser = OrderClauseParser(
        '-created_at, title',
        allowedFields: allowedFields,
      );
      final (sql, parsed) = parser.parse();

      expect(sql, equals('ORDER BY created_at DESC, title ASC'));
      expect(parsed, equals([('created_at', 'DESC'), ('title', 'ASC')]));
    });

    test('rejects field not in schema even if valid SQL identifier', () {
      final allowedFields = {'name', 'email'};
      final parser = OrderClauseParser(
        'password',  // Valid identifier but not in allowed fields
        allowedFields: allowedFields,
      );

      expect(
        () => parser.parse(),
        throwsA(isA<FormatException>()),
      );
    });
  });
}
