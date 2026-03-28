import 'dart:async';

import 'package:drift/drift.dart' as drift;
import 'package:vanestack_common/vanestack_common.dart';

import '../database/database.dart';

/// Minimum log level to output to console
LogLevel _logLevel = LogLevel.info;

/// ANSI color codes
const _reset = '\x1B[0m';
const _gray = '\x1B[90m';
const _blue = '\x1B[34m';
const _cyan = '\x1B[36m';
const _bold = '\x1B[1m';
const _red = '\x1B[31m';
const _yellow = '\x1B[33m';

/// Centralized logging utility for the VaneStack application.
///
/// Provides structured logging with multiple log levels (debug, info, warn, error)
/// and outputs to both console (with colors) and database for persistence.
///
/// Use the built-in loggers for framework components, or create custom loggers:
/// ```dart
/// final log = Logger.custom('Payments');
/// log.info('Invoice processed', context: 'invoice=$id');
/// ```
class Logger {
  /// The source/component for log entries
  final LogSource source;

  /// Freeform name for custom loggers (only used when source is [LogSource.custom]).
  final String? _customName;

  /// Display name shown in console output and stored in the database.
  String get displayName =>
      source == LogSource.custom ? (_customName ?? 'custom') : source.name;

  /// Static database reference for persistence
  static AppDatabase? _database;

  static final List<LogsCompanion> _buffer = [];
  static const _batchSize = 50;
  static Timer? _flushTimer;

  Logger(this.source) : _customName = null;

  /// Creates a logger with a custom source name.
  ///
  /// Use this to create loggers for your own components:
  /// ```dart
  /// final log = Logger.custom('Payments');
  /// log.info('Invoice processed');
  /// ```
  Logger.custom(String name) : source = LogSource.custom, _customName = name;

  static Future<void> _flush() async {
    _flushTimer?.cancel();
    _flushTimer = null;
    if (_buffer.isEmpty) return;
    final db = _database;
    if (db == null) {
      _buffer.clear();
      return;
    }
    final entries = List<LogsCompanion>.from(_buffer);
    _buffer.clear();
    try {
      await db.batch((batch) {
        batch.insertAll(db.logs, entries);
      });
    } catch (_) {
      // Best-effort logging — don't crash on DB errors
    }
  }

  /// Log a debug message - detailed information for debugging
  void debug(String message, {String? context, String? userId}) {
    _log(LogLevel.debug, message, context: context, userId: userId);
  }

  /// Log an info message - general operational information
  void info(String message, {String? context, String? userId}) {
    _log(LogLevel.info, message, context: context, userId: userId);
  }

  /// Log a warning message - potentially problematic situations
  void warn(String message, {String? context, String? userId}) {
    _log(LogLevel.warn, message, context: context, userId: userId);
  }

  /// Log an error message - errors and exceptions
  void error(
    String message, {
    Object? error,
    StackTrace? stackTrace,
    String? context,
    String? userId,
  }) {
    _log(
      LogLevel.error,
      message,
      context: context,
      userId: userId,
      errorObj: error,
      stackTrace: stackTrace,
    );
  }

  void _log(
    LogLevel level,
    String message, {
    String? context,
    String? userId,
    Object? errorObj,
    StackTrace? stackTrace,
  }) async {
    // Output to console if level meets threshold
    if (level.index >= _logLevel.index) {
      _printToConsole(
        level,
        message,
        context: context,
        errorObj: errorObj,
        stackTrace: stackTrace,
      );
    }

    // Buffer for batch insert
    final db = _database;
    if (db != null) {
      _buffer.add(
        LogsCompanion.insert(
          level: level,
          source: source,
          customSource: drift.Value(_customName),
          message: message,
          context: drift.Value(context),
          userId: drift.Value(userId),
          error: drift.Value(errorObj?.toString()),
          stackTrace: drift.Value(stackTrace?.toString()),
        ),
      );
      if (_buffer.length >= _batchSize) {
        unawaited(_flush());
      } else {
        _flushTimer ??= Timer(Duration(seconds: 2), _flush);
      }
    }
  }

  void _printToConsole(
    LogLevel level,
    String message, {
    String? context,
    Object? errorObj,
    StackTrace? stackTrace,
  }) {
    final now = DateTime.now();
    final timeStr = now.toIso8601String().split('T').last.substring(0, 12);

    final levelStr = _formatLevel(level);
    final sourceStr = '$_cyan[$displayName]$_reset';

    final parts = <String>[
      '$_gray$timeStr$_reset',
      levelStr,
      sourceStr,
      message,
    ];

    if (context != null) {
      parts.add('$_gray($context)$_reset');
    }

    print(parts.join(' '));

    if (errorObj != null) {
      print('  $_gray\u2514\u2500 Error: $errorObj$_reset');
    }

    if (stackTrace != null) {
      final lines = stackTrace.toString().split('\n').take(5);
      for (final line in lines) {
        print('  $_gray   $line$_reset');
      }
    }
  }

  String _formatLevel(LogLevel level) {
    switch (level) {
      case LogLevel.debug:
        return '$_gray${_bold}DEBUG$_reset';
      case LogLevel.info:
        return '$_blue${_bold}INFO$_reset ';
      case LogLevel.warn:
        return '$_yellow${_bold}WARN$_reset ';
      case LogLevel.error:
        return '$_red${_bold}ERROR$_reset';
      case LogLevel.none:
        return '';
    }
  }
}

/// Global loggers for common components
final serverLogger = Logger(LogSource.server);
final authLogger = Logger(LogSource.auth);
final usersLogger = Logger(LogSource.users);
final dbLogger = Logger(LogSource.database);
final storageLogger = Logger(LogSource.storage);
final realtimeLogger = Logger(LogSource.realtime);
final collectionsLogger = Logger(LogSource.collections);
final httpLogger = Logger(LogSource.http);

/// Configure the logging system with database and log level.
///
/// Internal — called by VaneStackServer on startup. Not exported in the public API.
void configureLogger({
  LogLevel? logLevel,
  AppDatabase? database,
  bool clearDatabase = false,
}) {
  if (logLevel != null) _logLevel = logLevel;
  if (database != null) Logger._database = database;
  if (clearDatabase) Logger._database = null;
}

/// Flush any buffered log entries to the database.
///
/// Internal — called by VaneStackServer on shutdown. Not exported in the public API.
Future<void> shutdownLogger() async {
  Logger._flushTimer?.cancel();
  Logger._flushTimer = null;
  await Logger._flush();
}
