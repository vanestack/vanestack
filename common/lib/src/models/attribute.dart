import 'package:dart_mappable/dart_mappable.dart';

part 'attribute.mapper.dart';

@MappableClass()
class ForeignKey with ForeignKeyMappable {
  final String table;
  final String column;
  final String? onDelete;
  final String? onUpdate;

  ForeignKey({
    required this.table,
    required this.column,
    this.onDelete,
    this.onUpdate,
  });
}

@MappableClass(discriminatorKey: 'type')
sealed class Attribute with AttributeMappable {
  final String name;
  final bool nullable;
  final bool unique;
  final bool primaryKey;
  final Object? defaultValue;
  final String? checkConstraint;
  final ForeignKey? foreignKey;

  Attribute({
    required this.name,
    this.nullable = true,
    this.unique = false,
    this.primaryKey = false,
    this.defaultValue,
    this.checkConstraint,
    this.foreignKey,
  });

  String get type => switch (this) {
    TextAttribute() => 'TEXT',
    IntAttribute() => 'INTEGER',
    DoubleAttribute() => 'REAL',
    BoolAttribute() => 'BOOL',
    DateAttribute() => 'DATE',
    JsonAttribute() => 'JSON',
  };
}

@MappableClass(discriminatorValue: 'TEXT')
class TextAttribute extends Attribute with TextAttributeMappable {
  TextAttribute({
    required super.name,
    super.nullable,
    super.unique,
    super.primaryKey,
    super.defaultValue,
    super.checkConstraint,
    super.foreignKey,
  });
}

@MappableClass(discriminatorValue: 'INTEGER')
class IntAttribute extends Attribute with IntAttributeMappable {
  IntAttribute({
    required super.name,
    super.nullable,
    super.unique,
    super.primaryKey,
    super.defaultValue,
    super.checkConstraint,
    super.foreignKey,
  });
}

@MappableClass(discriminatorValue: 'BOOL')
class BoolAttribute extends Attribute with BoolAttributeMappable {
  BoolAttribute({
    required super.name,
    super.nullable,
    super.unique,
    super.primaryKey,
    super.defaultValue,
    super.checkConstraint,
    super.foreignKey,
  });
}

@MappableClass(discriminatorValue: 'DATE')
class DateAttribute extends Attribute with DateAttributeMappable {
  DateAttribute({
    required super.name,
    super.nullable,
    super.unique,
    super.primaryKey,
    super.defaultValue,
    super.checkConstraint,
    super.foreignKey,
  });
}

@MappableClass(discriminatorValue: 'REAL')
class DoubleAttribute extends Attribute with DoubleAttributeMappable {
  DoubleAttribute({
    required super.name,
    super.nullable,
    super.unique,
    super.primaryKey,
    super.defaultValue,
    super.checkConstraint,
    super.foreignKey,
  });
}

@MappableClass(discriminatorValue: 'JSON')
class JsonAttribute extends Attribute with JsonAttributeMappable {
  JsonAttribute({
    required super.name,
    super.nullable,
    super.unique,
    super.primaryKey,
    super.defaultValue,
    super.checkConstraint,
    super.foreignKey,
  });
}
