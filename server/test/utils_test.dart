import 'package:vanestack/src/utils/auth.dart';
import 'package:vanestack/src/utils/tables.dart';
import 'package:vanestack/src/utils/validation.dart';
import 'package:dart_jsonwebtoken/dart_jsonwebtoken.dart';
import 'package:test/test.dart';

void main() {
  group('AuthUtils', () {
    group('hashPassword and verifyPassword', () {
      test('hashes password and verifies correctly', () async {
        const password = 'MySecurePassword123!';
        final hash = await AuthUtils.hashPassword(password);

        expect(hash, isNotEmpty);
        expect(hash, contains(':')); // Should have salt:hash format
        expect(await AuthUtils.verifyPassword(password, hash), isTrue);
      });

      test('different passwords produce different hashes', () async {
        final hash1 = await AuthUtils.hashPassword('Password1!');
        final hash2 = await AuthUtils.hashPassword('Password2!');

        expect(hash1, isNot(hash2));
      });

      test('same password produces different hashes (due to salt)', () async {
        final hash1 = await AuthUtils.hashPassword('SamePassword123!');
        final hash2 = await AuthUtils.hashPassword('SamePassword123!');

        expect(hash1, isNot(hash2));
        // But both should verify correctly
        expect(await AuthUtils.verifyPassword('SamePassword123!', hash1), isTrue);
        expect(await AuthUtils.verifyPassword('SamePassword123!', hash2), isTrue);
      });

      test('wrong password fails verification', () async {
        final hash = await AuthUtils.hashPassword('CorrectPassword123!');

        expect(await AuthUtils.verifyPassword('WrongPassword123!', hash), isFalse);
      });

      test('empty password hashes and verifies', () async {
        final hash = await AuthUtils.hashPassword('');

        expect(await AuthUtils.verifyPassword('', hash), isTrue);
        expect(await AuthUtils.verifyPassword('nonempty', hash), isFalse);
      });

      test('malformed hash returns false', () async {
        expect(await AuthUtils.verifyPassword('password', 'not-a-valid-hash'), isFalse);
        expect(await AuthUtils.verifyPassword('password', ''), isFalse);
        expect(await AuthUtils.verifyPassword('password', 'only-one-part'), isFalse);
      });

      test('handles unicode passwords', () async {
        const unicodePassword = 'Пароль123!'; // Russian word for "password"
        final hash = await AuthUtils.hashPassword(unicodePassword);

        expect(await AuthUtils.verifyPassword(unicodePassword, hash), isTrue);
        expect(await AuthUtils.verifyPassword('Password123!', hash), isFalse);
      });

      test('handles very long passwords', () async {
        final longPassword = 'A' * 1000 + '1!';
        final hash = await AuthUtils.hashPassword(longPassword);

        expect(await AuthUtils.verifyPassword(longPassword, hash), isTrue);
      });
    });

    group('generateJwt and verifyJwt', () {
      const testSecret = 'test-secret-key-for-testing';

      test('generates valid JWT', () {
        final token = AuthUtils.generateJwt(
          userId: 'user-123',
          jwtSecret: testSecret,
        );

        expect(token, isNotEmpty);
        expect(token.split('.').length, 3); // JWT has 3 parts
      });

      test('generated JWT can be verified', () {
        final token = AuthUtils.generateJwt(
          userId: 'user-123',
          email: 'test@example.com',
          jwtSecret: testSecret,
        );

        final payload = AuthUtils.verifyJwt(token, testSecret);

        expect(payload, isNotNull);
        expect(payload!['sub'], 'user-123');
        expect(payload['email'], 'test@example.com');
      });

      test('includes superuser claim', () {
        final token = AuthUtils.generateJwt(
          userId: 'admin-user',
          jwtSecret: testSecret,
          superuser: true,
        );

        final payload = AuthUtils.verifyJwt(token, testSecret);

        expect(payload!['superUser'], isTrue);
      });

      test('JWT with wrong secret fails verification', () {
        final token = AuthUtils.generateJwt(
          userId: 'user-123',
          jwtSecret: testSecret,
        );

        final payload = AuthUtils.verifyJwt(token, 'wrong-secret');

        expect(payload, isNull);
      });

      test('expired JWT throws JWTExpiredException', () {
        final token = AuthUtils.generateJwt(
          userId: 'user-123',
          jwtSecret: testSecret,
          expiry: const Duration(seconds: -1), // Already expired
        );

        expect(
          () => AuthUtils.verifyJwt(token, testSecret),
          throwsA(isA<JWTExpiredException>()),
        );
      });

      test('malformed JWT returns null', () {
        expect(AuthUtils.verifyJwt('not-a-jwt', testSecret), isNull);
        expect(AuthUtils.verifyJwt('a.b.c', testSecret), isNull);
        expect(AuthUtils.verifyJwt('', testSecret), isNull);
      });

      test('includes issuer claim', () {
        final token = AuthUtils.generateJwt(
          userId: 'user-123',
          jwtSecret: testSecret,
        );

        final jwt = JWT.verify(token, SecretKey(testSecret));
        expect(jwt.issuer, 'vanestack');
      });
    });

    group('generateRandomToken', () {
      test('generates token of default length', () {
        final token = AuthUtils.generateRandomToken();

        expect(token, isNotEmpty);
        // Base64 encoding of 32 bytes = ~43 characters
        expect(token.length, greaterThan(30));
      });

      test('generates different tokens each time', () {
        final token1 = AuthUtils.generateRandomToken();
        final token2 = AuthUtils.generateRandomToken();

        expect(token1, isNot(token2));
      });

      test('generates token of specified length', () {
        final shortToken = AuthUtils.generateRandomToken(length: 16);
        final longToken = AuthUtils.generateRandomToken(length: 64);

        // Longer input produces longer base64 output
        expect(longToken.length, greaterThan(shortToken.length));
      });
    });

    group('validatePasswordStrength', () {
      test('accepts strong password', () {
        final error = AuthUtils.validatePasswordStrength('MyStr0ng!Pass');
        expect(error, isNull);
      });

      test('rejects password shorter than 8 characters', () {
        final error = AuthUtils.validatePasswordStrength('Short1!');
        expect(error, contains('at least 8'));
      });

      test('rejects password without uppercase', () {
        final error = AuthUtils.validatePasswordStrength('password123!');
        expect(error, contains('uppercase'));
      });

      test('rejects password without lowercase', () {
        final error = AuthUtils.validatePasswordStrength('PASSWORD123!');
        expect(error, contains('lowercase'));
      });

      test('rejects password without number', () {
        final error = AuthUtils.validatePasswordStrength('PasswordOnly!');
        expect(error, contains('number'));
      });

      test('rejects password without special character', () {
        final error = AuthUtils.validatePasswordStrength('Password123');
        expect(error, contains('special character'));
      });

      test('rejects common passwords', () {
        final error1 = AuthUtils.validatePasswordStrength('Password1234!');
        expect(error1, contains('common'));

        final error2 = AuthUtils.validatePasswordStrength('MyQwerty123!');
        expect(error2, contains('common'));

        final error3 = AuthUtils.validatePasswordStrength('Admin123!@#');
        expect(error3, contains('common'));
      });

      test('accepts password with various special characters', () {
        expect(AuthUtils.validatePasswordStrength('Passw0rd!'), isNull);
        expect(AuthUtils.validatePasswordStrength('Passw0rd@'), isNull);
        expect(AuthUtils.validatePasswordStrength('Passw0rd#'), isNull);
        expect(AuthUtils.validatePasswordStrength('Passw0rd\$'), isNull);
        expect(AuthUtils.validatePasswordStrength('Passw0rd%'), isNull);
        expect(AuthUtils.validatePasswordStrength('Passw0rd^'), isNull);
        expect(AuthUtils.validatePasswordStrength('Passw0rd&'), isNull);
        expect(AuthUtils.validatePasswordStrength('Passw0rd*'), isNull);
        expect(AuthUtils.validatePasswordStrength('Passw0rd_'), isNull);
        expect(AuthUtils.validatePasswordStrength('Passw0rd-'), isNull);
      });
    });
  });

  group('Validation Utils', () {
    group('validateEmail', () {
      test('accepts valid emails', () {
        expect(validateEmail('user@example.com'), isTrue);
        expect(validateEmail('user.name@example.com'), isTrue);
        expect(validateEmail('user+tag@example.com'), isTrue);
        expect(validateEmail('user@subdomain.example.com'), isTrue);
        expect(validateEmail('user123@example.co.uk'), isTrue);
      });

      test('rejects invalid emails', () {
        expect(validateEmail(''), isFalse);
        expect(validateEmail('not-an-email'), isFalse);
        expect(validateEmail('user@'), isFalse);
        expect(validateEmail('@example.com'), isFalse);
        expect(validateEmail('user@.com'), isFalse);
        expect(validateEmail('user@example'), isFalse);
        expect(validateEmail('user @example.com'), isFalse);
      });

      test('trims whitespace', () {
        expect(validateEmail('  user@example.com  '), isTrue);
      });
    });

    group('validateUuid', () {
      test('accepts valid UUIDs', () {
        expect(validateUuid('550e8400-e29b-41d4-a716-446655440000'), isTrue);
        expect(validateUuid('6ba7b810-9dad-11d1-80b4-00c04fd430c8'), isTrue);
        expect(validateUuid('f47ac10b-58cc-4372-a567-0e02b2c3d479'), isTrue);
      });

      test('rejects invalid UUIDs', () {
        expect(validateUuid(''), isFalse);
        expect(validateUuid('not-a-uuid'), isFalse);
        expect(validateUuid('550e8400-e29b-41d4-a716'), isFalse); // Too short
        expect(validateUuid('550e8400-e29b-41d4-a716-446655440000-extra'), isFalse);
        expect(validateUuid('gggggggg-gggg-gggg-gggg-gggggggggggg'), isFalse);
      });
    });

    group('validateUrlFriendlyName', () {
      test('accepts valid names', () {
        expect(validateUrlFriendlyName('mybucket'), isTrue);
        expect(validateUrlFriendlyName('my_bucket'), isTrue);
        expect(validateUrlFriendlyName('bucket123'), isTrue);
        expect(validateUrlFriendlyName('my_bucket_123'), isTrue);
      });

      test('rejects names starting with number', () {
        expect(validateUrlFriendlyName('123bucket'), isFalse);
        expect(validateUrlFriendlyName('1_bucket'), isFalse);
      });

      test('rejects names with uppercase', () {
        expect(validateUrlFriendlyName('MyBucket'), isFalse);
        expect(validateUrlFriendlyName('BUCKET'), isFalse);
      });

      test('rejects names with special characters', () {
        expect(validateUrlFriendlyName('my-bucket'), isFalse);
        expect(validateUrlFriendlyName('my.bucket'), isFalse);
        expect(validateUrlFriendlyName('my bucket'), isFalse);
        expect(validateUrlFriendlyName('bucket!'), isFalse);
      });

      test('rejects empty name', () {
        expect(validateUrlFriendlyName(''), isFalse);
      });
    });
  });

  group('Tables Utils', () {
    group('isValidIdentifier', () {
      test('accepts valid identifiers', () {
        expect(isValidIdentifier('users'), isTrue);
        expect(isValidIdentifier('my_table'), isTrue);
        expect(isValidIdentifier('table123'), isTrue);
        expect(isValidIdentifier('a'), isTrue);
      });

      test('rejects identifiers starting with number', () {
        expect(isValidIdentifier('123table'), isFalse);
        expect(isValidIdentifier('1table'), isFalse);
      });

      test('rejects identifiers with uppercase', () {
        expect(isValidIdentifier('MyTable'), isFalse);
        expect(isValidIdentifier('TABLE'), isFalse);
      });

      test('rejects identifiers with special characters', () {
        expect(isValidIdentifier('my-table'), isFalse);
        expect(isValidIdentifier('my.table'), isFalse);
        expect(isValidIdentifier('my table'), isFalse);
      });

      test('rejects empty identifier', () {
        expect(isValidIdentifier(''), isFalse);
      });

      test('rejects SQL keywords', () {
        expect(isValidIdentifier('select'), isFalse);
        expect(isValidIdentifier('from'), isFalse);
        expect(isValidIdentifier('where'), isFalse);
        expect(isValidIdentifier('table'), isFalse);
        expect(isValidIdentifier('index'), isFalse);
        expect(isValidIdentifier('create'), isFalse);
        expect(isValidIdentifier('drop'), isFalse);
        expect(isValidIdentifier('insert'), isFalse);
        expect(isValidIdentifier('update'), isFalse);
        expect(isValidIdentifier('delete'), isFalse);
        expect(isValidIdentifier('join'), isFalse);
        expect(isValidIdentifier('order'), isFalse);
        expect(isValidIdentifier('group'), isFalse);
        expect(isValidIdentifier('having'), isFalse);
        expect(isValidIdentifier('limit'), isFalse);
        expect(isValidIdentifier('offset'), isFalse);
        expect(isValidIdentifier('union'), isFalse);
        expect(isValidIdentifier('except'), isFalse);
        expect(isValidIdentifier('intersect'), isFalse);
        expect(isValidIdentifier('null'), isFalse);
        expect(isValidIdentifier('primary'), isFalse);
        expect(isValidIdentifier('foreign'), isFalse);
        expect(isValidIdentifier('references'), isFalse);
        expect(isValidIdentifier('constraint'), isFalse);
        expect(isValidIdentifier('unique'), isFalse);
        expect(isValidIdentifier('check'), isFalse);
        expect(isValidIdentifier('default'), isFalse);
        expect(isValidIdentifier('cascade'), isFalse);
        expect(isValidIdentifier('trigger'), isFalse);
        expect(isValidIdentifier('view'), isFalse);
        expect(isValidIdentifier('transaction'), isFalse);
        expect(isValidIdentifier('commit'), isFalse);
        expect(isValidIdentifier('rollback'), isFalse);
      });

      test('accepts words similar to but not SQL keywords', () {
        expect(isValidIdentifier('selected'), isTrue);
        expect(isValidIdentifier('selections'), isTrue);
        expect(isValidIdentifier('tables'), isTrue);
        expect(isValidIdentifier('indexes'), isTrue); // 'indexed' is a keyword, but 'indexes' is not
        expect(isValidIdentifier('created'), isTrue);
        expect(isValidIdentifier('updated'), isTrue);
        expect(isValidIdentifier('deleted'), isTrue);
        expect(isValidIdentifier('users'), isTrue);
        expect(isValidIdentifier('ordered'), isTrue);
        expect(isValidIdentifier('grouped'), isTrue);
      });
    });

    group('isValidColumnType', () {
      test('accepts valid column types', () {
        expect(isValidColumnType('TEXT'), isTrue);
        expect(isValidColumnType('INTEGER'), isTrue);
        expect(isValidColumnType('REAL'), isTrue);
        expect(isValidColumnType('BLOB'), isTrue);
        expect(isValidColumnType('NUMERIC'), isTrue);
        expect(isValidColumnType('VARCHAR'), isTrue);
        expect(isValidColumnType('CHAR'), isTrue);
        expect(isValidColumnType('BOOLEAN'), isTrue);
        expect(isValidColumnType('DATE'), isTrue);
        expect(isValidColumnType('DATETIME'), isTrue);
      });

      test('accepts lowercase types', () {
        expect(isValidColumnType('text'), isTrue);
        expect(isValidColumnType('integer'), isTrue);
        expect(isValidColumnType('real'), isTrue);
      });

      test('rejects invalid types', () {
        expect(isValidColumnType('STRING'), isFalse);
        expect(isValidColumnType('INT'), isFalse);
        expect(isValidColumnType('FLOAT'), isFalse);
        expect(isValidColumnType('UNKNOWN'), isFalse);
        expect(isValidColumnType(''), isFalse);
      });
    });
  });
}
