// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
// ignore_for_file: type=lint
// ignore_for_file: unused_element, unnecessary_cast, override_on_non_overriding_member
// ignore_for_file: strict_raw_type, inference_failure_on_untyped_parameter

part of 'user_type.dart';

class UserTypeMapper extends EnumMapper<UserType> {
  UserTypeMapper._();

  static UserTypeMapper? _instance;
  static UserTypeMapper ensureInitialized() {
    if (_instance == null) {
      MapperContainer.globals.use(_instance = UserTypeMapper._());
    }
    return _instance!;
  }

  static UserType fromValue(dynamic value) {
    ensureInitialized();
    return MapperContainer.globals.fromValue(value);
  }

  @override
  UserType decode(dynamic value) {
    switch (value) {
      case r'admin':
        return UserType.admin;
      case r'user':
        return UserType.user;
      case r'guest':
        return UserType.guest;
      default:
        throw MapperException.unknownEnumValue(value);
    }
  }

  @override
  dynamic encode(UserType self) {
    switch (self) {
      case UserType.admin:
        return r'admin';
      case UserType.user:
        return r'user';
      case UserType.guest:
        return r'guest';
    }
  }
}

extension UserTypeMapperExtension on UserType {
  String toValue() {
    UserTypeMapper.ensureInitialized();
    return MapperContainer.globals.toValue<UserType>(this) as String;
  }
}

