import 'dart:io';

import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';
import 'package:vanestack_common/vanestack_common.dart';

import '../database/database.dart';
import '../utils/auth.dart';
import '../utils/extensions.dart';
import '../utils/filter_parser.dart';
import '../utils/logger.dart';
import '../utils/order_clause_parser.dart';
import '../utils/validation.dart';
import 'context.dart';
import 'hooks.dart';

/// Service class for user CRUD operations.
///
/// This service handles all user-related business logic and can be used by:
/// - HTTP endpoints
/// - CLI commands
/// - Public API (`vanestack.users.create()`, etc.)
class UsersService {
  final ServiceContext context;

  UsersService(this.context);

  AppDatabase get db => context.database;

  /// Creates a new user.
  ///
  /// Throws [VaneStackException] if:
  /// - Email is invalid
  /// - User ID format is invalid (when provided)
  /// - A user with this email already exists
  /// - Password doesn't meet strength requirements (when provided)
  Future<User> create({
    String? id,
    required String email,
    String? password,
    String? name,
    bool superUser = false,
  }) async {
    final formattedEmail = email.trim().toLowerCase();
    if (!validateEmail(formattedEmail)) {
      throw VaneStackException(
        'Invalid email address.',
        status: HttpStatus.badRequest,
        code: UsersErrorCode.invalidEmail,
      );
    }

    if (id != null && !validateUuid(id)) {
      throw VaneStackException(
        'Invalid user ID format.',
        status: HttpStatus.badRequest,
        code: UsersErrorCode.invalidUserId,
      );
    }

    final userExists = await db.users
        .count(where: (t) => t.email.equals(formattedEmail))
        .getSingle()
        .then((count) => count > 0);

    if (userExists) {
      throw VaneStackException(
        'A user with this email already exists.',
        status: HttpStatus.conflict,
        code: UsersErrorCode.emailAlreadyExists,
      );
    }

    if (context.hooks != null) {
      final e = BeforeUserCreateEvent(
        email: formattedEmail,
        name: name,
        password: password,
        superUser: superUser,
      );
      await context.hooks!.runBeforeUserCreate(e);
      email = e.email;
      name = e.name;
      password = e.password;
      superUser = e.superUser;
    }

    usersLogger.debug('Creating user', context: 'email=$formattedEmail');

    final userId = id ?? const Uuid().v7();

    if (password != null) {
      final validationError = AuthUtils.validatePasswordStrength(password);
      if (validationError != null) {
        throw VaneStackException(
          validationError,
          status: HttpStatus.badRequest,
          code: UsersErrorCode.weakPassword,
        );
      }
    }

    final hashedPassword = password != null
        ? await AuthUtils.hashPassword(password)
        : null;

    final user = await db.users.insertReturning(
      UsersCompanion.insert(
        id: userId,
        email: formattedEmail,
        passwordHash: Value.absentIfNull(hashedPassword),
        name: Value.absentIfNull(name),
        superUser: Value(superUser),
      ),
    );

    final result = user.toPublic(); // New users have no providers yet

    usersLogger.info(
      'User created',
      context: 'email=$formattedEmail',
      userId: userId,
    );

    if (context.hooks != null) {
      await context.hooks!.runAfterUserCreate(
        AfterUserCreateEvent(result: result),
      );
    }

    return result;
  }

  /// Gets a user by ID.
  ///
  /// Returns `null` if user not found.
  Future<User?> getById(String id) async {
    final user = await (db.users.select()..where((u) => u.id.equals(id)))
        .getSingleOrNull();
    if (user == null) return null;

    final providers = await _getProviders([user.id]);
    return user.toPublic(providers: providers[user.id] ?? []);
  }

  /// Gets a user by email.
  ///
  /// Returns `null` if user not found.
  Future<User?> getByEmail(String email) async {
    final formattedEmail = email.trim().toLowerCase();
    final user =
        await (db.users.select()..where((u) => u.email.equals(formattedEmail)))
            .getSingleOrNull();
    if (user == null) return null;

    final providers = await _getProviders([user.id]);
    return user.toPublic(providers: providers[user.id] ?? []);
  }

  /// Lists users with optional filtering, ordering, and pagination.
  Future<ListUsersResult> list({
    String? filter,
    String? orderBy,
    int limit = 10,
    int offset = 0,
  }) async {
    final query = db.users.select();
    var countQuery = db.users.selectOnly();
    countQuery.addColumns([db.users.id.count()]);

    query.limit(limit, offset: offset);

    if (orderBy != null) {
      final (_, clauses) = OrderClauseParser(orderBy).parse();

      query.orderBy([
        for (final clause in clauses)
          (t) => OrderingTerm(
            expression: t.columnsByName[clause.$1]!,
            mode: clause.$2 == 'ASC' ? OrderingMode.asc : OrderingMode.desc,
          ),
      ]);
    }

    final variables = <Object?>[];
    if (filter != null) {
      final (whereClause, paramValues) = FilterParser(filter).parse();
      if (whereClause.isNotEmpty) {
        query.where((_) => CustomExpression<bool>(whereClause));
        countQuery.where(CustomExpression<bool>(whereClause));

        variables.addAll(paramValues);
      }
    }

    final users = await db
        .customSelect(
          query.constructQuery().sql,
          variables: [...variables.map((value) => Variable(value))],
        )
        .map((row) => db.users.map(row.data))
        .get();

    final count = await db
        .customSelect(
          countQuery.constructQuery().sql,
          variables: [...variables.map((value) => Variable(value))],
        )
        .map((row) => row.read<int>('c0'))
        .getSingle();

    final userIds = users.map((e) => e.id).toList();
    final providers = await _getProviders(userIds);

    return ListUsersResult(
      users: users
          .map((e) => e.toPublic(providers: providers[e.id] ?? []))
          .toList(),
      count: count,
    );
  }

  /// Updates a user.
  ///
  /// Throws [VaneStackException] if:
  /// - User not found
  /// - Email is invalid (when provided)
  /// - Password doesn't meet strength requirements (when provided)
  Future<User> update({
    required String id,
    String? email,
    String? password,
    String? name,
    bool? superUser,
  }) async {
    if (email != null) {
      final formattedEmail = email.trim().toLowerCase();
      if (!validateEmail(formattedEmail)) {
        throw VaneStackException(
          'Invalid email address.',
          status: HttpStatus.badRequest,
          code: UsersErrorCode.invalidEmail,
        );
      }
    }

    if (password != null) {
      final validationError = AuthUtils.validatePasswordStrength(password);
      if (validationError != null) {
        throw VaneStackException(
          validationError,
          status: HttpStatus.badRequest,
          code: UsersErrorCode.weakPassword,
        );
      }
    }

    if (context.hooks != null) {
      final e = BeforeUserUpdateEvent(
        id: id,
        email: email,
        name: name,
        password: password,
        superUser: superUser,
      );
      await context.hooks!.runBeforeUserUpdate(e);
      email = e.email;
      name = e.name;
      password = e.password;
      superUser = e.superUser;
    }

    final passwordHash = password != null
        ? await AuthUtils.hashPassword(password)
        : null;

    usersLogger.debug('Updating user', userId: id);

    await db.managers.users
        .filter((t) => t.id.equals(id))
        .update(
          (t) => t(
            updatedAt: Value(DateTime.now()),
            name: Value.absentIfNull(name),
            superUser: Value.absentIfNull(superUser),
            email: Value.absentIfNull(email?.trim().toLowerCase()),
            passwordHash: Value.absentIfNull(passwordHash),
          ),
        );

    final user = await (db.users.select()..where((u) => u.id.equals(id)))
        .getSingleOrNull();

    if (user == null) {
      throw VaneStackException(
        'User not found.',
        status: HttpStatus.notFound,
        code: UsersErrorCode.userNotFound,
      );
    }

    final providers = await _getProviders([user.id]);
    final result = user.toPublic(providers: providers[user.id] ?? []);

    usersLogger.info('User updated', userId: id);

    if (context.hooks != null) {
      await context.hooks!.runAfterUserUpdate(
        AfterUserUpdateEvent(result: result),
      );
    }

    return result;
  }

  /// Deletes a user by ID.
  Future<void> delete(String id) async {
    if (context.hooks != null) {
      final e = BeforeUserDeleteEvent(id: id);
      await context.hooks!.runBeforeUserDelete(e);
    }

    await db.users.deleteWhere((u) => u.id.equals(id));

    usersLogger.info('User deleted', userId: id);

    if (context.hooks != null) {
      await context.hooks!.runAfterUserDelete(AfterUserDeleteEvent(id: id));
    }
  }

  /// Deletes a user by email.
  Future<void> deleteByEmail(String email) async {
    final formattedEmail = email.trim().toLowerCase();
    await db.users.deleteWhere((u) => u.email.equals(formattedEmail));
  }

  /// Batch-fetches provider names for a list of user IDs.
  Future<Map<String, List<String>>> _getProviders(List<String> userIds) async {
    if (userIds.isEmpty) return {};
    final rows = await (db.externalAuths.select()
          ..where((e) => e.userId.isIn(userIds)))
        .get();
    final map = <String, List<String>>{};
    for (final row in rows) {
      (map[row.userId] ??= []).add(row.provider);
    }
    return map;
  }
}
