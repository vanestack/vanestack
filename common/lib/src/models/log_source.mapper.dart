// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
// ignore_for_file: type=lint
// ignore_for_file: unused_element, unnecessary_cast, override_on_non_overriding_member
// ignore_for_file: strict_raw_type, inference_failure_on_untyped_parameter

part of 'log_source.dart';

class LogSourceMapper extends EnumMapper<LogSource> {
  LogSourceMapper._();

  static LogSourceMapper? _instance;
  static LogSourceMapper ensureInitialized() {
    if (_instance == null) {
      MapperContainer.globals.use(_instance = LogSourceMapper._());
    }
    return _instance!;
  }

  static LogSource fromValue(dynamic value) {
    ensureInitialized();
    return MapperContainer.globals.fromValue(value);
  }

  @override
  LogSource decode(dynamic value) {
    switch (value) {
      case r'server':
        return LogSource.server;
      case r'auth':
        return LogSource.auth;
      case r'users':
        return LogSource.users;
      case r'database':
        return LogSource.database;
      case r'storage':
        return LogSource.storage;
      case r'realtime':
        return LogSource.realtime;
      case r'collections':
        return LogSource.collections;
      case r'http':
        return LogSource.http;
      case r'custom':
        return LogSource.custom;
      default:
        throw MapperException.unknownEnumValue(value);
    }
  }

  @override
  dynamic encode(LogSource self) {
    switch (self) {
      case LogSource.server:
        return r'server';
      case LogSource.auth:
        return r'auth';
      case LogSource.users:
        return r'users';
      case LogSource.database:
        return r'database';
      case LogSource.storage:
        return r'storage';
      case LogSource.realtime:
        return r'realtime';
      case LogSource.collections:
        return r'collections';
      case LogSource.http:
        return r'http';
      case LogSource.custom:
        return r'custom';
    }
  }
}

extension LogSourceMapperExtension on LogSource {
  String toValue() {
    LogSourceMapper.ensureInitialized();
    return MapperContainer.globals.toValue<LogSource>(this) as String;
  }
}

