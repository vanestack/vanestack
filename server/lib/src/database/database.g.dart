// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'database.dart';

// ignore_for_file: type=lint
class $UsersTable extends Users with TableInfo<$UsersTable, DbUser> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $UsersTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _emailMeta = const VerificationMeta('email');
  @override
  late final GeneratedColumn<String> email = GeneratedColumn<String>(
    'email',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways('UNIQUE'),
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _superUserMeta = const VerificationMeta(
    'superUser',
  );
  @override
  late final GeneratedColumn<bool> superUser = GeneratedColumn<bool>(
    'super_user',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintsDependsOnDialect({
      SqlDialect.sqlite: 'CHECK ("super_user" IN (0, 1))',
      SqlDialect.postgres: '',
    }),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _passwordHashMeta = const VerificationMeta(
    'passwordHash',
  );
  @override
  late final GeneratedColumn<String> passwordHash = GeneratedColumn<String>(
    'password_hash',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    email,
    name,
    superUser,
    passwordHash,
    createdAt,
    updatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = '_users';
  @override
  VerificationContext validateIntegrity(
    Insertable<DbUser> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('email')) {
      context.handle(
        _emailMeta,
        email.isAcceptableOrUnknown(data['email']!, _emailMeta),
      );
    } else if (isInserting) {
      context.missing(_emailMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    }
    if (data.containsKey('super_user')) {
      context.handle(
        _superUserMeta,
        superUser.isAcceptableOrUnknown(data['super_user']!, _superUserMeta),
      );
    }
    if (data.containsKey('password_hash')) {
      context.handle(
        _passwordHashMeta,
        passwordHash.isAcceptableOrUnknown(
          data['password_hash']!,
          _passwordHashMeta,
        ),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  DbUser map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return DbUser(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      email: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}email'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      ),
      superUser: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}super_user'],
      )!,
      passwordHash: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}password_hash'],
      ),
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
    );
  }

  @override
  $UsersTable createAlias(String alias) {
    return $UsersTable(attachedDatabase, alias);
  }
}

class DbUser extends DataClass implements Insertable<DbUser> {
  final String id;
  final String email;
  final String? name;
  final bool superUser;
  final String? passwordHash;
  final DateTime createdAt;
  final DateTime updatedAt;
  const DbUser({
    required this.id,
    required this.email,
    this.name,
    required this.superUser,
    this.passwordHash,
    required this.createdAt,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['email'] = Variable<String>(email);
    if (!nullToAbsent || name != null) {
      map['name'] = Variable<String>(name);
    }
    map['super_user'] = Variable<bool>(superUser);
    if (!nullToAbsent || passwordHash != null) {
      map['password_hash'] = Variable<String>(passwordHash);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  UsersCompanion toCompanion(bool nullToAbsent) {
    return UsersCompanion(
      id: Value(id),
      email: Value(email),
      name: name == null && nullToAbsent ? const Value.absent() : Value(name),
      superUser: Value(superUser),
      passwordHash: passwordHash == null && nullToAbsent
          ? const Value.absent()
          : Value(passwordHash),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
    );
  }

  factory DbUser.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return DbUser(
      id: serializer.fromJson<String>(json['id']),
      email: serializer.fromJson<String>(json['email']),
      name: serializer.fromJson<String?>(json['name']),
      superUser: serializer.fromJson<bool>(json['superUser']),
      passwordHash: serializer.fromJson<String?>(json['passwordHash']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'email': serializer.toJson<String>(email),
      'name': serializer.toJson<String?>(name),
      'superUser': serializer.toJson<bool>(superUser),
      'passwordHash': serializer.toJson<String?>(passwordHash),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  DbUser copyWith({
    String? id,
    String? email,
    Value<String?> name = const Value.absent(),
    bool? superUser,
    Value<String?> passwordHash = const Value.absent(),
    DateTime? createdAt,
    DateTime? updatedAt,
  }) => DbUser(
    id: id ?? this.id,
    email: email ?? this.email,
    name: name.present ? name.value : this.name,
    superUser: superUser ?? this.superUser,
    passwordHash: passwordHash.present ? passwordHash.value : this.passwordHash,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
  );
  DbUser copyWithCompanion(UsersCompanion data) {
    return DbUser(
      id: data.id.present ? data.id.value : this.id,
      email: data.email.present ? data.email.value : this.email,
      name: data.name.present ? data.name.value : this.name,
      superUser: data.superUser.present ? data.superUser.value : this.superUser,
      passwordHash: data.passwordHash.present
          ? data.passwordHash.value
          : this.passwordHash,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('DbUser(')
          ..write('id: $id, ')
          ..write('email: $email, ')
          ..write('name: $name, ')
          ..write('superUser: $superUser, ')
          ..write('passwordHash: $passwordHash, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    email,
    name,
    superUser,
    passwordHash,
    createdAt,
    updatedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is DbUser &&
          other.id == this.id &&
          other.email == this.email &&
          other.name == this.name &&
          other.superUser == this.superUser &&
          other.passwordHash == this.passwordHash &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt);
}

class UsersCompanion extends UpdateCompanion<DbUser> {
  final Value<String> id;
  final Value<String> email;
  final Value<String?> name;
  final Value<bool> superUser;
  final Value<String?> passwordHash;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<int> rowid;
  const UsersCompanion({
    this.id = const Value.absent(),
    this.email = const Value.absent(),
    this.name = const Value.absent(),
    this.superUser = const Value.absent(),
    this.passwordHash = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  UsersCompanion.insert({
    required String id,
    required String email,
    this.name = const Value.absent(),
    this.superUser = const Value.absent(),
    this.passwordHash = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       email = Value(email);
  static Insertable<DbUser> custom({
    Expression<String>? id,
    Expression<String>? email,
    Expression<String>? name,
    Expression<bool>? superUser,
    Expression<String>? passwordHash,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (email != null) 'email': email,
      if (name != null) 'name': name,
      if (superUser != null) 'super_user': superUser,
      if (passwordHash != null) 'password_hash': passwordHash,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  UsersCompanion copyWith({
    Value<String>? id,
    Value<String>? email,
    Value<String?>? name,
    Value<bool>? superUser,
    Value<String?>? passwordHash,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
    Value<int>? rowid,
  }) {
    return UsersCompanion(
      id: id ?? this.id,
      email: email ?? this.email,
      name: name ?? this.name,
      superUser: superUser ?? this.superUser,
      passwordHash: passwordHash ?? this.passwordHash,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (email.present) {
      map['email'] = Variable<String>(email.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (superUser.present) {
      map['super_user'] = Variable<bool>(superUser.value);
    }
    if (passwordHash.present) {
      map['password_hash'] = Variable<String>(passwordHash.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('UsersCompanion(')
          ..write('id: $id, ')
          ..write('email: $email, ')
          ..write('name: $name, ')
          ..write('superUser: $superUser, ')
          ..write('passwordHash: $passwordHash, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $RefreshTokensTable extends RefreshTokens
    with TableInfo<$RefreshTokensTable, RefreshToken> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $RefreshTokensTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _userIdMeta = const VerificationMeta('userId');
  @override
  late final GeneratedColumn<String> userId = GeneratedColumn<String>(
    'user_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _refreshTokenMeta = const VerificationMeta(
    'refreshToken',
  );
  @override
  late final GeneratedColumn<String> refreshToken = GeneratedColumn<String>(
    'refresh_token',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways('UNIQUE'),
  );
  static const VerificationMeta _accessTokenMeta = const VerificationMeta(
    'accessToken',
  );
  @override
  late final GeneratedColumn<String> accessToken = GeneratedColumn<String>(
    'access_token',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  static const VerificationMeta _expiresAtMeta = const VerificationMeta(
    'expiresAt',
  );
  @override
  late final GeneratedColumn<DateTime> expiresAt = GeneratedColumn<DateTime>(
    'expires_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    clientDefault: () => DateTime.now().add(const Duration(days: 7)),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    userId,
    refreshToken,
    accessToken,
    createdAt,
    expiresAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = '_refresh_tokens';
  @override
  VerificationContext validateIntegrity(
    Insertable<RefreshToken> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('user_id')) {
      context.handle(
        _userIdMeta,
        userId.isAcceptableOrUnknown(data['user_id']!, _userIdMeta),
      );
    } else if (isInserting) {
      context.missing(_userIdMeta);
    }
    if (data.containsKey('refresh_token')) {
      context.handle(
        _refreshTokenMeta,
        refreshToken.isAcceptableOrUnknown(
          data['refresh_token']!,
          _refreshTokenMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_refreshTokenMeta);
    }
    if (data.containsKey('access_token')) {
      context.handle(
        _accessTokenMeta,
        accessToken.isAcceptableOrUnknown(
          data['access_token']!,
          _accessTokenMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_accessTokenMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    }
    if (data.containsKey('expires_at')) {
      context.handle(
        _expiresAtMeta,
        expiresAt.isAcceptableOrUnknown(data['expires_at']!, _expiresAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  RefreshToken map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return RefreshToken(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      userId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}user_id'],
      )!,
      refreshToken: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}refresh_token'],
      )!,
      accessToken: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}access_token'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      expiresAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}expires_at'],
      )!,
    );
  }

  @override
  $RefreshTokensTable createAlias(String alias) {
    return $RefreshTokensTable(attachedDatabase, alias);
  }
}

class RefreshToken extends DataClass implements Insertable<RefreshToken> {
  final int id;
  final String userId;
  final String refreshToken;
  final String accessToken;
  final DateTime createdAt;
  final DateTime expiresAt;
  const RefreshToken({
    required this.id,
    required this.userId,
    required this.refreshToken,
    required this.accessToken,
    required this.createdAt,
    required this.expiresAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['user_id'] = Variable<String>(userId);
    map['refresh_token'] = Variable<String>(refreshToken);
    map['access_token'] = Variable<String>(accessToken);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['expires_at'] = Variable<DateTime>(expiresAt);
    return map;
  }

  RefreshTokensCompanion toCompanion(bool nullToAbsent) {
    return RefreshTokensCompanion(
      id: Value(id),
      userId: Value(userId),
      refreshToken: Value(refreshToken),
      accessToken: Value(accessToken),
      createdAt: Value(createdAt),
      expiresAt: Value(expiresAt),
    );
  }

  factory RefreshToken.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return RefreshToken(
      id: serializer.fromJson<int>(json['id']),
      userId: serializer.fromJson<String>(json['userId']),
      refreshToken: serializer.fromJson<String>(json['refreshToken']),
      accessToken: serializer.fromJson<String>(json['accessToken']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      expiresAt: serializer.fromJson<DateTime>(json['expiresAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'userId': serializer.toJson<String>(userId),
      'refreshToken': serializer.toJson<String>(refreshToken),
      'accessToken': serializer.toJson<String>(accessToken),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'expiresAt': serializer.toJson<DateTime>(expiresAt),
    };
  }

  RefreshToken copyWith({
    int? id,
    String? userId,
    String? refreshToken,
    String? accessToken,
    DateTime? createdAt,
    DateTime? expiresAt,
  }) => RefreshToken(
    id: id ?? this.id,
    userId: userId ?? this.userId,
    refreshToken: refreshToken ?? this.refreshToken,
    accessToken: accessToken ?? this.accessToken,
    createdAt: createdAt ?? this.createdAt,
    expiresAt: expiresAt ?? this.expiresAt,
  );
  RefreshToken copyWithCompanion(RefreshTokensCompanion data) {
    return RefreshToken(
      id: data.id.present ? data.id.value : this.id,
      userId: data.userId.present ? data.userId.value : this.userId,
      refreshToken: data.refreshToken.present
          ? data.refreshToken.value
          : this.refreshToken,
      accessToken: data.accessToken.present
          ? data.accessToken.value
          : this.accessToken,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      expiresAt: data.expiresAt.present ? data.expiresAt.value : this.expiresAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('RefreshToken(')
          ..write('id: $id, ')
          ..write('userId: $userId, ')
          ..write('refreshToken: $refreshToken, ')
          ..write('accessToken: $accessToken, ')
          ..write('createdAt: $createdAt, ')
          ..write('expiresAt: $expiresAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, userId, refreshToken, accessToken, createdAt, expiresAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is RefreshToken &&
          other.id == this.id &&
          other.userId == this.userId &&
          other.refreshToken == this.refreshToken &&
          other.accessToken == this.accessToken &&
          other.createdAt == this.createdAt &&
          other.expiresAt == this.expiresAt);
}

class RefreshTokensCompanion extends UpdateCompanion<RefreshToken> {
  final Value<int> id;
  final Value<String> userId;
  final Value<String> refreshToken;
  final Value<String> accessToken;
  final Value<DateTime> createdAt;
  final Value<DateTime> expiresAt;
  const RefreshTokensCompanion({
    this.id = const Value.absent(),
    this.userId = const Value.absent(),
    this.refreshToken = const Value.absent(),
    this.accessToken = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.expiresAt = const Value.absent(),
  });
  RefreshTokensCompanion.insert({
    this.id = const Value.absent(),
    required String userId,
    required String refreshToken,
    required String accessToken,
    this.createdAt = const Value.absent(),
    this.expiresAt = const Value.absent(),
  }) : userId = Value(userId),
       refreshToken = Value(refreshToken),
       accessToken = Value(accessToken);
  static Insertable<RefreshToken> custom({
    Expression<int>? id,
    Expression<String>? userId,
    Expression<String>? refreshToken,
    Expression<String>? accessToken,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? expiresAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (userId != null) 'user_id': userId,
      if (refreshToken != null) 'refresh_token': refreshToken,
      if (accessToken != null) 'access_token': accessToken,
      if (createdAt != null) 'created_at': createdAt,
      if (expiresAt != null) 'expires_at': expiresAt,
    });
  }

  RefreshTokensCompanion copyWith({
    Value<int>? id,
    Value<String>? userId,
    Value<String>? refreshToken,
    Value<String>? accessToken,
    Value<DateTime>? createdAt,
    Value<DateTime>? expiresAt,
  }) {
    return RefreshTokensCompanion(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      refreshToken: refreshToken ?? this.refreshToken,
      accessToken: accessToken ?? this.accessToken,
      createdAt: createdAt ?? this.createdAt,
      expiresAt: expiresAt ?? this.expiresAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (userId.present) {
      map['user_id'] = Variable<String>(userId.value);
    }
    if (refreshToken.present) {
      map['refresh_token'] = Variable<String>(refreshToken.value);
    }
    if (accessToken.present) {
      map['access_token'] = Variable<String>(accessToken.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (expiresAt.present) {
      map['expires_at'] = Variable<DateTime>(expiresAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('RefreshTokensCompanion(')
          ..write('id: $id, ')
          ..write('userId: $userId, ')
          ..write('refreshToken: $refreshToken, ')
          ..write('accessToken: $accessToken, ')
          ..write('createdAt: $createdAt, ')
          ..write('expiresAt: $expiresAt')
          ..write(')'))
        .toString();
  }
}

class $ResetPasswordTokensTable extends ResetPasswordTokens
    with TableInfo<$ResetPasswordTokensTable, ResetPasswordToken> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ResetPasswordTokensTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _userIdMeta = const VerificationMeta('userId');
  @override
  late final GeneratedColumn<String> userId = GeneratedColumn<String>(
    'user_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _tokenMeta = const VerificationMeta('token');
  @override
  late final GeneratedColumn<String> token = GeneratedColumn<String>(
    'token',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  static const VerificationMeta _expiresAtMeta = const VerificationMeta(
    'expiresAt',
  );
  @override
  late final GeneratedColumn<DateTime> expiresAt = GeneratedColumn<DateTime>(
    'expires_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    clientDefault: () => DateTime.now().add(const Duration(minutes: 30)),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    userId,
    token,
    createdAt,
    expiresAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = '_reset_password_tokens';
  @override
  VerificationContext validateIntegrity(
    Insertable<ResetPasswordToken> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('user_id')) {
      context.handle(
        _userIdMeta,
        userId.isAcceptableOrUnknown(data['user_id']!, _userIdMeta),
      );
    } else if (isInserting) {
      context.missing(_userIdMeta);
    }
    if (data.containsKey('token')) {
      context.handle(
        _tokenMeta,
        token.isAcceptableOrUnknown(data['token']!, _tokenMeta),
      );
    } else if (isInserting) {
      context.missing(_tokenMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    }
    if (data.containsKey('expires_at')) {
      context.handle(
        _expiresAtMeta,
        expiresAt.isAcceptableOrUnknown(data['expires_at']!, _expiresAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  ResetPasswordToken map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ResetPasswordToken(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      userId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}user_id'],
      )!,
      token: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}token'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      expiresAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}expires_at'],
      )!,
    );
  }

  @override
  $ResetPasswordTokensTable createAlias(String alias) {
    return $ResetPasswordTokensTable(attachedDatabase, alias);
  }
}

class ResetPasswordToken extends DataClass
    implements Insertable<ResetPasswordToken> {
  final int id;
  final String userId;
  final String token;
  final DateTime createdAt;
  final DateTime expiresAt;
  const ResetPasswordToken({
    required this.id,
    required this.userId,
    required this.token,
    required this.createdAt,
    required this.expiresAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['user_id'] = Variable<String>(userId);
    map['token'] = Variable<String>(token);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['expires_at'] = Variable<DateTime>(expiresAt);
    return map;
  }

  ResetPasswordTokensCompanion toCompanion(bool nullToAbsent) {
    return ResetPasswordTokensCompanion(
      id: Value(id),
      userId: Value(userId),
      token: Value(token),
      createdAt: Value(createdAt),
      expiresAt: Value(expiresAt),
    );
  }

  factory ResetPasswordToken.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ResetPasswordToken(
      id: serializer.fromJson<int>(json['id']),
      userId: serializer.fromJson<String>(json['userId']),
      token: serializer.fromJson<String>(json['token']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      expiresAt: serializer.fromJson<DateTime>(json['expiresAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'userId': serializer.toJson<String>(userId),
      'token': serializer.toJson<String>(token),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'expiresAt': serializer.toJson<DateTime>(expiresAt),
    };
  }

  ResetPasswordToken copyWith({
    int? id,
    String? userId,
    String? token,
    DateTime? createdAt,
    DateTime? expiresAt,
  }) => ResetPasswordToken(
    id: id ?? this.id,
    userId: userId ?? this.userId,
    token: token ?? this.token,
    createdAt: createdAt ?? this.createdAt,
    expiresAt: expiresAt ?? this.expiresAt,
  );
  ResetPasswordToken copyWithCompanion(ResetPasswordTokensCompanion data) {
    return ResetPasswordToken(
      id: data.id.present ? data.id.value : this.id,
      userId: data.userId.present ? data.userId.value : this.userId,
      token: data.token.present ? data.token.value : this.token,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      expiresAt: data.expiresAt.present ? data.expiresAt.value : this.expiresAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ResetPasswordToken(')
          ..write('id: $id, ')
          ..write('userId: $userId, ')
          ..write('token: $token, ')
          ..write('createdAt: $createdAt, ')
          ..write('expiresAt: $expiresAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, userId, token, createdAt, expiresAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ResetPasswordToken &&
          other.id == this.id &&
          other.userId == this.userId &&
          other.token == this.token &&
          other.createdAt == this.createdAt &&
          other.expiresAt == this.expiresAt);
}

class ResetPasswordTokensCompanion extends UpdateCompanion<ResetPasswordToken> {
  final Value<int> id;
  final Value<String> userId;
  final Value<String> token;
  final Value<DateTime> createdAt;
  final Value<DateTime> expiresAt;
  const ResetPasswordTokensCompanion({
    this.id = const Value.absent(),
    this.userId = const Value.absent(),
    this.token = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.expiresAt = const Value.absent(),
  });
  ResetPasswordTokensCompanion.insert({
    this.id = const Value.absent(),
    required String userId,
    required String token,
    this.createdAt = const Value.absent(),
    this.expiresAt = const Value.absent(),
  }) : userId = Value(userId),
       token = Value(token);
  static Insertable<ResetPasswordToken> custom({
    Expression<int>? id,
    Expression<String>? userId,
    Expression<String>? token,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? expiresAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (userId != null) 'user_id': userId,
      if (token != null) 'token': token,
      if (createdAt != null) 'created_at': createdAt,
      if (expiresAt != null) 'expires_at': expiresAt,
    });
  }

  ResetPasswordTokensCompanion copyWith({
    Value<int>? id,
    Value<String>? userId,
    Value<String>? token,
    Value<DateTime>? createdAt,
    Value<DateTime>? expiresAt,
  }) {
    return ResetPasswordTokensCompanion(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      token: token ?? this.token,
      createdAt: createdAt ?? this.createdAt,
      expiresAt: expiresAt ?? this.expiresAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (userId.present) {
      map['user_id'] = Variable<String>(userId.value);
    }
    if (token.present) {
      map['token'] = Variable<String>(token.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (expiresAt.present) {
      map['expires_at'] = Variable<DateTime>(expiresAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ResetPasswordTokensCompanion(')
          ..write('id: $id, ')
          ..write('userId: $userId, ')
          ..write('token: $token, ')
          ..write('createdAt: $createdAt, ')
          ..write('expiresAt: $expiresAt')
          ..write(')'))
        .toString();
  }
}

class $LogsTable extends Logs with TableInfo<$LogsTable, AppLog> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $LogsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  @override
  late final GeneratedColumnWithTypeConverter<LogLevel, String> level =
      GeneratedColumn<String>(
        'level',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      ).withConverter<LogLevel>($LogsTable.$converterlevel);
  @override
  late final GeneratedColumnWithTypeConverter<LogSource, String> source =
      GeneratedColumn<String>(
        'source',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      ).withConverter<LogSource>($LogsTable.$convertersource);
  static const VerificationMeta _customSourceMeta = const VerificationMeta(
    'customSource',
  );
  @override
  late final GeneratedColumn<String> customSource = GeneratedColumn<String>(
    'custom_source',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _messageMeta = const VerificationMeta(
    'message',
  );
  @override
  late final GeneratedColumn<String> message = GeneratedColumn<String>(
    'message',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _contextMeta = const VerificationMeta(
    'context',
  );
  @override
  late final GeneratedColumn<String> context = GeneratedColumn<String>(
    'context',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _userIdMeta = const VerificationMeta('userId');
  @override
  late final GeneratedColumn<String> userId = GeneratedColumn<String>(
    'user_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _errorMeta = const VerificationMeta('error');
  @override
  late final GeneratedColumn<String> error = GeneratedColumn<String>(
    'error',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _stackTraceMeta = const VerificationMeta(
    'stackTrace',
  );
  @override
  late final GeneratedColumn<String> stackTrace = GeneratedColumn<String>(
    'stack_trace',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    level,
    source,
    customSource,
    message,
    context,
    userId,
    error,
    stackTrace,
    createdAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = '_logs';
  @override
  VerificationContext validateIntegrity(
    Insertable<AppLog> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('custom_source')) {
      context.handle(
        _customSourceMeta,
        customSource.isAcceptableOrUnknown(
          data['custom_source']!,
          _customSourceMeta,
        ),
      );
    }
    if (data.containsKey('message')) {
      context.handle(
        _messageMeta,
        message.isAcceptableOrUnknown(data['message']!, _messageMeta),
      );
    } else if (isInserting) {
      context.missing(_messageMeta);
    }
    if (data.containsKey('context')) {
      context.handle(
        _contextMeta,
        this.context.isAcceptableOrUnknown(data['context']!, _contextMeta),
      );
    }
    if (data.containsKey('user_id')) {
      context.handle(
        _userIdMeta,
        userId.isAcceptableOrUnknown(data['user_id']!, _userIdMeta),
      );
    }
    if (data.containsKey('error')) {
      context.handle(
        _errorMeta,
        error.isAcceptableOrUnknown(data['error']!, _errorMeta),
      );
    }
    if (data.containsKey('stack_trace')) {
      context.handle(
        _stackTraceMeta,
        stackTrace.isAcceptableOrUnknown(data['stack_trace']!, _stackTraceMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  AppLog map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return AppLog(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      level: $LogsTable.$converterlevel.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}level'],
        )!,
      ),
      source: $LogsTable.$convertersource.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}source'],
        )!,
      ),
      customSource: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}custom_source'],
      ),
      message: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}message'],
      )!,
      context: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}context'],
      ),
      userId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}user_id'],
      ),
      error: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}error'],
      ),
      stackTrace: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}stack_trace'],
      ),
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
    );
  }

  @override
  $LogsTable createAlias(String alias) {
    return $LogsTable(attachedDatabase, alias);
  }

  static JsonTypeConverter2<LogLevel, String, String> $converterlevel =
      const EnumNameConverter<LogLevel>(LogLevel.values);
  static JsonTypeConverter2<LogSource, String, String> $convertersource =
      const EnumNameConverter<LogSource>(LogSource.values);
}

class LogsCompanion extends UpdateCompanion<AppLog> {
  final Value<int> id;
  final Value<LogLevel> level;
  final Value<LogSource> source;
  final Value<String?> customSource;
  final Value<String> message;
  final Value<String?> context;
  final Value<String?> userId;
  final Value<String?> error;
  final Value<String?> stackTrace;
  final Value<DateTime> createdAt;
  const LogsCompanion({
    this.id = const Value.absent(),
    this.level = const Value.absent(),
    this.source = const Value.absent(),
    this.customSource = const Value.absent(),
    this.message = const Value.absent(),
    this.context = const Value.absent(),
    this.userId = const Value.absent(),
    this.error = const Value.absent(),
    this.stackTrace = const Value.absent(),
    this.createdAt = const Value.absent(),
  });
  LogsCompanion.insert({
    this.id = const Value.absent(),
    required LogLevel level,
    required LogSource source,
    this.customSource = const Value.absent(),
    required String message,
    this.context = const Value.absent(),
    this.userId = const Value.absent(),
    this.error = const Value.absent(),
    this.stackTrace = const Value.absent(),
    this.createdAt = const Value.absent(),
  }) : level = Value(level),
       source = Value(source),
       message = Value(message);
  static Insertable<AppLog> custom({
    Expression<int>? id,
    Expression<String>? level,
    Expression<String>? source,
    Expression<String>? customSource,
    Expression<String>? message,
    Expression<String>? context,
    Expression<String>? userId,
    Expression<String>? error,
    Expression<String>? stackTrace,
    Expression<DateTime>? createdAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (level != null) 'level': level,
      if (source != null) 'source': source,
      if (customSource != null) 'custom_source': customSource,
      if (message != null) 'message': message,
      if (context != null) 'context': context,
      if (userId != null) 'user_id': userId,
      if (error != null) 'error': error,
      if (stackTrace != null) 'stack_trace': stackTrace,
      if (createdAt != null) 'created_at': createdAt,
    });
  }

  LogsCompanion copyWith({
    Value<int>? id,
    Value<LogLevel>? level,
    Value<LogSource>? source,
    Value<String?>? customSource,
    Value<String>? message,
    Value<String?>? context,
    Value<String?>? userId,
    Value<String?>? error,
    Value<String?>? stackTrace,
    Value<DateTime>? createdAt,
  }) {
    return LogsCompanion(
      id: id ?? this.id,
      level: level ?? this.level,
      source: source ?? this.source,
      customSource: customSource ?? this.customSource,
      message: message ?? this.message,
      context: context ?? this.context,
      userId: userId ?? this.userId,
      error: error ?? this.error,
      stackTrace: stackTrace ?? this.stackTrace,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (level.present) {
      map['level'] = Variable<String>(
        $LogsTable.$converterlevel.toSql(level.value),
      );
    }
    if (source.present) {
      map['source'] = Variable<String>(
        $LogsTable.$convertersource.toSql(source.value),
      );
    }
    if (customSource.present) {
      map['custom_source'] = Variable<String>(customSource.value);
    }
    if (message.present) {
      map['message'] = Variable<String>(message.value);
    }
    if (context.present) {
      map['context'] = Variable<String>(context.value);
    }
    if (userId.present) {
      map['user_id'] = Variable<String>(userId.value);
    }
    if (error.present) {
      map['error'] = Variable<String>(error.value);
    }
    if (stackTrace.present) {
      map['stack_trace'] = Variable<String>(stackTrace.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('LogsCompanion(')
          ..write('id: $id, ')
          ..write('level: $level, ')
          ..write('source: $source, ')
          ..write('customSource: $customSource, ')
          ..write('message: $message, ')
          ..write('context: $context, ')
          ..write('userId: $userId, ')
          ..write('error: $error, ')
          ..write('stackTrace: $stackTrace, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }
}

class $CollectionsTable extends Collections
    with TableInfo<$CollectionsTable, CollectionData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $CollectionsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _typeMeta = const VerificationMeta('type');
  @override
  late final GeneratedColumn<String> type = GeneratedColumn<String>(
    'type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('base'),
  );
  static const VerificationMeta _listRuleMeta = const VerificationMeta(
    'listRule',
  );
  @override
  late final GeneratedColumn<String> listRule = GeneratedColumn<String>(
    'list_rule',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _createRuleMeta = const VerificationMeta(
    'createRule',
  );
  @override
  late final GeneratedColumn<String> createRule = GeneratedColumn<String>(
    'create_rule',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _updateRuleMeta = const VerificationMeta(
    'updateRule',
  );
  @override
  late final GeneratedColumn<String> updateRule = GeneratedColumn<String>(
    'update_rule',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _deleteRuleMeta = const VerificationMeta(
    'deleteRule',
  );
  @override
  late final GeneratedColumn<String> deleteRule = GeneratedColumn<String>(
    'delete_rule',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _viewRuleMeta = const VerificationMeta(
    'viewRule',
  );
  @override
  late final GeneratedColumn<String> viewRule = GeneratedColumn<String>(
    'view_rule',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _viewQueryMeta = const VerificationMeta(
    'viewQuery',
  );
  @override
  late final GeneratedColumn<String> viewQuery = GeneratedColumn<String>(
    'view_query',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  late final GeneratedColumnWithTypeConverter<List<Attribute>, String>
  attributes = GeneratedColumn<String>(
    'attributes',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('[]'),
  ).withConverter<List<Attribute>>($CollectionsTable.$converterattributes);
  @override
  late final GeneratedColumnWithTypeConverter<List<Index>, String> indexes =
      GeneratedColumn<String>(
        'indexes',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
        defaultValue: const Constant('[]'),
      ).withConverter<List<Index>>($CollectionsTable.$converterindexes);
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  @override
  List<GeneratedColumn> get $columns => [
    name,
    type,
    listRule,
    createRule,
    updateRule,
    deleteRule,
    viewRule,
    viewQuery,
    attributes,
    indexes,
    createdAt,
    updatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = '_collections';
  @override
  VerificationContext validateIntegrity(
    Insertable<CollectionData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('type')) {
      context.handle(
        _typeMeta,
        type.isAcceptableOrUnknown(data['type']!, _typeMeta),
      );
    }
    if (data.containsKey('list_rule')) {
      context.handle(
        _listRuleMeta,
        listRule.isAcceptableOrUnknown(data['list_rule']!, _listRuleMeta),
      );
    }
    if (data.containsKey('create_rule')) {
      context.handle(
        _createRuleMeta,
        createRule.isAcceptableOrUnknown(data['create_rule']!, _createRuleMeta),
      );
    }
    if (data.containsKey('update_rule')) {
      context.handle(
        _updateRuleMeta,
        updateRule.isAcceptableOrUnknown(data['update_rule']!, _updateRuleMeta),
      );
    }
    if (data.containsKey('delete_rule')) {
      context.handle(
        _deleteRuleMeta,
        deleteRule.isAcceptableOrUnknown(data['delete_rule']!, _deleteRuleMeta),
      );
    }
    if (data.containsKey('view_rule')) {
      context.handle(
        _viewRuleMeta,
        viewRule.isAcceptableOrUnknown(data['view_rule']!, _viewRuleMeta),
      );
    }
    if (data.containsKey('view_query')) {
      context.handle(
        _viewQueryMeta,
        viewQuery.isAcceptableOrUnknown(data['view_query']!, _viewQueryMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {name};
  @override
  CollectionData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return CollectionData(
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      type: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}type'],
      )!,
      listRule: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}list_rule'],
      ),
      createRule: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}create_rule'],
      ),
      updateRule: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}update_rule'],
      ),
      deleteRule: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}delete_rule'],
      ),
      viewRule: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}view_rule'],
      ),
      viewQuery: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}view_query'],
      ),
      attributes: $CollectionsTable.$converterattributes.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}attributes'],
        )!,
      ),
      indexes: $CollectionsTable.$converterindexes.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}indexes'],
        )!,
      ),
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
    );
  }

  @override
  $CollectionsTable createAlias(String alias) {
    return $CollectionsTable(attachedDatabase, alias);
  }

  static JsonTypeConverter2<List<Attribute>, String, Object?>
  $converterattributes = Collections.attributesConverter;
  static JsonTypeConverter2<List<Index>, String, Object?> $converterindexes =
      Collections.indexesConverter;
}

class CollectionData extends DataClass implements Insertable<CollectionData> {
  final String name;
  final String type;
  final String? listRule;
  final String? createRule;
  final String? updateRule;
  final String? deleteRule;
  final String? viewRule;
  final String? viewQuery;
  final List<Attribute> attributes;
  final List<Index> indexes;
  final DateTime createdAt;
  final DateTime updatedAt;
  const CollectionData({
    required this.name,
    required this.type,
    this.listRule,
    this.createRule,
    this.updateRule,
    this.deleteRule,
    this.viewRule,
    this.viewQuery,
    required this.attributes,
    required this.indexes,
    required this.createdAt,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['name'] = Variable<String>(name);
    map['type'] = Variable<String>(type);
    if (!nullToAbsent || listRule != null) {
      map['list_rule'] = Variable<String>(listRule);
    }
    if (!nullToAbsent || createRule != null) {
      map['create_rule'] = Variable<String>(createRule);
    }
    if (!nullToAbsent || updateRule != null) {
      map['update_rule'] = Variable<String>(updateRule);
    }
    if (!nullToAbsent || deleteRule != null) {
      map['delete_rule'] = Variable<String>(deleteRule);
    }
    if (!nullToAbsent || viewRule != null) {
      map['view_rule'] = Variable<String>(viewRule);
    }
    if (!nullToAbsent || viewQuery != null) {
      map['view_query'] = Variable<String>(viewQuery);
    }
    {
      map['attributes'] = Variable<String>(
        $CollectionsTable.$converterattributes.toSql(attributes),
      );
    }
    {
      map['indexes'] = Variable<String>(
        $CollectionsTable.$converterindexes.toSql(indexes),
      );
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  CollectionsCompanion toCompanion(bool nullToAbsent) {
    return CollectionsCompanion(
      name: Value(name),
      type: Value(type),
      listRule: listRule == null && nullToAbsent
          ? const Value.absent()
          : Value(listRule),
      createRule: createRule == null && nullToAbsent
          ? const Value.absent()
          : Value(createRule),
      updateRule: updateRule == null && nullToAbsent
          ? const Value.absent()
          : Value(updateRule),
      deleteRule: deleteRule == null && nullToAbsent
          ? const Value.absent()
          : Value(deleteRule),
      viewRule: viewRule == null && nullToAbsent
          ? const Value.absent()
          : Value(viewRule),
      viewQuery: viewQuery == null && nullToAbsent
          ? const Value.absent()
          : Value(viewQuery),
      attributes: Value(attributes),
      indexes: Value(indexes),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
    );
  }

  factory CollectionData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return CollectionData(
      name: serializer.fromJson<String>(json['name']),
      type: serializer.fromJson<String>(json['type']),
      listRule: serializer.fromJson<String?>(json['listRule']),
      createRule: serializer.fromJson<String?>(json['createRule']),
      updateRule: serializer.fromJson<String?>(json['updateRule']),
      deleteRule: serializer.fromJson<String?>(json['deleteRule']),
      viewRule: serializer.fromJson<String?>(json['viewRule']),
      viewQuery: serializer.fromJson<String?>(json['viewQuery']),
      attributes: $CollectionsTable.$converterattributes.fromJson(
        serializer.fromJson<Object?>(json['attributes']),
      ),
      indexes: $CollectionsTable.$converterindexes.fromJson(
        serializer.fromJson<Object?>(json['indexes']),
      ),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'name': serializer.toJson<String>(name),
      'type': serializer.toJson<String>(type),
      'listRule': serializer.toJson<String?>(listRule),
      'createRule': serializer.toJson<String?>(createRule),
      'updateRule': serializer.toJson<String?>(updateRule),
      'deleteRule': serializer.toJson<String?>(deleteRule),
      'viewRule': serializer.toJson<String?>(viewRule),
      'viewQuery': serializer.toJson<String?>(viewQuery),
      'attributes': serializer.toJson<Object?>(
        $CollectionsTable.$converterattributes.toJson(attributes),
      ),
      'indexes': serializer.toJson<Object?>(
        $CollectionsTable.$converterindexes.toJson(indexes),
      ),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  CollectionData copyWith({
    String? name,
    String? type,
    Value<String?> listRule = const Value.absent(),
    Value<String?> createRule = const Value.absent(),
    Value<String?> updateRule = const Value.absent(),
    Value<String?> deleteRule = const Value.absent(),
    Value<String?> viewRule = const Value.absent(),
    Value<String?> viewQuery = const Value.absent(),
    List<Attribute>? attributes,
    List<Index>? indexes,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) => CollectionData(
    name: name ?? this.name,
    type: type ?? this.type,
    listRule: listRule.present ? listRule.value : this.listRule,
    createRule: createRule.present ? createRule.value : this.createRule,
    updateRule: updateRule.present ? updateRule.value : this.updateRule,
    deleteRule: deleteRule.present ? deleteRule.value : this.deleteRule,
    viewRule: viewRule.present ? viewRule.value : this.viewRule,
    viewQuery: viewQuery.present ? viewQuery.value : this.viewQuery,
    attributes: attributes ?? this.attributes,
    indexes: indexes ?? this.indexes,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
  );
  CollectionData copyWithCompanion(CollectionsCompanion data) {
    return CollectionData(
      name: data.name.present ? data.name.value : this.name,
      type: data.type.present ? data.type.value : this.type,
      listRule: data.listRule.present ? data.listRule.value : this.listRule,
      createRule: data.createRule.present
          ? data.createRule.value
          : this.createRule,
      updateRule: data.updateRule.present
          ? data.updateRule.value
          : this.updateRule,
      deleteRule: data.deleteRule.present
          ? data.deleteRule.value
          : this.deleteRule,
      viewRule: data.viewRule.present ? data.viewRule.value : this.viewRule,
      viewQuery: data.viewQuery.present ? data.viewQuery.value : this.viewQuery,
      attributes: data.attributes.present
          ? data.attributes.value
          : this.attributes,
      indexes: data.indexes.present ? data.indexes.value : this.indexes,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('CollectionData(')
          ..write('name: $name, ')
          ..write('type: $type, ')
          ..write('listRule: $listRule, ')
          ..write('createRule: $createRule, ')
          ..write('updateRule: $updateRule, ')
          ..write('deleteRule: $deleteRule, ')
          ..write('viewRule: $viewRule, ')
          ..write('viewQuery: $viewQuery, ')
          ..write('attributes: $attributes, ')
          ..write('indexes: $indexes, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    name,
    type,
    listRule,
    createRule,
    updateRule,
    deleteRule,
    viewRule,
    viewQuery,
    attributes,
    indexes,
    createdAt,
    updatedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is CollectionData &&
          other.name == this.name &&
          other.type == this.type &&
          other.listRule == this.listRule &&
          other.createRule == this.createRule &&
          other.updateRule == this.updateRule &&
          other.deleteRule == this.deleteRule &&
          other.viewRule == this.viewRule &&
          other.viewQuery == this.viewQuery &&
          other.attributes == this.attributes &&
          other.indexes == this.indexes &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt);
}

class CollectionsCompanion extends UpdateCompanion<CollectionData> {
  final Value<String> name;
  final Value<String> type;
  final Value<String?> listRule;
  final Value<String?> createRule;
  final Value<String?> updateRule;
  final Value<String?> deleteRule;
  final Value<String?> viewRule;
  final Value<String?> viewQuery;
  final Value<List<Attribute>> attributes;
  final Value<List<Index>> indexes;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<int> rowid;
  const CollectionsCompanion({
    this.name = const Value.absent(),
    this.type = const Value.absent(),
    this.listRule = const Value.absent(),
    this.createRule = const Value.absent(),
    this.updateRule = const Value.absent(),
    this.deleteRule = const Value.absent(),
    this.viewRule = const Value.absent(),
    this.viewQuery = const Value.absent(),
    this.attributes = const Value.absent(),
    this.indexes = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  CollectionsCompanion.insert({
    required String name,
    this.type = const Value.absent(),
    this.listRule = const Value.absent(),
    this.createRule = const Value.absent(),
    this.updateRule = const Value.absent(),
    this.deleteRule = const Value.absent(),
    this.viewRule = const Value.absent(),
    this.viewQuery = const Value.absent(),
    this.attributes = const Value.absent(),
    this.indexes = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : name = Value(name);
  static Insertable<CollectionData> custom({
    Expression<String>? name,
    Expression<String>? type,
    Expression<String>? listRule,
    Expression<String>? createRule,
    Expression<String>? updateRule,
    Expression<String>? deleteRule,
    Expression<String>? viewRule,
    Expression<String>? viewQuery,
    Expression<String>? attributes,
    Expression<String>? indexes,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (name != null) 'name': name,
      if (type != null) 'type': type,
      if (listRule != null) 'list_rule': listRule,
      if (createRule != null) 'create_rule': createRule,
      if (updateRule != null) 'update_rule': updateRule,
      if (deleteRule != null) 'delete_rule': deleteRule,
      if (viewRule != null) 'view_rule': viewRule,
      if (viewQuery != null) 'view_query': viewQuery,
      if (attributes != null) 'attributes': attributes,
      if (indexes != null) 'indexes': indexes,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  CollectionsCompanion copyWith({
    Value<String>? name,
    Value<String>? type,
    Value<String?>? listRule,
    Value<String?>? createRule,
    Value<String?>? updateRule,
    Value<String?>? deleteRule,
    Value<String?>? viewRule,
    Value<String?>? viewQuery,
    Value<List<Attribute>>? attributes,
    Value<List<Index>>? indexes,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
    Value<int>? rowid,
  }) {
    return CollectionsCompanion(
      name: name ?? this.name,
      type: type ?? this.type,
      listRule: listRule ?? this.listRule,
      createRule: createRule ?? this.createRule,
      updateRule: updateRule ?? this.updateRule,
      deleteRule: deleteRule ?? this.deleteRule,
      viewRule: viewRule ?? this.viewRule,
      viewQuery: viewQuery ?? this.viewQuery,
      attributes: attributes ?? this.attributes,
      indexes: indexes ?? this.indexes,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (type.present) {
      map['type'] = Variable<String>(type.value);
    }
    if (listRule.present) {
      map['list_rule'] = Variable<String>(listRule.value);
    }
    if (createRule.present) {
      map['create_rule'] = Variable<String>(createRule.value);
    }
    if (updateRule.present) {
      map['update_rule'] = Variable<String>(updateRule.value);
    }
    if (deleteRule.present) {
      map['delete_rule'] = Variable<String>(deleteRule.value);
    }
    if (viewRule.present) {
      map['view_rule'] = Variable<String>(viewRule.value);
    }
    if (viewQuery.present) {
      map['view_query'] = Variable<String>(viewQuery.value);
    }
    if (attributes.present) {
      map['attributes'] = Variable<String>(
        $CollectionsTable.$converterattributes.toSql(attributes.value),
      );
    }
    if (indexes.present) {
      map['indexes'] = Variable<String>(
        $CollectionsTable.$converterindexes.toSql(indexes.value),
      );
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('CollectionsCompanion(')
          ..write('name: $name, ')
          ..write('type: $type, ')
          ..write('listRule: $listRule, ')
          ..write('createRule: $createRule, ')
          ..write('updateRule: $updateRule, ')
          ..write('deleteRule: $deleteRule, ')
          ..write('viewRule: $viewRule, ')
          ..write('viewQuery: $viewQuery, ')
          ..write('attributes: $attributes, ')
          ..write('indexes: $indexes, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $AppSettingsTable extends AppSettings
    with TableInfo<$AppSettingsTable, Settings> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $AppSettingsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _appNameMeta = const VerificationMeta(
    'appName',
  );
  @override
  late final GeneratedColumn<String> appName = GeneratedColumn<String>(
    'app_name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _siteUrlMeta = const VerificationMeta(
    'siteUrl',
  );
  @override
  late final GeneratedColumn<String> siteUrl = GeneratedColumn<String>(
    'site_url',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: Constant('http://localhost:8080'),
  );
  @override
  late final GeneratedColumnWithTypeConverter<List<String>, String>
  redirectUrls = GeneratedColumn<String>(
    'redirect_urls',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: Constant('[]'),
  ).withConverter<List<String>>($AppSettingsTable.$converterredirectUrls);
  @override
  late final GeneratedColumnWithTypeConverter<OAuthProviderList, String>
  oauthProviders =
      GeneratedColumn<String>(
        'oauth_providers',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      ).withConverter<OAuthProviderList>(
        $AppSettingsTable.$converteroauthProviders,
      );
  @override
  late final GeneratedColumnWithTypeConverter<S3Settings?, String> s3 =
      GeneratedColumn<String>(
        's3',
        aliasedName,
        true,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
      ).withConverter<S3Settings?>($AppSettingsTable.$converters3n);
  @override
  late final GeneratedColumnWithTypeConverter<MailSettings?, String> mail =
      GeneratedColumn<String>(
        'mail',
        aliasedName,
        true,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
      ).withConverter<MailSettings?>($AppSettingsTable.$convertermailn);
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    appName,
    siteUrl,
    redirectUrls,
    oauthProviders,
    s3,
    mail,
    createdAt,
    updatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = '_app_settings';
  @override
  VerificationContext validateIntegrity(
    Insertable<Settings> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('app_name')) {
      context.handle(
        _appNameMeta,
        appName.isAcceptableOrUnknown(data['app_name']!, _appNameMeta),
      );
    } else if (isInserting) {
      context.missing(_appNameMeta);
    }
    if (data.containsKey('site_url')) {
      context.handle(
        _siteUrlMeta,
        siteUrl.isAcceptableOrUnknown(data['site_url']!, _siteUrlMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Settings map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Settings(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      appName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}app_name'],
      )!,
      siteUrl: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}site_url'],
      )!,
      redirectUrls: $AppSettingsTable.$converterredirectUrls.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}redirect_urls'],
        )!,
      ),
      s3: $AppSettingsTable.$converters3n.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}s3'],
        ),
      ),
      mail: $AppSettingsTable.$convertermailn.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}mail'],
        ),
      ),
      oauthProviders: $AppSettingsTable.$converteroauthProviders.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}oauth_providers'],
        )!,
      ),
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
    );
  }

  @override
  $AppSettingsTable createAlias(String alias) {
    return $AppSettingsTable(attachedDatabase, alias);
  }

  static TypeConverter<List<String>, String> $converterredirectUrls =
      const RedirectUrlsConverter();
  static JsonTypeConverter2<OAuthProviderList, String, Map<String, Object?>>
  $converteroauthProviders = const OAuthProviderListConverter();
  static JsonTypeConverter2<S3Settings, String, Map<String, Object?>>
  $converters3 = const S3SettingsConverter();
  static JsonTypeConverter2<S3Settings?, String?, Map<String, Object?>?>
  $converters3n = JsonTypeConverter2.asNullable($converters3);
  static JsonTypeConverter2<MailSettings, String, Map<String, Object?>>
  $convertermail = const MailSettingsConverter();
  static JsonTypeConverter2<MailSettings?, String?, Map<String, Object?>?>
  $convertermailn = JsonTypeConverter2.asNullable($convertermail);
}

class AppSettingsCompanion extends UpdateCompanion<Settings> {
  final Value<int> id;
  final Value<String> appName;
  final Value<String> siteUrl;
  final Value<List<String>> redirectUrls;
  final Value<OAuthProviderList> oauthProviders;
  final Value<S3Settings?> s3;
  final Value<MailSettings?> mail;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  const AppSettingsCompanion({
    this.id = const Value.absent(),
    this.appName = const Value.absent(),
    this.siteUrl = const Value.absent(),
    this.redirectUrls = const Value.absent(),
    this.oauthProviders = const Value.absent(),
    this.s3 = const Value.absent(),
    this.mail = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
  });
  AppSettingsCompanion.insert({
    this.id = const Value.absent(),
    required String appName,
    this.siteUrl = const Value.absent(),
    this.redirectUrls = const Value.absent(),
    required OAuthProviderList oauthProviders,
    this.s3 = const Value.absent(),
    this.mail = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
  }) : appName = Value(appName),
       oauthProviders = Value(oauthProviders);
  static Insertable<Settings> custom({
    Expression<int>? id,
    Expression<String>? appName,
    Expression<String>? siteUrl,
    Expression<String>? redirectUrls,
    Expression<String>? oauthProviders,
    Expression<String>? s3,
    Expression<String>? mail,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (appName != null) 'app_name': appName,
      if (siteUrl != null) 'site_url': siteUrl,
      if (redirectUrls != null) 'redirect_urls': redirectUrls,
      if (oauthProviders != null) 'oauth_providers': oauthProviders,
      if (s3 != null) 's3': s3,
      if (mail != null) 'mail': mail,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
    });
  }

  AppSettingsCompanion copyWith({
    Value<int>? id,
    Value<String>? appName,
    Value<String>? siteUrl,
    Value<List<String>>? redirectUrls,
    Value<OAuthProviderList>? oauthProviders,
    Value<S3Settings?>? s3,
    Value<MailSettings?>? mail,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
  }) {
    return AppSettingsCompanion(
      id: id ?? this.id,
      appName: appName ?? this.appName,
      siteUrl: siteUrl ?? this.siteUrl,
      redirectUrls: redirectUrls ?? this.redirectUrls,
      oauthProviders: oauthProviders ?? this.oauthProviders,
      s3: s3 ?? this.s3,
      mail: mail ?? this.mail,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (appName.present) {
      map['app_name'] = Variable<String>(appName.value);
    }
    if (siteUrl.present) {
      map['site_url'] = Variable<String>(siteUrl.value);
    }
    if (redirectUrls.present) {
      map['redirect_urls'] = Variable<String>(
        $AppSettingsTable.$converterredirectUrls.toSql(redirectUrls.value),
      );
    }
    if (oauthProviders.present) {
      map['oauth_providers'] = Variable<String>(
        $AppSettingsTable.$converteroauthProviders.toSql(oauthProviders.value),
      );
    }
    if (s3.present) {
      map['s3'] = Variable<String>(
        $AppSettingsTable.$converters3n.toSql(s3.value),
      );
    }
    if (mail.present) {
      map['mail'] = Variable<String>(
        $AppSettingsTable.$convertermailn.toSql(mail.value),
      );
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('AppSettingsCompanion(')
          ..write('id: $id, ')
          ..write('appName: $appName, ')
          ..write('siteUrl: $siteUrl, ')
          ..write('redirectUrls: $redirectUrls, ')
          ..write('oauthProviders: $oauthProviders, ')
          ..write('s3: $s3, ')
          ..write('mail: $mail, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }
}

class $OtpsTable extends Otps with TableInfo<$OtpsTable, Otp> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $OtpsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _emailMeta = const VerificationMeta('email');
  @override
  late final GeneratedColumn<String> email = GeneratedColumn<String>(
    'email',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _otpMeta = const VerificationMeta('otp');
  @override
  late final GeneratedColumn<String> otp = GeneratedColumn<String>(
    'otp',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  static const VerificationMeta _expiresAtMeta = const VerificationMeta(
    'expiresAt',
  );
  @override
  late final GeneratedColumn<DateTime> expiresAt = GeneratedColumn<DateTime>(
    'expires_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    clientDefault: () => DateTime.now().add(const Duration(minutes: 10)),
  );
  @override
  List<GeneratedColumn> get $columns => [id, email, otp, createdAt, expiresAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = '_otps';
  @override
  VerificationContext validateIntegrity(
    Insertable<Otp> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('email')) {
      context.handle(
        _emailMeta,
        email.isAcceptableOrUnknown(data['email']!, _emailMeta),
      );
    } else if (isInserting) {
      context.missing(_emailMeta);
    }
    if (data.containsKey('otp')) {
      context.handle(
        _otpMeta,
        otp.isAcceptableOrUnknown(data['otp']!, _otpMeta),
      );
    } else if (isInserting) {
      context.missing(_otpMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    }
    if (data.containsKey('expires_at')) {
      context.handle(
        _expiresAtMeta,
        expiresAt.isAcceptableOrUnknown(data['expires_at']!, _expiresAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Otp map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Otp(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      email: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}email'],
      )!,
      otp: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}otp'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      expiresAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}expires_at'],
      )!,
    );
  }

  @override
  $OtpsTable createAlias(String alias) {
    return $OtpsTable(attachedDatabase, alias);
  }
}

class Otp extends DataClass implements Insertable<Otp> {
  final int id;
  final String email;
  final String otp;
  final DateTime createdAt;
  final DateTime expiresAt;
  const Otp({
    required this.id,
    required this.email,
    required this.otp,
    required this.createdAt,
    required this.expiresAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['email'] = Variable<String>(email);
    map['otp'] = Variable<String>(otp);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['expires_at'] = Variable<DateTime>(expiresAt);
    return map;
  }

  OtpsCompanion toCompanion(bool nullToAbsent) {
    return OtpsCompanion(
      id: Value(id),
      email: Value(email),
      otp: Value(otp),
      createdAt: Value(createdAt),
      expiresAt: Value(expiresAt),
    );
  }

  factory Otp.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Otp(
      id: serializer.fromJson<int>(json['id']),
      email: serializer.fromJson<String>(json['email']),
      otp: serializer.fromJson<String>(json['otp']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      expiresAt: serializer.fromJson<DateTime>(json['expiresAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'email': serializer.toJson<String>(email),
      'otp': serializer.toJson<String>(otp),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'expiresAt': serializer.toJson<DateTime>(expiresAt),
    };
  }

  Otp copyWith({
    int? id,
    String? email,
    String? otp,
    DateTime? createdAt,
    DateTime? expiresAt,
  }) => Otp(
    id: id ?? this.id,
    email: email ?? this.email,
    otp: otp ?? this.otp,
    createdAt: createdAt ?? this.createdAt,
    expiresAt: expiresAt ?? this.expiresAt,
  );
  Otp copyWithCompanion(OtpsCompanion data) {
    return Otp(
      id: data.id.present ? data.id.value : this.id,
      email: data.email.present ? data.email.value : this.email,
      otp: data.otp.present ? data.otp.value : this.otp,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      expiresAt: data.expiresAt.present ? data.expiresAt.value : this.expiresAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Otp(')
          ..write('id: $id, ')
          ..write('email: $email, ')
          ..write('otp: $otp, ')
          ..write('createdAt: $createdAt, ')
          ..write('expiresAt: $expiresAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, email, otp, createdAt, expiresAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Otp &&
          other.id == this.id &&
          other.email == this.email &&
          other.otp == this.otp &&
          other.createdAt == this.createdAt &&
          other.expiresAt == this.expiresAt);
}

class OtpsCompanion extends UpdateCompanion<Otp> {
  final Value<int> id;
  final Value<String> email;
  final Value<String> otp;
  final Value<DateTime> createdAt;
  final Value<DateTime> expiresAt;
  const OtpsCompanion({
    this.id = const Value.absent(),
    this.email = const Value.absent(),
    this.otp = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.expiresAt = const Value.absent(),
  });
  OtpsCompanion.insert({
    this.id = const Value.absent(),
    required String email,
    required String otp,
    this.createdAt = const Value.absent(),
    this.expiresAt = const Value.absent(),
  }) : email = Value(email),
       otp = Value(otp);
  static Insertable<Otp> custom({
    Expression<int>? id,
    Expression<String>? email,
    Expression<String>? otp,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? expiresAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (email != null) 'email': email,
      if (otp != null) 'otp': otp,
      if (createdAt != null) 'created_at': createdAt,
      if (expiresAt != null) 'expires_at': expiresAt,
    });
  }

  OtpsCompanion copyWith({
    Value<int>? id,
    Value<String>? email,
    Value<String>? otp,
    Value<DateTime>? createdAt,
    Value<DateTime>? expiresAt,
  }) {
    return OtpsCompanion(
      id: id ?? this.id,
      email: email ?? this.email,
      otp: otp ?? this.otp,
      createdAt: createdAt ?? this.createdAt,
      expiresAt: expiresAt ?? this.expiresAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (email.present) {
      map['email'] = Variable<String>(email.value);
    }
    if (otp.present) {
      map['otp'] = Variable<String>(otp.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (expiresAt.present) {
      map['expires_at'] = Variable<DateTime>(expiresAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('OtpsCompanion(')
          ..write('id: $id, ')
          ..write('email: $email, ')
          ..write('otp: $otp, ')
          ..write('createdAt: $createdAt, ')
          ..write('expiresAt: $expiresAt')
          ..write(')'))
        .toString();
  }
}

class $FilesTable extends Files with TableInfo<$FilesTable, DbFile> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $FilesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    clientDefault: () => const Uuid().v7(),
  );
  static const VerificationMeta _pathMeta = const VerificationMeta('path');
  @override
  late final GeneratedColumn<String> path = GeneratedColumn<String>(
    'path',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _bucketMeta = const VerificationMeta('bucket');
  @override
  late final GeneratedColumn<String> bucket = GeneratedColumn<String>(
    'bucket',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _isLocalMeta = const VerificationMeta(
    'isLocal',
  );
  @override
  late final GeneratedColumn<bool> isLocal = GeneratedColumn<bool>(
    'is_local',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintsDependsOnDialect({
      SqlDialect.sqlite: 'CHECK ("is_local" IN (0, 1))',
      SqlDialect.postgres: '',
    }),
  );
  static const VerificationMeta _sizeMeta = const VerificationMeta('size');
  @override
  late final GeneratedColumn<int> size = GeneratedColumn<int>(
    'size',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _mimeTypeMeta = const VerificationMeta(
    'mimeType',
  );
  @override
  late final GeneratedColumn<String> mimeType = GeneratedColumn<String>(
    'mime_type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  late final GeneratedColumnWithTypeConverter<Map<String, Object?>?, String>
  metadata = GeneratedColumn<String>(
    'metadata',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  ).withConverter<Map<String, Object?>?>($FilesTable.$convertermetadatan);
  static const VerificationMeta _downloadTokenMeta = const VerificationMeta(
    'downloadToken',
  );
  @override
  late final GeneratedColumn<String> downloadToken = GeneratedColumn<String>(
    'download_token',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    path,
    bucket,
    isLocal,
    size,
    mimeType,
    metadata,
    downloadToken,
    createdAt,
    updatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = '_files';
  @override
  VerificationContext validateIntegrity(
    Insertable<DbFile> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('path')) {
      context.handle(
        _pathMeta,
        path.isAcceptableOrUnknown(data['path']!, _pathMeta),
      );
    } else if (isInserting) {
      context.missing(_pathMeta);
    }
    if (data.containsKey('bucket')) {
      context.handle(
        _bucketMeta,
        bucket.isAcceptableOrUnknown(data['bucket']!, _bucketMeta),
      );
    } else if (isInserting) {
      context.missing(_bucketMeta);
    }
    if (data.containsKey('is_local')) {
      context.handle(
        _isLocalMeta,
        isLocal.isAcceptableOrUnknown(data['is_local']!, _isLocalMeta),
      );
    } else if (isInserting) {
      context.missing(_isLocalMeta);
    }
    if (data.containsKey('size')) {
      context.handle(
        _sizeMeta,
        size.isAcceptableOrUnknown(data['size']!, _sizeMeta),
      );
    } else if (isInserting) {
      context.missing(_sizeMeta);
    }
    if (data.containsKey('mime_type')) {
      context.handle(
        _mimeTypeMeta,
        mimeType.isAcceptableOrUnknown(data['mime_type']!, _mimeTypeMeta),
      );
    } else if (isInserting) {
      context.missing(_mimeTypeMeta);
    }
    if (data.containsKey('download_token')) {
      context.handle(
        _downloadTokenMeta,
        downloadToken.isAcceptableOrUnknown(
          data['download_token']!,
          _downloadTokenMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_downloadTokenMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  DbFile map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return DbFile(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      path: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}path'],
      )!,
      bucket: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}bucket'],
      )!,
      isLocal: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_local'],
      )!,
      size: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}size'],
      )!,
      mimeType: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}mime_type'],
      )!,
      metadata: $FilesTable.$convertermetadatan.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}metadata'],
        ),
      ),
      downloadToken: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}download_token'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
    );
  }

  @override
  $FilesTable createAlias(String alias) {
    return $FilesTable(attachedDatabase, alias);
  }

  static JsonTypeConverter2<Map<String, Object?>, String, Map<String, Object?>>
  $convertermetadata = const MapConverter();
  static JsonTypeConverter2<
    Map<String, Object?>?,
    String?,
    Map<String, Object?>?
  >
  $convertermetadatan = JsonTypeConverter2.asNullable($convertermetadata);
}

class DbFile extends DataClass implements Insertable<DbFile>, Resource {
  final String id;
  final String path;
  final String bucket;
  final bool isLocal;
  final int size;
  final String mimeType;
  final Map<String, Object?>? metadata;
  final String downloadToken;
  final DateTime createdAt;
  final DateTime updatedAt;
  const DbFile({
    required this.id,
    required this.path,
    required this.bucket,
    required this.isLocal,
    required this.size,
    required this.mimeType,
    this.metadata,
    required this.downloadToken,
    required this.createdAt,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['path'] = Variable<String>(path);
    map['bucket'] = Variable<String>(bucket);
    map['is_local'] = Variable<bool>(isLocal);
    map['size'] = Variable<int>(size);
    map['mime_type'] = Variable<String>(mimeType);
    if (!nullToAbsent || metadata != null) {
      map['metadata'] = Variable<String>(
        $FilesTable.$convertermetadatan.toSql(metadata),
      );
    }
    map['download_token'] = Variable<String>(downloadToken);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  FilesCompanion toCompanion(bool nullToAbsent) {
    return FilesCompanion(
      id: Value(id),
      path: Value(path),
      bucket: Value(bucket),
      isLocal: Value(isLocal),
      size: Value(size),
      mimeType: Value(mimeType),
      metadata: metadata == null && nullToAbsent
          ? const Value.absent()
          : Value(metadata),
      downloadToken: Value(downloadToken),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
    );
  }

  factory DbFile.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return DbFile(
      id: serializer.fromJson<String>(json['id']),
      path: serializer.fromJson<String>(json['path']),
      bucket: serializer.fromJson<String>(json['bucket']),
      isLocal: serializer.fromJson<bool>(json['isLocal']),
      size: serializer.fromJson<int>(json['size']),
      mimeType: serializer.fromJson<String>(json['mimeType']),
      metadata: $FilesTable.$convertermetadatan.fromJson(
        serializer.fromJson<Map<String, Object?>?>(json['metadata']),
      ),
      downloadToken: serializer.fromJson<String>(json['downloadToken']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'path': serializer.toJson<String>(path),
      'bucket': serializer.toJson<String>(bucket),
      'isLocal': serializer.toJson<bool>(isLocal),
      'size': serializer.toJson<int>(size),
      'mimeType': serializer.toJson<String>(mimeType),
      'metadata': serializer.toJson<Map<String, Object?>?>(
        $FilesTable.$convertermetadatan.toJson(metadata),
      ),
      'downloadToken': serializer.toJson<String>(downloadToken),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  DbFile copyWith({
    String? id,
    String? path,
    String? bucket,
    bool? isLocal,
    int? size,
    String? mimeType,
    Value<Map<String, Object?>?> metadata = const Value.absent(),
    String? downloadToken,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) => DbFile(
    id: id ?? this.id,
    path: path ?? this.path,
    bucket: bucket ?? this.bucket,
    isLocal: isLocal ?? this.isLocal,
    size: size ?? this.size,
    mimeType: mimeType ?? this.mimeType,
    metadata: metadata.present ? metadata.value : this.metadata,
    downloadToken: downloadToken ?? this.downloadToken,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
  );
  DbFile copyWithCompanion(FilesCompanion data) {
    return DbFile(
      id: data.id.present ? data.id.value : this.id,
      path: data.path.present ? data.path.value : this.path,
      bucket: data.bucket.present ? data.bucket.value : this.bucket,
      isLocal: data.isLocal.present ? data.isLocal.value : this.isLocal,
      size: data.size.present ? data.size.value : this.size,
      mimeType: data.mimeType.present ? data.mimeType.value : this.mimeType,
      metadata: data.metadata.present ? data.metadata.value : this.metadata,
      downloadToken: data.downloadToken.present
          ? data.downloadToken.value
          : this.downloadToken,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('DbFile(')
          ..write('id: $id, ')
          ..write('path: $path, ')
          ..write('bucket: $bucket, ')
          ..write('isLocal: $isLocal, ')
          ..write('size: $size, ')
          ..write('mimeType: $mimeType, ')
          ..write('metadata: $metadata, ')
          ..write('downloadToken: $downloadToken, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    path,
    bucket,
    isLocal,
    size,
    mimeType,
    metadata,
    downloadToken,
    createdAt,
    updatedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is DbFile &&
          other.id == this.id &&
          other.path == this.path &&
          other.bucket == this.bucket &&
          other.isLocal == this.isLocal &&
          other.size == this.size &&
          other.mimeType == this.mimeType &&
          other.metadata == this.metadata &&
          other.downloadToken == this.downloadToken &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt);
}

class FilesCompanion extends UpdateCompanion<DbFile> {
  final Value<String> id;
  final Value<String> path;
  final Value<String> bucket;
  final Value<bool> isLocal;
  final Value<int> size;
  final Value<String> mimeType;
  final Value<Map<String, Object?>?> metadata;
  final Value<String> downloadToken;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<int> rowid;
  const FilesCompanion({
    this.id = const Value.absent(),
    this.path = const Value.absent(),
    this.bucket = const Value.absent(),
    this.isLocal = const Value.absent(),
    this.size = const Value.absent(),
    this.mimeType = const Value.absent(),
    this.metadata = const Value.absent(),
    this.downloadToken = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  FilesCompanion.insert({
    this.id = const Value.absent(),
    required String path,
    required String bucket,
    required bool isLocal,
    required int size,
    required String mimeType,
    this.metadata = const Value.absent(),
    required String downloadToken,
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : path = Value(path),
       bucket = Value(bucket),
       isLocal = Value(isLocal),
       size = Value(size),
       mimeType = Value(mimeType),
       downloadToken = Value(downloadToken);
  static Insertable<DbFile> custom({
    Expression<String>? id,
    Expression<String>? path,
    Expression<String>? bucket,
    Expression<bool>? isLocal,
    Expression<int>? size,
    Expression<String>? mimeType,
    Expression<String>? metadata,
    Expression<String>? downloadToken,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (path != null) 'path': path,
      if (bucket != null) 'bucket': bucket,
      if (isLocal != null) 'is_local': isLocal,
      if (size != null) 'size': size,
      if (mimeType != null) 'mime_type': mimeType,
      if (metadata != null) 'metadata': metadata,
      if (downloadToken != null) 'download_token': downloadToken,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  FilesCompanion copyWith({
    Value<String>? id,
    Value<String>? path,
    Value<String>? bucket,
    Value<bool>? isLocal,
    Value<int>? size,
    Value<String>? mimeType,
    Value<Map<String, Object?>?>? metadata,
    Value<String>? downloadToken,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
    Value<int>? rowid,
  }) {
    return FilesCompanion(
      id: id ?? this.id,
      path: path ?? this.path,
      bucket: bucket ?? this.bucket,
      isLocal: isLocal ?? this.isLocal,
      size: size ?? this.size,
      mimeType: mimeType ?? this.mimeType,
      metadata: metadata ?? this.metadata,
      downloadToken: downloadToken ?? this.downloadToken,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (path.present) {
      map['path'] = Variable<String>(path.value);
    }
    if (bucket.present) {
      map['bucket'] = Variable<String>(bucket.value);
    }
    if (isLocal.present) {
      map['is_local'] = Variable<bool>(isLocal.value);
    }
    if (size.present) {
      map['size'] = Variable<int>(size.value);
    }
    if (mimeType.present) {
      map['mime_type'] = Variable<String>(mimeType.value);
    }
    if (metadata.present) {
      map['metadata'] = Variable<String>(
        $FilesTable.$convertermetadatan.toSql(metadata.value),
      );
    }
    if (downloadToken.present) {
      map['download_token'] = Variable<String>(downloadToken.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('FilesCompanion(')
          ..write('id: $id, ')
          ..write('path: $path, ')
          ..write('bucket: $bucket, ')
          ..write('isLocal: $isLocal, ')
          ..write('size: $size, ')
          ..write('mimeType: $mimeType, ')
          ..write('metadata: $metadata, ')
          ..write('downloadToken: $downloadToken, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $BucketsTable extends Buckets with TableInfo<$BucketsTable, Bucket> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $BucketsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _listRuleMeta = const VerificationMeta(
    'listRule',
  );
  @override
  late final GeneratedColumn<String> listRule = GeneratedColumn<String>(
    'list_rule',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _createRuleMeta = const VerificationMeta(
    'createRule',
  );
  @override
  late final GeneratedColumn<String> createRule = GeneratedColumn<String>(
    'create_rule',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _updateRuleMeta = const VerificationMeta(
    'updateRule',
  );
  @override
  late final GeneratedColumn<String> updateRule = GeneratedColumn<String>(
    'update_rule',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _deleteRuleMeta = const VerificationMeta(
    'deleteRule',
  );
  @override
  late final GeneratedColumn<String> deleteRule = GeneratedColumn<String>(
    'delete_rule',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _viewRuleMeta = const VerificationMeta(
    'viewRule',
  );
  @override
  late final GeneratedColumn<String> viewRule = GeneratedColumn<String>(
    'view_rule',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  @override
  List<GeneratedColumn> get $columns => [
    name,
    listRule,
    createRule,
    updateRule,
    deleteRule,
    viewRule,
    createdAt,
    updatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = '_buckets';
  @override
  VerificationContext validateIntegrity(
    Insertable<Bucket> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('list_rule')) {
      context.handle(
        _listRuleMeta,
        listRule.isAcceptableOrUnknown(data['list_rule']!, _listRuleMeta),
      );
    }
    if (data.containsKey('create_rule')) {
      context.handle(
        _createRuleMeta,
        createRule.isAcceptableOrUnknown(data['create_rule']!, _createRuleMeta),
      );
    }
    if (data.containsKey('update_rule')) {
      context.handle(
        _updateRuleMeta,
        updateRule.isAcceptableOrUnknown(data['update_rule']!, _updateRuleMeta),
      );
    }
    if (data.containsKey('delete_rule')) {
      context.handle(
        _deleteRuleMeta,
        deleteRule.isAcceptableOrUnknown(data['delete_rule']!, _deleteRuleMeta),
      );
    }
    if (data.containsKey('view_rule')) {
      context.handle(
        _viewRuleMeta,
        viewRule.isAcceptableOrUnknown(data['view_rule']!, _viewRuleMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {name};
  @override
  Bucket map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Bucket(
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      listRule: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}list_rule'],
      ),
      viewRule: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}view_rule'],
      ),
      createRule: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}create_rule'],
      ),
      deleteRule: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}delete_rule'],
      ),
      updateRule: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}update_rule'],
      ),
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
    );
  }

  @override
  $BucketsTable createAlias(String alias) {
    return $BucketsTable(attachedDatabase, alias);
  }
}

class BucketsCompanion extends UpdateCompanion<Bucket> {
  final Value<String> name;
  final Value<String?> listRule;
  final Value<String?> createRule;
  final Value<String?> updateRule;
  final Value<String?> deleteRule;
  final Value<String?> viewRule;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<int> rowid;
  const BucketsCompanion({
    this.name = const Value.absent(),
    this.listRule = const Value.absent(),
    this.createRule = const Value.absent(),
    this.updateRule = const Value.absent(),
    this.deleteRule = const Value.absent(),
    this.viewRule = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  BucketsCompanion.insert({
    required String name,
    this.listRule = const Value.absent(),
    this.createRule = const Value.absent(),
    this.updateRule = const Value.absent(),
    this.deleteRule = const Value.absent(),
    this.viewRule = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : name = Value(name);
  static Insertable<Bucket> custom({
    Expression<String>? name,
    Expression<String>? listRule,
    Expression<String>? createRule,
    Expression<String>? updateRule,
    Expression<String>? deleteRule,
    Expression<String>? viewRule,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (name != null) 'name': name,
      if (listRule != null) 'list_rule': listRule,
      if (createRule != null) 'create_rule': createRule,
      if (updateRule != null) 'update_rule': updateRule,
      if (deleteRule != null) 'delete_rule': deleteRule,
      if (viewRule != null) 'view_rule': viewRule,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  BucketsCompanion copyWith({
    Value<String>? name,
    Value<String?>? listRule,
    Value<String?>? createRule,
    Value<String?>? updateRule,
    Value<String?>? deleteRule,
    Value<String?>? viewRule,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
    Value<int>? rowid,
  }) {
    return BucketsCompanion(
      name: name ?? this.name,
      listRule: listRule ?? this.listRule,
      createRule: createRule ?? this.createRule,
      updateRule: updateRule ?? this.updateRule,
      deleteRule: deleteRule ?? this.deleteRule,
      viewRule: viewRule ?? this.viewRule,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (listRule.present) {
      map['list_rule'] = Variable<String>(listRule.value);
    }
    if (createRule.present) {
      map['create_rule'] = Variable<String>(createRule.value);
    }
    if (updateRule.present) {
      map['update_rule'] = Variable<String>(updateRule.value);
    }
    if (deleteRule.present) {
      map['delete_rule'] = Variable<String>(deleteRule.value);
    }
    if (viewRule.present) {
      map['view_rule'] = Variable<String>(viewRule.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('BucketsCompanion(')
          ..write('name: $name, ')
          ..write('listRule: $listRule, ')
          ..write('createRule: $createRule, ')
          ..write('updateRule: $updateRule, ')
          ..write('deleteRule: $deleteRule, ')
          ..write('viewRule: $viewRule, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $OauthStatesTable extends OauthStates
    with TableInfo<$OauthStatesTable, OauthState> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $OauthStatesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _stateMeta = const VerificationMeta('state');
  @override
  late final GeneratedColumn<String> state = GeneratedColumn<String>(
    'state',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways('UNIQUE'),
  );
  static const VerificationMeta _providerMeta = const VerificationMeta(
    'provider',
  );
  @override
  late final GeneratedColumn<String> provider = GeneratedColumn<String>(
    'provider',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _redirectUrlMeta = const VerificationMeta(
    'redirectUrl',
  );
  @override
  late final GeneratedColumn<String> redirectUrl = GeneratedColumn<String>(
    'redirect_url',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  static const VerificationMeta _expiresAtMeta = const VerificationMeta(
    'expiresAt',
  );
  @override
  late final GeneratedColumn<DateTime> expiresAt = GeneratedColumn<DateTime>(
    'expires_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    clientDefault: () => DateTime.now().add(const Duration(minutes: 10)),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    state,
    provider,
    redirectUrl,
    createdAt,
    expiresAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = '_oauth_states';
  @override
  VerificationContext validateIntegrity(
    Insertable<OauthState> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('state')) {
      context.handle(
        _stateMeta,
        state.isAcceptableOrUnknown(data['state']!, _stateMeta),
      );
    } else if (isInserting) {
      context.missing(_stateMeta);
    }
    if (data.containsKey('provider')) {
      context.handle(
        _providerMeta,
        provider.isAcceptableOrUnknown(data['provider']!, _providerMeta),
      );
    } else if (isInserting) {
      context.missing(_providerMeta);
    }
    if (data.containsKey('redirect_url')) {
      context.handle(
        _redirectUrlMeta,
        redirectUrl.isAcceptableOrUnknown(
          data['redirect_url']!,
          _redirectUrlMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_redirectUrlMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    }
    if (data.containsKey('expires_at')) {
      context.handle(
        _expiresAtMeta,
        expiresAt.isAcceptableOrUnknown(data['expires_at']!, _expiresAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  OauthState map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return OauthState(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      state: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}state'],
      )!,
      provider: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}provider'],
      )!,
      redirectUrl: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}redirect_url'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      expiresAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}expires_at'],
      )!,
    );
  }

  @override
  $OauthStatesTable createAlias(String alias) {
    return $OauthStatesTable(attachedDatabase, alias);
  }
}

class OauthState extends DataClass implements Insertable<OauthState> {
  final int id;
  final String state;
  final String provider;
  final String redirectUrl;
  final DateTime createdAt;
  final DateTime expiresAt;
  const OauthState({
    required this.id,
    required this.state,
    required this.provider,
    required this.redirectUrl,
    required this.createdAt,
    required this.expiresAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['state'] = Variable<String>(state);
    map['provider'] = Variable<String>(provider);
    map['redirect_url'] = Variable<String>(redirectUrl);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['expires_at'] = Variable<DateTime>(expiresAt);
    return map;
  }

  OauthStatesCompanion toCompanion(bool nullToAbsent) {
    return OauthStatesCompanion(
      id: Value(id),
      state: Value(state),
      provider: Value(provider),
      redirectUrl: Value(redirectUrl),
      createdAt: Value(createdAt),
      expiresAt: Value(expiresAt),
    );
  }

  factory OauthState.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return OauthState(
      id: serializer.fromJson<int>(json['id']),
      state: serializer.fromJson<String>(json['state']),
      provider: serializer.fromJson<String>(json['provider']),
      redirectUrl: serializer.fromJson<String>(json['redirectUrl']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      expiresAt: serializer.fromJson<DateTime>(json['expiresAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'state': serializer.toJson<String>(state),
      'provider': serializer.toJson<String>(provider),
      'redirectUrl': serializer.toJson<String>(redirectUrl),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'expiresAt': serializer.toJson<DateTime>(expiresAt),
    };
  }

  OauthState copyWith({
    int? id,
    String? state,
    String? provider,
    String? redirectUrl,
    DateTime? createdAt,
    DateTime? expiresAt,
  }) => OauthState(
    id: id ?? this.id,
    state: state ?? this.state,
    provider: provider ?? this.provider,
    redirectUrl: redirectUrl ?? this.redirectUrl,
    createdAt: createdAt ?? this.createdAt,
    expiresAt: expiresAt ?? this.expiresAt,
  );
  OauthState copyWithCompanion(OauthStatesCompanion data) {
    return OauthState(
      id: data.id.present ? data.id.value : this.id,
      state: data.state.present ? data.state.value : this.state,
      provider: data.provider.present ? data.provider.value : this.provider,
      redirectUrl: data.redirectUrl.present
          ? data.redirectUrl.value
          : this.redirectUrl,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      expiresAt: data.expiresAt.present ? data.expiresAt.value : this.expiresAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('OauthState(')
          ..write('id: $id, ')
          ..write('state: $state, ')
          ..write('provider: $provider, ')
          ..write('redirectUrl: $redirectUrl, ')
          ..write('createdAt: $createdAt, ')
          ..write('expiresAt: $expiresAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, state, provider, redirectUrl, createdAt, expiresAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is OauthState &&
          other.id == this.id &&
          other.state == this.state &&
          other.provider == this.provider &&
          other.redirectUrl == this.redirectUrl &&
          other.createdAt == this.createdAt &&
          other.expiresAt == this.expiresAt);
}

class OauthStatesCompanion extends UpdateCompanion<OauthState> {
  final Value<int> id;
  final Value<String> state;
  final Value<String> provider;
  final Value<String> redirectUrl;
  final Value<DateTime> createdAt;
  final Value<DateTime> expiresAt;
  const OauthStatesCompanion({
    this.id = const Value.absent(),
    this.state = const Value.absent(),
    this.provider = const Value.absent(),
    this.redirectUrl = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.expiresAt = const Value.absent(),
  });
  OauthStatesCompanion.insert({
    this.id = const Value.absent(),
    required String state,
    required String provider,
    required String redirectUrl,
    this.createdAt = const Value.absent(),
    this.expiresAt = const Value.absent(),
  }) : state = Value(state),
       provider = Value(provider),
       redirectUrl = Value(redirectUrl);
  static Insertable<OauthState> custom({
    Expression<int>? id,
    Expression<String>? state,
    Expression<String>? provider,
    Expression<String>? redirectUrl,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? expiresAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (state != null) 'state': state,
      if (provider != null) 'provider': provider,
      if (redirectUrl != null) 'redirect_url': redirectUrl,
      if (createdAt != null) 'created_at': createdAt,
      if (expiresAt != null) 'expires_at': expiresAt,
    });
  }

  OauthStatesCompanion copyWith({
    Value<int>? id,
    Value<String>? state,
    Value<String>? provider,
    Value<String>? redirectUrl,
    Value<DateTime>? createdAt,
    Value<DateTime>? expiresAt,
  }) {
    return OauthStatesCompanion(
      id: id ?? this.id,
      state: state ?? this.state,
      provider: provider ?? this.provider,
      redirectUrl: redirectUrl ?? this.redirectUrl,
      createdAt: createdAt ?? this.createdAt,
      expiresAt: expiresAt ?? this.expiresAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (state.present) {
      map['state'] = Variable<String>(state.value);
    }
    if (provider.present) {
      map['provider'] = Variable<String>(provider.value);
    }
    if (redirectUrl.present) {
      map['redirect_url'] = Variable<String>(redirectUrl.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (expiresAt.present) {
      map['expires_at'] = Variable<DateTime>(expiresAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('OauthStatesCompanion(')
          ..write('id: $id, ')
          ..write('state: $state, ')
          ..write('provider: $provider, ')
          ..write('redirectUrl: $redirectUrl, ')
          ..write('createdAt: $createdAt, ')
          ..write('expiresAt: $expiresAt')
          ..write(')'))
        .toString();
  }
}

class $ExternalAuthsTable extends ExternalAuths
    with TableInfo<$ExternalAuthsTable, ExternalAuth> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ExternalAuthsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _userIdMeta = const VerificationMeta('userId');
  @override
  late final GeneratedColumn<String> userId = GeneratedColumn<String>(
    'user_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _providerMeta = const VerificationMeta(
    'provider',
  );
  @override
  late final GeneratedColumn<String> provider = GeneratedColumn<String>(
    'provider',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _providerIdMeta = const VerificationMeta(
    'providerId',
  );
  @override
  late final GeneratedColumn<String> providerId = GeneratedColumn<String>(
    'provider_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    userId,
    provider,
    providerId,
    createdAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = '_external_auths';
  @override
  VerificationContext validateIntegrity(
    Insertable<ExternalAuth> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('user_id')) {
      context.handle(
        _userIdMeta,
        userId.isAcceptableOrUnknown(data['user_id']!, _userIdMeta),
      );
    } else if (isInserting) {
      context.missing(_userIdMeta);
    }
    if (data.containsKey('provider')) {
      context.handle(
        _providerMeta,
        provider.isAcceptableOrUnknown(data['provider']!, _providerMeta),
      );
    } else if (isInserting) {
      context.missing(_providerMeta);
    }
    if (data.containsKey('provider_id')) {
      context.handle(
        _providerIdMeta,
        providerId.isAcceptableOrUnknown(data['provider_id']!, _providerIdMeta),
      );
    } else if (isInserting) {
      context.missing(_providerIdMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  List<Set<GeneratedColumn>> get uniqueKeys => [
    {provider, providerId},
  ];
  @override
  ExternalAuth map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ExternalAuth(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      userId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}user_id'],
      )!,
      provider: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}provider'],
      )!,
      providerId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}provider_id'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
    );
  }

  @override
  $ExternalAuthsTable createAlias(String alias) {
    return $ExternalAuthsTable(attachedDatabase, alias);
  }
}

class ExternalAuth extends DataClass implements Insertable<ExternalAuth> {
  final int id;
  final String userId;
  final String provider;
  final String providerId;
  final DateTime createdAt;
  const ExternalAuth({
    required this.id,
    required this.userId,
    required this.provider,
    required this.providerId,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['user_id'] = Variable<String>(userId);
    map['provider'] = Variable<String>(provider);
    map['provider_id'] = Variable<String>(providerId);
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  ExternalAuthsCompanion toCompanion(bool nullToAbsent) {
    return ExternalAuthsCompanion(
      id: Value(id),
      userId: Value(userId),
      provider: Value(provider),
      providerId: Value(providerId),
      createdAt: Value(createdAt),
    );
  }

  factory ExternalAuth.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ExternalAuth(
      id: serializer.fromJson<int>(json['id']),
      userId: serializer.fromJson<String>(json['userId']),
      provider: serializer.fromJson<String>(json['provider']),
      providerId: serializer.fromJson<String>(json['providerId']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'userId': serializer.toJson<String>(userId),
      'provider': serializer.toJson<String>(provider),
      'providerId': serializer.toJson<String>(providerId),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  ExternalAuth copyWith({
    int? id,
    String? userId,
    String? provider,
    String? providerId,
    DateTime? createdAt,
  }) => ExternalAuth(
    id: id ?? this.id,
    userId: userId ?? this.userId,
    provider: provider ?? this.provider,
    providerId: providerId ?? this.providerId,
    createdAt: createdAt ?? this.createdAt,
  );
  ExternalAuth copyWithCompanion(ExternalAuthsCompanion data) {
    return ExternalAuth(
      id: data.id.present ? data.id.value : this.id,
      userId: data.userId.present ? data.userId.value : this.userId,
      provider: data.provider.present ? data.provider.value : this.provider,
      providerId: data.providerId.present
          ? data.providerId.value
          : this.providerId,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ExternalAuth(')
          ..write('id: $id, ')
          ..write('userId: $userId, ')
          ..write('provider: $provider, ')
          ..write('providerId: $providerId, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, userId, provider, providerId, createdAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ExternalAuth &&
          other.id == this.id &&
          other.userId == this.userId &&
          other.provider == this.provider &&
          other.providerId == this.providerId &&
          other.createdAt == this.createdAt);
}

class ExternalAuthsCompanion extends UpdateCompanion<ExternalAuth> {
  final Value<int> id;
  final Value<String> userId;
  final Value<String> provider;
  final Value<String> providerId;
  final Value<DateTime> createdAt;
  const ExternalAuthsCompanion({
    this.id = const Value.absent(),
    this.userId = const Value.absent(),
    this.provider = const Value.absent(),
    this.providerId = const Value.absent(),
    this.createdAt = const Value.absent(),
  });
  ExternalAuthsCompanion.insert({
    this.id = const Value.absent(),
    required String userId,
    required String provider,
    required String providerId,
    this.createdAt = const Value.absent(),
  }) : userId = Value(userId),
       provider = Value(provider),
       providerId = Value(providerId);
  static Insertable<ExternalAuth> custom({
    Expression<int>? id,
    Expression<String>? userId,
    Expression<String>? provider,
    Expression<String>? providerId,
    Expression<DateTime>? createdAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (userId != null) 'user_id': userId,
      if (provider != null) 'provider': provider,
      if (providerId != null) 'provider_id': providerId,
      if (createdAt != null) 'created_at': createdAt,
    });
  }

  ExternalAuthsCompanion copyWith({
    Value<int>? id,
    Value<String>? userId,
    Value<String>? provider,
    Value<String>? providerId,
    Value<DateTime>? createdAt,
  }) {
    return ExternalAuthsCompanion(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      provider: provider ?? this.provider,
      providerId: providerId ?? this.providerId,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (userId.present) {
      map['user_id'] = Variable<String>(userId.value);
    }
    if (provider.present) {
      map['provider'] = Variable<String>(provider.value);
    }
    if (providerId.present) {
      map['provider_id'] = Variable<String>(providerId.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ExternalAuthsCompanion(')
          ..write('id: $id, ')
          ..write('userId: $userId, ')
          ..write('provider: $provider, ')
          ..write('providerId: $providerId, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $UsersTable users = $UsersTable(this);
  late final $RefreshTokensTable refreshTokens = $RefreshTokensTable(this);
  late final $ResetPasswordTokensTable resetPasswordTokens =
      $ResetPasswordTokensTable(this);
  late final $LogsTable logs = $LogsTable(this);
  late final $CollectionsTable collections = $CollectionsTable(this);
  late final $AppSettingsTable appSettings = $AppSettingsTable(this);
  late final $OtpsTable otps = $OtpsTable(this);
  late final $FilesTable files = $FilesTable(this);
  late final $BucketsTable buckets = $BucketsTable(this);
  late final $OauthStatesTable oauthStates = $OauthStatesTable(this);
  late final $ExternalAuthsTable externalAuths = $ExternalAuthsTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    users,
    refreshTokens,
    resetPasswordTokens,
    logs,
    collections,
    appSettings,
    otps,
    files,
    buckets,
    oauthStates,
    externalAuths,
  ];
}

typedef $$UsersTableCreateCompanionBuilder =
    UsersCompanion Function({
      required String id,
      required String email,
      Value<String?> name,
      Value<bool> superUser,
      Value<String?> passwordHash,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<int> rowid,
    });
typedef $$UsersTableUpdateCompanionBuilder =
    UsersCompanion Function({
      Value<String> id,
      Value<String> email,
      Value<String?> name,
      Value<bool> superUser,
      Value<String?> passwordHash,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<int> rowid,
    });

class $$UsersTableFilterComposer extends Composer<_$AppDatabase, $UsersTable> {
  $$UsersTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get email => $composableBuilder(
    column: $table.email,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get superUser => $composableBuilder(
    column: $table.superUser,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get passwordHash => $composableBuilder(
    column: $table.passwordHash,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$UsersTableOrderingComposer
    extends Composer<_$AppDatabase, $UsersTable> {
  $$UsersTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get email => $composableBuilder(
    column: $table.email,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get superUser => $composableBuilder(
    column: $table.superUser,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get passwordHash => $composableBuilder(
    column: $table.passwordHash,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$UsersTableAnnotationComposer
    extends Composer<_$AppDatabase, $UsersTable> {
  $$UsersTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get email =>
      $composableBuilder(column: $table.email, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<bool> get superUser =>
      $composableBuilder(column: $table.superUser, builder: (column) => column);

  GeneratedColumn<String> get passwordHash => $composableBuilder(
    column: $table.passwordHash,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);
}

class $$UsersTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $UsersTable,
          DbUser,
          $$UsersTableFilterComposer,
          $$UsersTableOrderingComposer,
          $$UsersTableAnnotationComposer,
          $$UsersTableCreateCompanionBuilder,
          $$UsersTableUpdateCompanionBuilder,
          (DbUser, BaseReferences<_$AppDatabase, $UsersTable, DbUser>),
          DbUser,
          PrefetchHooks Function()
        > {
  $$UsersTableTableManager(_$AppDatabase db, $UsersTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$UsersTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$UsersTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$UsersTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> email = const Value.absent(),
                Value<String?> name = const Value.absent(),
                Value<bool> superUser = const Value.absent(),
                Value<String?> passwordHash = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => UsersCompanion(
                id: id,
                email: email,
                name: name,
                superUser: superUser,
                passwordHash: passwordHash,
                createdAt: createdAt,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String email,
                Value<String?> name = const Value.absent(),
                Value<bool> superUser = const Value.absent(),
                Value<String?> passwordHash = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => UsersCompanion.insert(
                id: id,
                email: email,
                name: name,
                superUser: superUser,
                passwordHash: passwordHash,
                createdAt: createdAt,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$UsersTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $UsersTable,
      DbUser,
      $$UsersTableFilterComposer,
      $$UsersTableOrderingComposer,
      $$UsersTableAnnotationComposer,
      $$UsersTableCreateCompanionBuilder,
      $$UsersTableUpdateCompanionBuilder,
      (DbUser, BaseReferences<_$AppDatabase, $UsersTable, DbUser>),
      DbUser,
      PrefetchHooks Function()
    >;
typedef $$RefreshTokensTableCreateCompanionBuilder =
    RefreshTokensCompanion Function({
      Value<int> id,
      required String userId,
      required String refreshToken,
      required String accessToken,
      Value<DateTime> createdAt,
      Value<DateTime> expiresAt,
    });
typedef $$RefreshTokensTableUpdateCompanionBuilder =
    RefreshTokensCompanion Function({
      Value<int> id,
      Value<String> userId,
      Value<String> refreshToken,
      Value<String> accessToken,
      Value<DateTime> createdAt,
      Value<DateTime> expiresAt,
    });

class $$RefreshTokensTableFilterComposer
    extends Composer<_$AppDatabase, $RefreshTokensTable> {
  $$RefreshTokensTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get userId => $composableBuilder(
    column: $table.userId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get refreshToken => $composableBuilder(
    column: $table.refreshToken,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get accessToken => $composableBuilder(
    column: $table.accessToken,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get expiresAt => $composableBuilder(
    column: $table.expiresAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$RefreshTokensTableOrderingComposer
    extends Composer<_$AppDatabase, $RefreshTokensTable> {
  $$RefreshTokensTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get userId => $composableBuilder(
    column: $table.userId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get refreshToken => $composableBuilder(
    column: $table.refreshToken,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get accessToken => $composableBuilder(
    column: $table.accessToken,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get expiresAt => $composableBuilder(
    column: $table.expiresAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$RefreshTokensTableAnnotationComposer
    extends Composer<_$AppDatabase, $RefreshTokensTable> {
  $$RefreshTokensTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get userId =>
      $composableBuilder(column: $table.userId, builder: (column) => column);

  GeneratedColumn<String> get refreshToken => $composableBuilder(
    column: $table.refreshToken,
    builder: (column) => column,
  );

  GeneratedColumn<String> get accessToken => $composableBuilder(
    column: $table.accessToken,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get expiresAt =>
      $composableBuilder(column: $table.expiresAt, builder: (column) => column);
}

class $$RefreshTokensTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $RefreshTokensTable,
          RefreshToken,
          $$RefreshTokensTableFilterComposer,
          $$RefreshTokensTableOrderingComposer,
          $$RefreshTokensTableAnnotationComposer,
          $$RefreshTokensTableCreateCompanionBuilder,
          $$RefreshTokensTableUpdateCompanionBuilder,
          (
            RefreshToken,
            BaseReferences<_$AppDatabase, $RefreshTokensTable, RefreshToken>,
          ),
          RefreshToken,
          PrefetchHooks Function()
        > {
  $$RefreshTokensTableTableManager(_$AppDatabase db, $RefreshTokensTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$RefreshTokensTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$RefreshTokensTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$RefreshTokensTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> userId = const Value.absent(),
                Value<String> refreshToken = const Value.absent(),
                Value<String> accessToken = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> expiresAt = const Value.absent(),
              }) => RefreshTokensCompanion(
                id: id,
                userId: userId,
                refreshToken: refreshToken,
                accessToken: accessToken,
                createdAt: createdAt,
                expiresAt: expiresAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String userId,
                required String refreshToken,
                required String accessToken,
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> expiresAt = const Value.absent(),
              }) => RefreshTokensCompanion.insert(
                id: id,
                userId: userId,
                refreshToken: refreshToken,
                accessToken: accessToken,
                createdAt: createdAt,
                expiresAt: expiresAt,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$RefreshTokensTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $RefreshTokensTable,
      RefreshToken,
      $$RefreshTokensTableFilterComposer,
      $$RefreshTokensTableOrderingComposer,
      $$RefreshTokensTableAnnotationComposer,
      $$RefreshTokensTableCreateCompanionBuilder,
      $$RefreshTokensTableUpdateCompanionBuilder,
      (
        RefreshToken,
        BaseReferences<_$AppDatabase, $RefreshTokensTable, RefreshToken>,
      ),
      RefreshToken,
      PrefetchHooks Function()
    >;
typedef $$ResetPasswordTokensTableCreateCompanionBuilder =
    ResetPasswordTokensCompanion Function({
      Value<int> id,
      required String userId,
      required String token,
      Value<DateTime> createdAt,
      Value<DateTime> expiresAt,
    });
typedef $$ResetPasswordTokensTableUpdateCompanionBuilder =
    ResetPasswordTokensCompanion Function({
      Value<int> id,
      Value<String> userId,
      Value<String> token,
      Value<DateTime> createdAt,
      Value<DateTime> expiresAt,
    });

class $$ResetPasswordTokensTableFilterComposer
    extends Composer<_$AppDatabase, $ResetPasswordTokensTable> {
  $$ResetPasswordTokensTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get userId => $composableBuilder(
    column: $table.userId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get token => $composableBuilder(
    column: $table.token,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get expiresAt => $composableBuilder(
    column: $table.expiresAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$ResetPasswordTokensTableOrderingComposer
    extends Composer<_$AppDatabase, $ResetPasswordTokensTable> {
  $$ResetPasswordTokensTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get userId => $composableBuilder(
    column: $table.userId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get token => $composableBuilder(
    column: $table.token,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get expiresAt => $composableBuilder(
    column: $table.expiresAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$ResetPasswordTokensTableAnnotationComposer
    extends Composer<_$AppDatabase, $ResetPasswordTokensTable> {
  $$ResetPasswordTokensTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get userId =>
      $composableBuilder(column: $table.userId, builder: (column) => column);

  GeneratedColumn<String> get token =>
      $composableBuilder(column: $table.token, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get expiresAt =>
      $composableBuilder(column: $table.expiresAt, builder: (column) => column);
}

class $$ResetPasswordTokensTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $ResetPasswordTokensTable,
          ResetPasswordToken,
          $$ResetPasswordTokensTableFilterComposer,
          $$ResetPasswordTokensTableOrderingComposer,
          $$ResetPasswordTokensTableAnnotationComposer,
          $$ResetPasswordTokensTableCreateCompanionBuilder,
          $$ResetPasswordTokensTableUpdateCompanionBuilder,
          (
            ResetPasswordToken,
            BaseReferences<
              _$AppDatabase,
              $ResetPasswordTokensTable,
              ResetPasswordToken
            >,
          ),
          ResetPasswordToken,
          PrefetchHooks Function()
        > {
  $$ResetPasswordTokensTableTableManager(
    _$AppDatabase db,
    $ResetPasswordTokensTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ResetPasswordTokensTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ResetPasswordTokensTableOrderingComposer(
                $db: db,
                $table: table,
              ),
          createComputedFieldComposer: () =>
              $$ResetPasswordTokensTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> userId = const Value.absent(),
                Value<String> token = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> expiresAt = const Value.absent(),
              }) => ResetPasswordTokensCompanion(
                id: id,
                userId: userId,
                token: token,
                createdAt: createdAt,
                expiresAt: expiresAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String userId,
                required String token,
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> expiresAt = const Value.absent(),
              }) => ResetPasswordTokensCompanion.insert(
                id: id,
                userId: userId,
                token: token,
                createdAt: createdAt,
                expiresAt: expiresAt,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$ResetPasswordTokensTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $ResetPasswordTokensTable,
      ResetPasswordToken,
      $$ResetPasswordTokensTableFilterComposer,
      $$ResetPasswordTokensTableOrderingComposer,
      $$ResetPasswordTokensTableAnnotationComposer,
      $$ResetPasswordTokensTableCreateCompanionBuilder,
      $$ResetPasswordTokensTableUpdateCompanionBuilder,
      (
        ResetPasswordToken,
        BaseReferences<
          _$AppDatabase,
          $ResetPasswordTokensTable,
          ResetPasswordToken
        >,
      ),
      ResetPasswordToken,
      PrefetchHooks Function()
    >;
typedef $$LogsTableCreateCompanionBuilder =
    LogsCompanion Function({
      Value<int> id,
      required LogLevel level,
      required LogSource source,
      Value<String?> customSource,
      required String message,
      Value<String?> context,
      Value<String?> userId,
      Value<String?> error,
      Value<String?> stackTrace,
      Value<DateTime> createdAt,
    });
typedef $$LogsTableUpdateCompanionBuilder =
    LogsCompanion Function({
      Value<int> id,
      Value<LogLevel> level,
      Value<LogSource> source,
      Value<String?> customSource,
      Value<String> message,
      Value<String?> context,
      Value<String?> userId,
      Value<String?> error,
      Value<String?> stackTrace,
      Value<DateTime> createdAt,
    });

class $$LogsTableFilterComposer extends Composer<_$AppDatabase, $LogsTable> {
  $$LogsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<LogLevel, LogLevel, String> get level =>
      $composableBuilder(
        column: $table.level,
        builder: (column) => ColumnWithTypeConverterFilters(column),
      );

  ColumnWithTypeConverterFilters<LogSource, LogSource, String> get source =>
      $composableBuilder(
        column: $table.source,
        builder: (column) => ColumnWithTypeConverterFilters(column),
      );

  ColumnFilters<String> get customSource => $composableBuilder(
    column: $table.customSource,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get message => $composableBuilder(
    column: $table.message,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get context => $composableBuilder(
    column: $table.context,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get userId => $composableBuilder(
    column: $table.userId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get error => $composableBuilder(
    column: $table.error,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get stackTrace => $composableBuilder(
    column: $table.stackTrace,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$LogsTableOrderingComposer extends Composer<_$AppDatabase, $LogsTable> {
  $$LogsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get level => $composableBuilder(
    column: $table.level,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get source => $composableBuilder(
    column: $table.source,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get customSource => $composableBuilder(
    column: $table.customSource,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get message => $composableBuilder(
    column: $table.message,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get context => $composableBuilder(
    column: $table.context,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get userId => $composableBuilder(
    column: $table.userId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get error => $composableBuilder(
    column: $table.error,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get stackTrace => $composableBuilder(
    column: $table.stackTrace,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$LogsTableAnnotationComposer
    extends Composer<_$AppDatabase, $LogsTable> {
  $$LogsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumnWithTypeConverter<LogLevel, String> get level =>
      $composableBuilder(column: $table.level, builder: (column) => column);

  GeneratedColumnWithTypeConverter<LogSource, String> get source =>
      $composableBuilder(column: $table.source, builder: (column) => column);

  GeneratedColumn<String> get customSource => $composableBuilder(
    column: $table.customSource,
    builder: (column) => column,
  );

  GeneratedColumn<String> get message =>
      $composableBuilder(column: $table.message, builder: (column) => column);

  GeneratedColumn<String> get context =>
      $composableBuilder(column: $table.context, builder: (column) => column);

  GeneratedColumn<String> get userId =>
      $composableBuilder(column: $table.userId, builder: (column) => column);

  GeneratedColumn<String> get error =>
      $composableBuilder(column: $table.error, builder: (column) => column);

  GeneratedColumn<String> get stackTrace => $composableBuilder(
    column: $table.stackTrace,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);
}

class $$LogsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $LogsTable,
          AppLog,
          $$LogsTableFilterComposer,
          $$LogsTableOrderingComposer,
          $$LogsTableAnnotationComposer,
          $$LogsTableCreateCompanionBuilder,
          $$LogsTableUpdateCompanionBuilder,
          (AppLog, BaseReferences<_$AppDatabase, $LogsTable, AppLog>),
          AppLog,
          PrefetchHooks Function()
        > {
  $$LogsTableTableManager(_$AppDatabase db, $LogsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$LogsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$LogsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$LogsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<LogLevel> level = const Value.absent(),
                Value<LogSource> source = const Value.absent(),
                Value<String?> customSource = const Value.absent(),
                Value<String> message = const Value.absent(),
                Value<String?> context = const Value.absent(),
                Value<String?> userId = const Value.absent(),
                Value<String?> error = const Value.absent(),
                Value<String?> stackTrace = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
              }) => LogsCompanion(
                id: id,
                level: level,
                source: source,
                customSource: customSource,
                message: message,
                context: context,
                userId: userId,
                error: error,
                stackTrace: stackTrace,
                createdAt: createdAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required LogLevel level,
                required LogSource source,
                Value<String?> customSource = const Value.absent(),
                required String message,
                Value<String?> context = const Value.absent(),
                Value<String?> userId = const Value.absent(),
                Value<String?> error = const Value.absent(),
                Value<String?> stackTrace = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
              }) => LogsCompanion.insert(
                id: id,
                level: level,
                source: source,
                customSource: customSource,
                message: message,
                context: context,
                userId: userId,
                error: error,
                stackTrace: stackTrace,
                createdAt: createdAt,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$LogsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $LogsTable,
      AppLog,
      $$LogsTableFilterComposer,
      $$LogsTableOrderingComposer,
      $$LogsTableAnnotationComposer,
      $$LogsTableCreateCompanionBuilder,
      $$LogsTableUpdateCompanionBuilder,
      (AppLog, BaseReferences<_$AppDatabase, $LogsTable, AppLog>),
      AppLog,
      PrefetchHooks Function()
    >;
typedef $$CollectionsTableCreateCompanionBuilder =
    CollectionsCompanion Function({
      required String name,
      Value<String> type,
      Value<String?> listRule,
      Value<String?> createRule,
      Value<String?> updateRule,
      Value<String?> deleteRule,
      Value<String?> viewRule,
      Value<String?> viewQuery,
      Value<List<Attribute>> attributes,
      Value<List<Index>> indexes,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<int> rowid,
    });
typedef $$CollectionsTableUpdateCompanionBuilder =
    CollectionsCompanion Function({
      Value<String> name,
      Value<String> type,
      Value<String?> listRule,
      Value<String?> createRule,
      Value<String?> updateRule,
      Value<String?> deleteRule,
      Value<String?> viewRule,
      Value<String?> viewQuery,
      Value<List<Attribute>> attributes,
      Value<List<Index>> indexes,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<int> rowid,
    });

class $$CollectionsTableFilterComposer
    extends Composer<_$AppDatabase, $CollectionsTable> {
  $$CollectionsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get type => $composableBuilder(
    column: $table.type,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get listRule => $composableBuilder(
    column: $table.listRule,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get createRule => $composableBuilder(
    column: $table.createRule,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get updateRule => $composableBuilder(
    column: $table.updateRule,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get deleteRule => $composableBuilder(
    column: $table.deleteRule,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get viewRule => $composableBuilder(
    column: $table.viewRule,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get viewQuery => $composableBuilder(
    column: $table.viewQuery,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<List<Attribute>, List<Attribute>, String>
  get attributes => $composableBuilder(
    column: $table.attributes,
    builder: (column) => ColumnWithTypeConverterFilters(column),
  );

  ColumnWithTypeConverterFilters<List<Index>, List<Index>, String>
  get indexes => $composableBuilder(
    column: $table.indexes,
    builder: (column) => ColumnWithTypeConverterFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$CollectionsTableOrderingComposer
    extends Composer<_$AppDatabase, $CollectionsTable> {
  $$CollectionsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get type => $composableBuilder(
    column: $table.type,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get listRule => $composableBuilder(
    column: $table.listRule,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get createRule => $composableBuilder(
    column: $table.createRule,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get updateRule => $composableBuilder(
    column: $table.updateRule,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get deleteRule => $composableBuilder(
    column: $table.deleteRule,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get viewRule => $composableBuilder(
    column: $table.viewRule,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get viewQuery => $composableBuilder(
    column: $table.viewQuery,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get attributes => $composableBuilder(
    column: $table.attributes,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get indexes => $composableBuilder(
    column: $table.indexes,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$CollectionsTableAnnotationComposer
    extends Composer<_$AppDatabase, $CollectionsTable> {
  $$CollectionsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get type =>
      $composableBuilder(column: $table.type, builder: (column) => column);

  GeneratedColumn<String> get listRule =>
      $composableBuilder(column: $table.listRule, builder: (column) => column);

  GeneratedColumn<String> get createRule => $composableBuilder(
    column: $table.createRule,
    builder: (column) => column,
  );

  GeneratedColumn<String> get updateRule => $composableBuilder(
    column: $table.updateRule,
    builder: (column) => column,
  );

  GeneratedColumn<String> get deleteRule => $composableBuilder(
    column: $table.deleteRule,
    builder: (column) => column,
  );

  GeneratedColumn<String> get viewRule =>
      $composableBuilder(column: $table.viewRule, builder: (column) => column);

  GeneratedColumn<String> get viewQuery =>
      $composableBuilder(column: $table.viewQuery, builder: (column) => column);

  GeneratedColumnWithTypeConverter<List<Attribute>, String> get attributes =>
      $composableBuilder(
        column: $table.attributes,
        builder: (column) => column,
      );

  GeneratedColumnWithTypeConverter<List<Index>, String> get indexes =>
      $composableBuilder(column: $table.indexes, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);
}

class $$CollectionsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $CollectionsTable,
          CollectionData,
          $$CollectionsTableFilterComposer,
          $$CollectionsTableOrderingComposer,
          $$CollectionsTableAnnotationComposer,
          $$CollectionsTableCreateCompanionBuilder,
          $$CollectionsTableUpdateCompanionBuilder,
          (
            CollectionData,
            BaseReferences<_$AppDatabase, $CollectionsTable, CollectionData>,
          ),
          CollectionData,
          PrefetchHooks Function()
        > {
  $$CollectionsTableTableManager(_$AppDatabase db, $CollectionsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$CollectionsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$CollectionsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$CollectionsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> name = const Value.absent(),
                Value<String> type = const Value.absent(),
                Value<String?> listRule = const Value.absent(),
                Value<String?> createRule = const Value.absent(),
                Value<String?> updateRule = const Value.absent(),
                Value<String?> deleteRule = const Value.absent(),
                Value<String?> viewRule = const Value.absent(),
                Value<String?> viewQuery = const Value.absent(),
                Value<List<Attribute>> attributes = const Value.absent(),
                Value<List<Index>> indexes = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => CollectionsCompanion(
                name: name,
                type: type,
                listRule: listRule,
                createRule: createRule,
                updateRule: updateRule,
                deleteRule: deleteRule,
                viewRule: viewRule,
                viewQuery: viewQuery,
                attributes: attributes,
                indexes: indexes,
                createdAt: createdAt,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String name,
                Value<String> type = const Value.absent(),
                Value<String?> listRule = const Value.absent(),
                Value<String?> createRule = const Value.absent(),
                Value<String?> updateRule = const Value.absent(),
                Value<String?> deleteRule = const Value.absent(),
                Value<String?> viewRule = const Value.absent(),
                Value<String?> viewQuery = const Value.absent(),
                Value<List<Attribute>> attributes = const Value.absent(),
                Value<List<Index>> indexes = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => CollectionsCompanion.insert(
                name: name,
                type: type,
                listRule: listRule,
                createRule: createRule,
                updateRule: updateRule,
                deleteRule: deleteRule,
                viewRule: viewRule,
                viewQuery: viewQuery,
                attributes: attributes,
                indexes: indexes,
                createdAt: createdAt,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$CollectionsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $CollectionsTable,
      CollectionData,
      $$CollectionsTableFilterComposer,
      $$CollectionsTableOrderingComposer,
      $$CollectionsTableAnnotationComposer,
      $$CollectionsTableCreateCompanionBuilder,
      $$CollectionsTableUpdateCompanionBuilder,
      (
        CollectionData,
        BaseReferences<_$AppDatabase, $CollectionsTable, CollectionData>,
      ),
      CollectionData,
      PrefetchHooks Function()
    >;
typedef $$AppSettingsTableCreateCompanionBuilder =
    AppSettingsCompanion Function({
      Value<int> id,
      required String appName,
      Value<String> siteUrl,
      Value<List<String>> redirectUrls,
      required OAuthProviderList oauthProviders,
      Value<S3Settings?> s3,
      Value<MailSettings?> mail,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
    });
typedef $$AppSettingsTableUpdateCompanionBuilder =
    AppSettingsCompanion Function({
      Value<int> id,
      Value<String> appName,
      Value<String> siteUrl,
      Value<List<String>> redirectUrls,
      Value<OAuthProviderList> oauthProviders,
      Value<S3Settings?> s3,
      Value<MailSettings?> mail,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
    });

class $$AppSettingsTableFilterComposer
    extends Composer<_$AppDatabase, $AppSettingsTable> {
  $$AppSettingsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get appName => $composableBuilder(
    column: $table.appName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get siteUrl => $composableBuilder(
    column: $table.siteUrl,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<List<String>, List<String>, String>
  get redirectUrls => $composableBuilder(
    column: $table.redirectUrls,
    builder: (column) => ColumnWithTypeConverterFilters(column),
  );

  ColumnWithTypeConverterFilters<OAuthProviderList, OAuthProviderList, String>
  get oauthProviders => $composableBuilder(
    column: $table.oauthProviders,
    builder: (column) => ColumnWithTypeConverterFilters(column),
  );

  ColumnWithTypeConverterFilters<S3Settings?, S3Settings, String> get s3 =>
      $composableBuilder(
        column: $table.s3,
        builder: (column) => ColumnWithTypeConverterFilters(column),
      );

  ColumnWithTypeConverterFilters<MailSettings?, MailSettings, String>
  get mail => $composableBuilder(
    column: $table.mail,
    builder: (column) => ColumnWithTypeConverterFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$AppSettingsTableOrderingComposer
    extends Composer<_$AppDatabase, $AppSettingsTable> {
  $$AppSettingsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get appName => $composableBuilder(
    column: $table.appName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get siteUrl => $composableBuilder(
    column: $table.siteUrl,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get redirectUrls => $composableBuilder(
    column: $table.redirectUrls,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get oauthProviders => $composableBuilder(
    column: $table.oauthProviders,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get s3 => $composableBuilder(
    column: $table.s3,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get mail => $composableBuilder(
    column: $table.mail,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$AppSettingsTableAnnotationComposer
    extends Composer<_$AppDatabase, $AppSettingsTable> {
  $$AppSettingsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get appName =>
      $composableBuilder(column: $table.appName, builder: (column) => column);

  GeneratedColumn<String> get siteUrl =>
      $composableBuilder(column: $table.siteUrl, builder: (column) => column);

  GeneratedColumnWithTypeConverter<List<String>, String> get redirectUrls =>
      $composableBuilder(
        column: $table.redirectUrls,
        builder: (column) => column,
      );

  GeneratedColumnWithTypeConverter<OAuthProviderList, String>
  get oauthProviders => $composableBuilder(
    column: $table.oauthProviders,
    builder: (column) => column,
  );

  GeneratedColumnWithTypeConverter<S3Settings?, String> get s3 =>
      $composableBuilder(column: $table.s3, builder: (column) => column);

  GeneratedColumnWithTypeConverter<MailSettings?, String> get mail =>
      $composableBuilder(column: $table.mail, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);
}

class $$AppSettingsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $AppSettingsTable,
          Settings,
          $$AppSettingsTableFilterComposer,
          $$AppSettingsTableOrderingComposer,
          $$AppSettingsTableAnnotationComposer,
          $$AppSettingsTableCreateCompanionBuilder,
          $$AppSettingsTableUpdateCompanionBuilder,
          (
            Settings,
            BaseReferences<_$AppDatabase, $AppSettingsTable, Settings>,
          ),
          Settings,
          PrefetchHooks Function()
        > {
  $$AppSettingsTableTableManager(_$AppDatabase db, $AppSettingsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$AppSettingsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$AppSettingsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$AppSettingsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> appName = const Value.absent(),
                Value<String> siteUrl = const Value.absent(),
                Value<List<String>> redirectUrls = const Value.absent(),
                Value<OAuthProviderList> oauthProviders = const Value.absent(),
                Value<S3Settings?> s3 = const Value.absent(),
                Value<MailSettings?> mail = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
              }) => AppSettingsCompanion(
                id: id,
                appName: appName,
                siteUrl: siteUrl,
                redirectUrls: redirectUrls,
                oauthProviders: oauthProviders,
                s3: s3,
                mail: mail,
                createdAt: createdAt,
                updatedAt: updatedAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String appName,
                Value<String> siteUrl = const Value.absent(),
                Value<List<String>> redirectUrls = const Value.absent(),
                required OAuthProviderList oauthProviders,
                Value<S3Settings?> s3 = const Value.absent(),
                Value<MailSettings?> mail = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
              }) => AppSettingsCompanion.insert(
                id: id,
                appName: appName,
                siteUrl: siteUrl,
                redirectUrls: redirectUrls,
                oauthProviders: oauthProviders,
                s3: s3,
                mail: mail,
                createdAt: createdAt,
                updatedAt: updatedAt,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$AppSettingsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $AppSettingsTable,
      Settings,
      $$AppSettingsTableFilterComposer,
      $$AppSettingsTableOrderingComposer,
      $$AppSettingsTableAnnotationComposer,
      $$AppSettingsTableCreateCompanionBuilder,
      $$AppSettingsTableUpdateCompanionBuilder,
      (Settings, BaseReferences<_$AppDatabase, $AppSettingsTable, Settings>),
      Settings,
      PrefetchHooks Function()
    >;
typedef $$OtpsTableCreateCompanionBuilder =
    OtpsCompanion Function({
      Value<int> id,
      required String email,
      required String otp,
      Value<DateTime> createdAt,
      Value<DateTime> expiresAt,
    });
typedef $$OtpsTableUpdateCompanionBuilder =
    OtpsCompanion Function({
      Value<int> id,
      Value<String> email,
      Value<String> otp,
      Value<DateTime> createdAt,
      Value<DateTime> expiresAt,
    });

class $$OtpsTableFilterComposer extends Composer<_$AppDatabase, $OtpsTable> {
  $$OtpsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get email => $composableBuilder(
    column: $table.email,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get otp => $composableBuilder(
    column: $table.otp,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get expiresAt => $composableBuilder(
    column: $table.expiresAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$OtpsTableOrderingComposer extends Composer<_$AppDatabase, $OtpsTable> {
  $$OtpsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get email => $composableBuilder(
    column: $table.email,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get otp => $composableBuilder(
    column: $table.otp,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get expiresAt => $composableBuilder(
    column: $table.expiresAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$OtpsTableAnnotationComposer
    extends Composer<_$AppDatabase, $OtpsTable> {
  $$OtpsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get email =>
      $composableBuilder(column: $table.email, builder: (column) => column);

  GeneratedColumn<String> get otp =>
      $composableBuilder(column: $table.otp, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get expiresAt =>
      $composableBuilder(column: $table.expiresAt, builder: (column) => column);
}

class $$OtpsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $OtpsTable,
          Otp,
          $$OtpsTableFilterComposer,
          $$OtpsTableOrderingComposer,
          $$OtpsTableAnnotationComposer,
          $$OtpsTableCreateCompanionBuilder,
          $$OtpsTableUpdateCompanionBuilder,
          (Otp, BaseReferences<_$AppDatabase, $OtpsTable, Otp>),
          Otp,
          PrefetchHooks Function()
        > {
  $$OtpsTableTableManager(_$AppDatabase db, $OtpsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$OtpsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$OtpsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$OtpsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> email = const Value.absent(),
                Value<String> otp = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> expiresAt = const Value.absent(),
              }) => OtpsCompanion(
                id: id,
                email: email,
                otp: otp,
                createdAt: createdAt,
                expiresAt: expiresAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String email,
                required String otp,
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> expiresAt = const Value.absent(),
              }) => OtpsCompanion.insert(
                id: id,
                email: email,
                otp: otp,
                createdAt: createdAt,
                expiresAt: expiresAt,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$OtpsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $OtpsTable,
      Otp,
      $$OtpsTableFilterComposer,
      $$OtpsTableOrderingComposer,
      $$OtpsTableAnnotationComposer,
      $$OtpsTableCreateCompanionBuilder,
      $$OtpsTableUpdateCompanionBuilder,
      (Otp, BaseReferences<_$AppDatabase, $OtpsTable, Otp>),
      Otp,
      PrefetchHooks Function()
    >;
typedef $$FilesTableCreateCompanionBuilder =
    FilesCompanion Function({
      Value<String> id,
      required String path,
      required String bucket,
      required bool isLocal,
      required int size,
      required String mimeType,
      Value<Map<String, Object?>?> metadata,
      required String downloadToken,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<int> rowid,
    });
typedef $$FilesTableUpdateCompanionBuilder =
    FilesCompanion Function({
      Value<String> id,
      Value<String> path,
      Value<String> bucket,
      Value<bool> isLocal,
      Value<int> size,
      Value<String> mimeType,
      Value<Map<String, Object?>?> metadata,
      Value<String> downloadToken,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<int> rowid,
    });

class $$FilesTableFilterComposer extends Composer<_$AppDatabase, $FilesTable> {
  $$FilesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get path => $composableBuilder(
    column: $table.path,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get bucket => $composableBuilder(
    column: $table.bucket,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isLocal => $composableBuilder(
    column: $table.isLocal,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get size => $composableBuilder(
    column: $table.size,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get mimeType => $composableBuilder(
    column: $table.mimeType,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<
    Map<String, Object?>?,
    Map<String, Object>?,
    String
  >
  get metadata => $composableBuilder(
    column: $table.metadata,
    builder: (column) => ColumnWithTypeConverterFilters(column),
  );

  ColumnFilters<String> get downloadToken => $composableBuilder(
    column: $table.downloadToken,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$FilesTableOrderingComposer
    extends Composer<_$AppDatabase, $FilesTable> {
  $$FilesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get path => $composableBuilder(
    column: $table.path,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get bucket => $composableBuilder(
    column: $table.bucket,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isLocal => $composableBuilder(
    column: $table.isLocal,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get size => $composableBuilder(
    column: $table.size,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get mimeType => $composableBuilder(
    column: $table.mimeType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get metadata => $composableBuilder(
    column: $table.metadata,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get downloadToken => $composableBuilder(
    column: $table.downloadToken,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$FilesTableAnnotationComposer
    extends Composer<_$AppDatabase, $FilesTable> {
  $$FilesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get path =>
      $composableBuilder(column: $table.path, builder: (column) => column);

  GeneratedColumn<String> get bucket =>
      $composableBuilder(column: $table.bucket, builder: (column) => column);

  GeneratedColumn<bool> get isLocal =>
      $composableBuilder(column: $table.isLocal, builder: (column) => column);

  GeneratedColumn<int> get size =>
      $composableBuilder(column: $table.size, builder: (column) => column);

  GeneratedColumn<String> get mimeType =>
      $composableBuilder(column: $table.mimeType, builder: (column) => column);

  GeneratedColumnWithTypeConverter<Map<String, Object?>?, String>
  get metadata =>
      $composableBuilder(column: $table.metadata, builder: (column) => column);

  GeneratedColumn<String> get downloadToken => $composableBuilder(
    column: $table.downloadToken,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);
}

class $$FilesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $FilesTable,
          DbFile,
          $$FilesTableFilterComposer,
          $$FilesTableOrderingComposer,
          $$FilesTableAnnotationComposer,
          $$FilesTableCreateCompanionBuilder,
          $$FilesTableUpdateCompanionBuilder,
          (DbFile, BaseReferences<_$AppDatabase, $FilesTable, DbFile>),
          DbFile,
          PrefetchHooks Function()
        > {
  $$FilesTableTableManager(_$AppDatabase db, $FilesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$FilesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$FilesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$FilesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> path = const Value.absent(),
                Value<String> bucket = const Value.absent(),
                Value<bool> isLocal = const Value.absent(),
                Value<int> size = const Value.absent(),
                Value<String> mimeType = const Value.absent(),
                Value<Map<String, Object?>?> metadata = const Value.absent(),
                Value<String> downloadToken = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => FilesCompanion(
                id: id,
                path: path,
                bucket: bucket,
                isLocal: isLocal,
                size: size,
                mimeType: mimeType,
                metadata: metadata,
                downloadToken: downloadToken,
                createdAt: createdAt,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                required String path,
                required String bucket,
                required bool isLocal,
                required int size,
                required String mimeType,
                Value<Map<String, Object?>?> metadata = const Value.absent(),
                required String downloadToken,
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => FilesCompanion.insert(
                id: id,
                path: path,
                bucket: bucket,
                isLocal: isLocal,
                size: size,
                mimeType: mimeType,
                metadata: metadata,
                downloadToken: downloadToken,
                createdAt: createdAt,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$FilesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $FilesTable,
      DbFile,
      $$FilesTableFilterComposer,
      $$FilesTableOrderingComposer,
      $$FilesTableAnnotationComposer,
      $$FilesTableCreateCompanionBuilder,
      $$FilesTableUpdateCompanionBuilder,
      (DbFile, BaseReferences<_$AppDatabase, $FilesTable, DbFile>),
      DbFile,
      PrefetchHooks Function()
    >;
typedef $$BucketsTableCreateCompanionBuilder =
    BucketsCompanion Function({
      required String name,
      Value<String?> listRule,
      Value<String?> createRule,
      Value<String?> updateRule,
      Value<String?> deleteRule,
      Value<String?> viewRule,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<int> rowid,
    });
typedef $$BucketsTableUpdateCompanionBuilder =
    BucketsCompanion Function({
      Value<String> name,
      Value<String?> listRule,
      Value<String?> createRule,
      Value<String?> updateRule,
      Value<String?> deleteRule,
      Value<String?> viewRule,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<int> rowid,
    });

class $$BucketsTableFilterComposer
    extends Composer<_$AppDatabase, $BucketsTable> {
  $$BucketsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get listRule => $composableBuilder(
    column: $table.listRule,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get createRule => $composableBuilder(
    column: $table.createRule,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get updateRule => $composableBuilder(
    column: $table.updateRule,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get deleteRule => $composableBuilder(
    column: $table.deleteRule,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get viewRule => $composableBuilder(
    column: $table.viewRule,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$BucketsTableOrderingComposer
    extends Composer<_$AppDatabase, $BucketsTable> {
  $$BucketsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get listRule => $composableBuilder(
    column: $table.listRule,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get createRule => $composableBuilder(
    column: $table.createRule,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get updateRule => $composableBuilder(
    column: $table.updateRule,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get deleteRule => $composableBuilder(
    column: $table.deleteRule,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get viewRule => $composableBuilder(
    column: $table.viewRule,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$BucketsTableAnnotationComposer
    extends Composer<_$AppDatabase, $BucketsTable> {
  $$BucketsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get listRule =>
      $composableBuilder(column: $table.listRule, builder: (column) => column);

  GeneratedColumn<String> get createRule => $composableBuilder(
    column: $table.createRule,
    builder: (column) => column,
  );

  GeneratedColumn<String> get updateRule => $composableBuilder(
    column: $table.updateRule,
    builder: (column) => column,
  );

  GeneratedColumn<String> get deleteRule => $composableBuilder(
    column: $table.deleteRule,
    builder: (column) => column,
  );

  GeneratedColumn<String> get viewRule =>
      $composableBuilder(column: $table.viewRule, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);
}

class $$BucketsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $BucketsTable,
          Bucket,
          $$BucketsTableFilterComposer,
          $$BucketsTableOrderingComposer,
          $$BucketsTableAnnotationComposer,
          $$BucketsTableCreateCompanionBuilder,
          $$BucketsTableUpdateCompanionBuilder,
          (Bucket, BaseReferences<_$AppDatabase, $BucketsTable, Bucket>),
          Bucket,
          PrefetchHooks Function()
        > {
  $$BucketsTableTableManager(_$AppDatabase db, $BucketsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$BucketsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$BucketsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$BucketsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> name = const Value.absent(),
                Value<String?> listRule = const Value.absent(),
                Value<String?> createRule = const Value.absent(),
                Value<String?> updateRule = const Value.absent(),
                Value<String?> deleteRule = const Value.absent(),
                Value<String?> viewRule = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => BucketsCompanion(
                name: name,
                listRule: listRule,
                createRule: createRule,
                updateRule: updateRule,
                deleteRule: deleteRule,
                viewRule: viewRule,
                createdAt: createdAt,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String name,
                Value<String?> listRule = const Value.absent(),
                Value<String?> createRule = const Value.absent(),
                Value<String?> updateRule = const Value.absent(),
                Value<String?> deleteRule = const Value.absent(),
                Value<String?> viewRule = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => BucketsCompanion.insert(
                name: name,
                listRule: listRule,
                createRule: createRule,
                updateRule: updateRule,
                deleteRule: deleteRule,
                viewRule: viewRule,
                createdAt: createdAt,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$BucketsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $BucketsTable,
      Bucket,
      $$BucketsTableFilterComposer,
      $$BucketsTableOrderingComposer,
      $$BucketsTableAnnotationComposer,
      $$BucketsTableCreateCompanionBuilder,
      $$BucketsTableUpdateCompanionBuilder,
      (Bucket, BaseReferences<_$AppDatabase, $BucketsTable, Bucket>),
      Bucket,
      PrefetchHooks Function()
    >;
typedef $$OauthStatesTableCreateCompanionBuilder =
    OauthStatesCompanion Function({
      Value<int> id,
      required String state,
      required String provider,
      required String redirectUrl,
      Value<DateTime> createdAt,
      Value<DateTime> expiresAt,
    });
typedef $$OauthStatesTableUpdateCompanionBuilder =
    OauthStatesCompanion Function({
      Value<int> id,
      Value<String> state,
      Value<String> provider,
      Value<String> redirectUrl,
      Value<DateTime> createdAt,
      Value<DateTime> expiresAt,
    });

class $$OauthStatesTableFilterComposer
    extends Composer<_$AppDatabase, $OauthStatesTable> {
  $$OauthStatesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get state => $composableBuilder(
    column: $table.state,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get provider => $composableBuilder(
    column: $table.provider,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get redirectUrl => $composableBuilder(
    column: $table.redirectUrl,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get expiresAt => $composableBuilder(
    column: $table.expiresAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$OauthStatesTableOrderingComposer
    extends Composer<_$AppDatabase, $OauthStatesTable> {
  $$OauthStatesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get state => $composableBuilder(
    column: $table.state,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get provider => $composableBuilder(
    column: $table.provider,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get redirectUrl => $composableBuilder(
    column: $table.redirectUrl,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get expiresAt => $composableBuilder(
    column: $table.expiresAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$OauthStatesTableAnnotationComposer
    extends Composer<_$AppDatabase, $OauthStatesTable> {
  $$OauthStatesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get state =>
      $composableBuilder(column: $table.state, builder: (column) => column);

  GeneratedColumn<String> get provider =>
      $composableBuilder(column: $table.provider, builder: (column) => column);

  GeneratedColumn<String> get redirectUrl => $composableBuilder(
    column: $table.redirectUrl,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get expiresAt =>
      $composableBuilder(column: $table.expiresAt, builder: (column) => column);
}

class $$OauthStatesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $OauthStatesTable,
          OauthState,
          $$OauthStatesTableFilterComposer,
          $$OauthStatesTableOrderingComposer,
          $$OauthStatesTableAnnotationComposer,
          $$OauthStatesTableCreateCompanionBuilder,
          $$OauthStatesTableUpdateCompanionBuilder,
          (
            OauthState,
            BaseReferences<_$AppDatabase, $OauthStatesTable, OauthState>,
          ),
          OauthState,
          PrefetchHooks Function()
        > {
  $$OauthStatesTableTableManager(_$AppDatabase db, $OauthStatesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$OauthStatesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$OauthStatesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$OauthStatesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> state = const Value.absent(),
                Value<String> provider = const Value.absent(),
                Value<String> redirectUrl = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> expiresAt = const Value.absent(),
              }) => OauthStatesCompanion(
                id: id,
                state: state,
                provider: provider,
                redirectUrl: redirectUrl,
                createdAt: createdAt,
                expiresAt: expiresAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String state,
                required String provider,
                required String redirectUrl,
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> expiresAt = const Value.absent(),
              }) => OauthStatesCompanion.insert(
                id: id,
                state: state,
                provider: provider,
                redirectUrl: redirectUrl,
                createdAt: createdAt,
                expiresAt: expiresAt,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$OauthStatesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $OauthStatesTable,
      OauthState,
      $$OauthStatesTableFilterComposer,
      $$OauthStatesTableOrderingComposer,
      $$OauthStatesTableAnnotationComposer,
      $$OauthStatesTableCreateCompanionBuilder,
      $$OauthStatesTableUpdateCompanionBuilder,
      (
        OauthState,
        BaseReferences<_$AppDatabase, $OauthStatesTable, OauthState>,
      ),
      OauthState,
      PrefetchHooks Function()
    >;
typedef $$ExternalAuthsTableCreateCompanionBuilder =
    ExternalAuthsCompanion Function({
      Value<int> id,
      required String userId,
      required String provider,
      required String providerId,
      Value<DateTime> createdAt,
    });
typedef $$ExternalAuthsTableUpdateCompanionBuilder =
    ExternalAuthsCompanion Function({
      Value<int> id,
      Value<String> userId,
      Value<String> provider,
      Value<String> providerId,
      Value<DateTime> createdAt,
    });

class $$ExternalAuthsTableFilterComposer
    extends Composer<_$AppDatabase, $ExternalAuthsTable> {
  $$ExternalAuthsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get userId => $composableBuilder(
    column: $table.userId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get provider => $composableBuilder(
    column: $table.provider,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get providerId => $composableBuilder(
    column: $table.providerId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$ExternalAuthsTableOrderingComposer
    extends Composer<_$AppDatabase, $ExternalAuthsTable> {
  $$ExternalAuthsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get userId => $composableBuilder(
    column: $table.userId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get provider => $composableBuilder(
    column: $table.provider,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get providerId => $composableBuilder(
    column: $table.providerId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$ExternalAuthsTableAnnotationComposer
    extends Composer<_$AppDatabase, $ExternalAuthsTable> {
  $$ExternalAuthsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get userId =>
      $composableBuilder(column: $table.userId, builder: (column) => column);

  GeneratedColumn<String> get provider =>
      $composableBuilder(column: $table.provider, builder: (column) => column);

  GeneratedColumn<String> get providerId => $composableBuilder(
    column: $table.providerId,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);
}

class $$ExternalAuthsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $ExternalAuthsTable,
          ExternalAuth,
          $$ExternalAuthsTableFilterComposer,
          $$ExternalAuthsTableOrderingComposer,
          $$ExternalAuthsTableAnnotationComposer,
          $$ExternalAuthsTableCreateCompanionBuilder,
          $$ExternalAuthsTableUpdateCompanionBuilder,
          (
            ExternalAuth,
            BaseReferences<_$AppDatabase, $ExternalAuthsTable, ExternalAuth>,
          ),
          ExternalAuth,
          PrefetchHooks Function()
        > {
  $$ExternalAuthsTableTableManager(_$AppDatabase db, $ExternalAuthsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ExternalAuthsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ExternalAuthsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ExternalAuthsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> userId = const Value.absent(),
                Value<String> provider = const Value.absent(),
                Value<String> providerId = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
              }) => ExternalAuthsCompanion(
                id: id,
                userId: userId,
                provider: provider,
                providerId: providerId,
                createdAt: createdAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String userId,
                required String provider,
                required String providerId,
                Value<DateTime> createdAt = const Value.absent(),
              }) => ExternalAuthsCompanion.insert(
                id: id,
                userId: userId,
                provider: provider,
                providerId: providerId,
                createdAt: createdAt,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$ExternalAuthsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $ExternalAuthsTable,
      ExternalAuth,
      $$ExternalAuthsTableFilterComposer,
      $$ExternalAuthsTableOrderingComposer,
      $$ExternalAuthsTableAnnotationComposer,
      $$ExternalAuthsTableCreateCompanionBuilder,
      $$ExternalAuthsTableUpdateCompanionBuilder,
      (
        ExternalAuth,
        BaseReferences<_$AppDatabase, $ExternalAuthsTable, ExternalAuth>,
      ),
      ExternalAuth,
      PrefetchHooks Function()
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$UsersTableTableManager get users =>
      $$UsersTableTableManager(_db, _db.users);
  $$RefreshTokensTableTableManager get refreshTokens =>
      $$RefreshTokensTableTableManager(_db, _db.refreshTokens);
  $$ResetPasswordTokensTableTableManager get resetPasswordTokens =>
      $$ResetPasswordTokensTableTableManager(_db, _db.resetPasswordTokens);
  $$LogsTableTableManager get logs => $$LogsTableTableManager(_db, _db.logs);
  $$CollectionsTableTableManager get collections =>
      $$CollectionsTableTableManager(_db, _db.collections);
  $$AppSettingsTableTableManager get appSettings =>
      $$AppSettingsTableTableManager(_db, _db.appSettings);
  $$OtpsTableTableManager get otps => $$OtpsTableTableManager(_db, _db.otps);
  $$FilesTableTableManager get files =>
      $$FilesTableTableManager(_db, _db.files);
  $$BucketsTableTableManager get buckets =>
      $$BucketsTableTableManager(_db, _db.buckets);
  $$OauthStatesTableTableManager get oauthStates =>
      $$OauthStatesTableTableManager(_db, _db.oauthStates);
  $$ExternalAuthsTableTableManager get externalAuths =>
      $$ExternalAuthsTableTableManager(_db, _db.externalAuths);
}
