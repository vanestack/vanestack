import 'dart:convert';

import 'package:vanestack_common/vanestack_common.dart';

import 'validation.dart';

class CollectionUtils {
  static const systemAttrs = {'id', 'created_at', 'updated_at'};

  /// Validates a user input map against the collection's attributes.
  /// Throws a [FormatException] if validation fails.
  static void validateCreate(
    Collection collection,
    Map<String, dynamic> input,
  ) {
    final attrMap = {for (var a in collection.attributes) a.name: a};

    for (final entry in input.entries) {
      final key = entry.key;
      final value = entry.value;

      // Handle system attributes
      if (key == 'id') {
        // allowed: present, null, or missing — nothing to validate
        if (value != null) {
          final valid = validateUuid(value);
          if (!valid) {
            throw FormatException('Attribute "id" must be a valid UUID');
          }
        }
        continue;
      } else if (key == 'created_at' || key == 'updated_at') {
        throw FormatException('Attribute "$key" cannot be set during create');
      }

      final attr = attrMap[key];
      if (attr == null) {
        throw FormatException('Unknown attribute: $key');
      }

      if (value == null) {
        if (!attr.nullable) {
          throw FormatException('Attribute "$key" cannot be null');
        }
        continue;
      }

      // Type checking
      switch (attr) {
        case TextAttribute():
          if (value is! String) {
            throw FormatException('Expected String for "$key"');
          }
          break;
        case IntAttribute():
          if (value is! int) {
            throw FormatException('Expected int for "$key"');
          }
          break;
        case DoubleAttribute():
          if (value is! num) {
            throw FormatException('Expected number for "$key"');
          }
          break;
        case BoolAttribute():
          if (value is! bool && value is! int) {
            throw FormatException('Expected bool or int for "$key"');
          }
          break;
        case DateAttribute():
          if (value is! DateTime && value is! int) {
            throw FormatException('Expected DateTime or epoch int for "$key"');
          }
          break;
        case JsonAttribute():
          if (value is! Map && value is! List && value is! String) {
            throw FormatException('Expected Map/List/JSON string for "$key"');
          }
          break;
      }
    }
  }

  /// Validates a user input map against the collection's attributes.
  /// Throws a [FormatException] if validation fails.
  static void validateUpdate(
    Collection collection,
    Map<String, dynamic> input,
  ) {
    final attrMap = {for (var a in collection.attributes) a.name: a};

    for (final entry in input.entries) {
      final key = entry.key;
      final value = entry.value;

      // System attributes are not allowed in updates
      if (systemAttrs.contains(key)) {
        throw FormatException('Attribute "$key" cannot be set during update');
      }

      final attr = attrMap[key];
      if (attr == null) {
        throw FormatException('Unknown attribute: $key');
      }

      if (value == null) {
        continue;
      }

      // Type checking
      switch (attr) {
        case TextAttribute():
          if (value is! String) {
            throw FormatException('Expected String for "$key"');
          }
          break;
        case IntAttribute():
          if (value is! int) {
            throw FormatException('Expected int for "$key"');
          }
          break;
        case DoubleAttribute():
          if (value is! num) {
            throw FormatException('Expected number for "$key"');
          }
          break;
        case BoolAttribute():
          if (value is! bool && value is! int) {
            throw FormatException('Expected bool or int for "$key"');
          }
          break;
        case DateAttribute():
          if (value is! DateTime && value is! int) {
            throw FormatException('Expected DateTime or epoch int for "$key"');
          }
          break;
        case JsonAttribute():
          if (value is! Map && value is! List && value is! String) {
            throw FormatException('Expected Map/List/JSON string for "$key"');
          }
          break;
      }
    }
  }

  /// Converts Dart-native values to database-compatible representations.
  static Map<String, dynamic> encodeForDb(
    Collection collection,
    Map<String, dynamic> input,
  ) {
    final attrMap = {for (var a in collection.attributes) a.name: a};

    final result = <String, dynamic>{};
    for (final entry in input.entries) {
      final attr = attrMap[entry.key];
      if (attr == null) continue;
      final value = entry.value;
      if (value == null) {
        result[entry.key] = null;
        continue;
      }

      result[entry.key] = switch (attr) {
        JsonAttribute() => value is String ? value : jsonEncode(value),
        BoolAttribute() => value is bool ? (value ? 1 : 0) : value,
        DateAttribute() =>
          value is DateTime ? value.millisecondsSinceEpoch ~/ 1000 : value,
        _ => value,
      };
    }

    return result;
  }

  /// Converts database rows to Dart-native types.
  static Map<String, dynamic> decodeFromDb(
    Collection collection,
    Map<String, dynamic> dbRow,
  ) {
    final attrMap = {for (var a in collection.attributes) a.name: a};

    final result = <String, dynamic>{};
    for (final entry in dbRow.entries) {
      final attr = attrMap[entry.key];
      if (attr == null) continue;
      final value = entry.value;

      if (value == null) {
        result[entry.key] = null;
        continue;
      }

      result[entry.key] = switch (attr) {
        JsonAttribute() => switch (value) {
          String v when v.trim().isEmpty => null,
          String v => jsonDecode(v),
          _ => null,
        },
        BoolAttribute() => switch (value) {
          int v when v == 0 => false,
          int v when v == 1 => true,
          _ => null,
        },
        DateAttribute() => switch (value) {
          String v when v.trim().isEmpty => null,
          String v =>
            int.tryParse(v) != null
                ? DateTime.fromMillisecondsSinceEpoch(int.parse(v) * 1000)
                : null,
          int v => DateTime.fromMillisecondsSinceEpoch(v * 1000),
          _ => null,
        },
        IntAttribute() => value is int ? value : null,
        DoubleAttribute() => value is num ? value.toDouble() : null,
        _ => value,
      };
    }

    return result;
  }

  static Document toDocument(
    Collection collection,
    Map<String, dynamic> dbRow,
  ) {
    final outputData = decodeFromDb(collection, dbRow);

    final id = outputData['id'];
    final createdAt = _toDateTime(outputData['created_at']);
    final updatedAt = _toDateTime(outputData['updated_at']);

    final outputDataCleaned = Map<String, dynamic>.from(outputData)
      ..remove('id')
      ..remove('created_at')
      ..remove('updated_at');

    return Document(
      id: id,
      collection: collection.name,
      createdAt: createdAt,
      updatedAt: updatedAt,
      data: outputDataCleaned,
    );
  }

  static Map<String, dynamic> documentToRow(
    Collection collection,
    Document document,
  ) {
    return encodeForDb(collection, {
      'id': document.id,
      'created_at': document.createdAt,
      'updated_at': document.updatedAt,
      ...document.data,
    });
  }

  static DateTime? _toDateTime(dynamic value) {
    if (value is DateTime) return value;
    if (value is int) return DateTime.fromMillisecondsSinceEpoch(value * 1000);
    return null;
  }
}
