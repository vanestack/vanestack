import 'dart:async';

import 'package:analyzer/dart/element/element.dart';
import 'package:analyzer/dart/element/nullability_suffix.dart';
import 'package:analyzer/dart/element/type.dart' hide FunctionType;
import 'package:build/build.dart';
import 'package:code_builder/code_builder.dart';
import 'package:vanestack_annotation/vanestack_annotation.dart' show HttpMethod;
import 'package:dart_style/dart_style.dart';

import 'find_routes.dart';

Builder routeBuilder(BuilderOptions options) => RouteBuilder();

class RouteBuilder implements Builder {
  final _dartFormatter = DartFormatter(
    languageVersion: DartFormatter.latestLanguageVersion,
  );

  final _dartIo = 'dart:io';
  final _dartAsync = 'dart:async';
  final _dartConvert = 'dart:convert';
  final _shelf = 'package:shelf/shelf.dart';
  final _uuid = 'package:uuid/uuid.dart';
  final _shelfRouter = 'package:shelf_router/shelf_router.dart';
  final _sseHandler = 'package:vanestack/src/handlers/sse.dart';
  final _logs = 'package:vanestack_common/vanestack_common.dart';

  @override
  Future<void> build(BuildStep buildStep) async {
    final routes = await findRoutes(buildStep);

    final sortedRoutes = [...routes]
      ..sort((a, b) {
        final aHasParams = a.path.contains('<');
        final bHasParams = b.path.contains('<');
        if (aHasParams == bHasParams) return a.path.compareTo(b.path);
        return aHasParams ? 1 : -1; // static routes first
      });

    final library = Library((lib) {
      lib.directives.add(
        Directive.import('package:vanestack_common/vanestack_common.dart'),
      );

      // ====== RequestUtils extension ======
      lib.body.add(_buildRequestUtilsExtension());
      lib.body.add(_buildCleanParam());

      // ====== Helper functions ======
      lib.body.add(_buildStringToDartTypeFunction());
      lib.body.add(_buildDefaultErrorHandlerFunction());

      // ====== Route handlers ======
      for (final (index, route) in sortedRoutes.indexed) {
        lib.body.add(_buildRouteHandler(index, route));
      }

      // ====== registerRoutes() ======
      lib.body.add(_buildRegisterRoutesFunction(sortedRoutes));
    });

    final emitter = DartEmitter.scoped();
    final generatedCode = _dartFormatter.format(
      '// GENERATED CODE - DO NOT MODIFY BY HAND\n\n${library.accept(emitter)}',
    );

    await buildStep.writeAsString(
      AssetId(buildStep.inputId.package, 'lib/src/routes.dart'),
      generatedCode,
    );

    // Also generate routes_info.dart with plain data for the generate command
    final routesInfoCode = _buildRoutesInfo(sortedRoutes);
    await buildStep.writeAsString(
      AssetId(buildStep.inputId.package, 'lib/src/routes_info.dart'),
      routesInfoCode,
    );
  }

  @override
  final buildExtensions = const {
    r'$package$': ['lib/src/routes.dart', 'lib/src/routes_info.dart'],
  };

  // ---------------------------------------------------------------------------
  // Helper builders below
  // ---------------------------------------------------------------------------

  Extension _buildRequestUtilsExtension() {
    return Extension((ext) {
      ext.name = 'RequestUtils';
      ext.on = refer('Request', _shelf);

      ext.methods.add(
        Method((m) {
          m.name = 'toMap';
          m.returns = TypeReference(
            (t) => t
              ..symbol = 'Future'
              ..types.add(
                TypeReference(
                  (t) => t
                    ..symbol = 'Map'
                    ..types.addAll([refer('String'), refer('Object?')]),
                ),
              ),
          );
          m.modifier = MethodModifier.async;

          m.body = Block.of([
            Code('''
          final contentType = headers['content-type'] ?? '';
          final body = await readAsString();

          if (body.isEmpty) {
            return {};
          }

          if (contentType.contains('application/json')) {
          '''),

            declareFinal('decoded')
                .assign(refer('jsonDecode', _dartConvert).call([refer('body')]))
                .statement,
            Code('''
            if (decoded is Map) {
              return Map<String, Object?>.from(decoded);
            } else {
              throw FormatException('JSON body is not an object');
            }
          }

          if (contentType.contains('application/x-www-form-urlencoded')) {
            final formData = Uri.splitQueryString(body);
            return Map<String, Object?>.from(formData);
          }

          // Fallback
          return {};
          '''),
          ]);
        }),
      );
    });
  }

  Method _buildStringToDartTypeFunction() {
    return Method((m) {
      m.name = 'stringToDartType';
      m.requiredParameters.add(
        Parameter(
          (p) => p
            ..name = 'value'
            ..type = refer('String'),
        ),
      );
      m.returns = refer('Object?');
      m.body = Code('''
      return switch (value) {
        'null' => null,
        'true' => true,
        'false' => false,
        _ when int.tryParse(value) != null => int.parse(value),
        _ when double.tryParse(value) != null => double.parse(value),
        _ when DateTime.tryParse(value) != null => DateTime.parse(value),
        _ => value,
      };
      ''');
    });
  }

  Method _buildCleanParam() {
    return Method((m) {
      m.name = 'cleanParam';
      m.requiredParameters.add(
        Parameter(
          (p) => p
            ..name = 'pathSegment'
            ..type = refer('String'),
        ),
      );
      m.returns = refer('String');
      m.body = Code('''
      // Split by '?' and take the first part
      var parts = pathSegment.split('?');
      var value = parts.first.trim();

      parts = value.split('%3F'); // URL-encoded '?'
      value = parts.first.trim();

      return value;
      ''');
    });
  }

  Method _buildDefaultErrorHandlerFunction() {
    return Method((m) {
      m.name = 'catchError';
      m.modifier = MethodModifier.async;
      m.returns = TypeReference(
        (t) => t
          ..url = _dartAsync
          ..symbol = 'Future'
          ..types.add(refer('Response', _shelf)),
      );
      m.requiredParameters.add(
        Parameter(
          (p) => p
            ..name = 'wrapper'
            ..type = FunctionType(
              (ft) => ft.returnType = TypeReference(
                (t) => t
                  ..symbol = 'Future'
                  ..types.add(
                    TypeReference(
                      (s) => s
                        ..symbol = 'Response'
                        ..url = _shelf,
                    ),
                  ),
              ),
            ),
        ),
      );

      m.body = Block.of([
        Code('try {'),
        refer('wrapper').call([]).awaited.returned.statement,
        Code('} on VaneStackException catch (e) {'),
        _response(refer('e').property('status'), refer('e')).returned.statement,
        Code('} on '),
        refer('HijackException', _shelf).code,
        Code('{ rethrow;'),
        Code('} catch (e) {'),
        _response(
          refer('HttpStatus', _dartIo).property('internalServerError'),
          literalMap({
            'error': literalMap({
              'message': refer('e').property('toString').call([]),
            }),
          }),
        ).returned.statement,
        Code('}'),
      ]);
    });
  }

  Method _buildRouteHandler(int index, RouteDetail route) {
    final methodName = '${route.functionName}${index}Route';

    final params = [
      Parameter(
        (p) => p
          ..name = 'request'
          ..type = refer('Request', _shelf),
      ),
      ...route.pathParams.map(
        (p) => Parameter(
          (param) => param
            ..name = p
            ..type = refer('String'),
        ),
      ),
    ];

    // Call actual function
    final returnType = route.returnType.getDisplayString();
    final isSseRoute = route.returnType.isDartAsyncStream;

    return Method((m) {
      m.name = methodName;
      m.returns = TypeReference(
        (t) => t
          ..url = _dartAsync
          ..symbol = 'FutureOr'
          ..types.add(refer('Response', _shelf)),
      );

      m.modifier = MethodModifier.async;
      m.requiredParameters.addAll(params);
      m.body = Block.of([
        if (route.requiresAuth || route.requiresSuperUserAuth) ...[
          declareFinal('userType')
              .assign(
                refer('request')
                    .property('context')
                    .index(literalString('userType'))
                    .asA(refer('UserType', _logs)),
              )
              .statement,
          Code('if ('),
          route.requiresSuperUserAuth
              ? refer(
                  'userType',
                ).notEqualTo(refer('UserType', _logs).property('admin')).code
              : refer(
                  'userType',
                ).equalTo(refer('UserType', _logs).property('guest')).code,
          Code(') {'),
          _response(
            refer('HttpStatus', _dartIo).property('forbidden'),
            literalMap({
              'error': literalMap({
                'message': literalString(
                  route.requiresSuperUserAuth
                      ? 'Admin privileges required.'
                      : 'Authentication required.',
                ),
              }),
            }),
          ).returned.statement,
          Code('}'),
        ],
        if (route.bodyParams.isNotEmpty) ...[
          if ({
            HttpMethod.post,
            HttpMethod.put,
            HttpMethod.patch,
          }.contains(route.method))
            Code('final body = await request.toMap();')
          else
            Code('''
            final body = request.url.queryParameters.map(
            (k, v) => MapEntry(k, stringToDartType(v)),
            );
            '''),

          for (final bodyParam in route.bodyParams) ...[
            declareFinal(
              bodyParam.name!,
            ).assign(parseParam(bodyParam)).statement,
          ],
        ],
        if ([
          'void',
          'FutureOr<void>',
          'Future<void>',
        ].contains(returnType)) ...[
          refer(route.functionName, route.import)
              .call([
                refer('request'),
                ...route.pathParams.map(
                  (p) => refer('cleanParam').call([refer(p)]),
                ),
                ...route.bodyParams.map((p) => refer(p.name!)),
              ])
              .awaited
              .statement,
          _response(
            refer('HttpStatus', _dartIo).property('ok'),
          ).returned.statement,
        ] else if (returnType == 'FutureOr<Response>') ...[
          refer(route.functionName, route.import)
              .call([
                refer('request'),
                ...route.pathParams.map(
                  (p) => refer('cleanParam').call([refer(p)]),
                ),
                ...route.bodyParams.map((p) => refer(p.name!)),
              ])
              .awaited
              .returned
              .statement,
        ] else if (returnType == 'FutureOr<FileResponse>') ...[
          declareFinal('result')
              .assign(
                refer(route.functionName, route.import).call([
                  refer('request'),
                  ...route.pathParams.map(
                    (p) => refer('cleanParam').call([refer(p)]),
                  ),
                  ...route.bodyParams.map((p) => refer(p.name!)),
                ]).awaited,
              )
              .statement,
          refer('Response', _shelf)
              .call(
                [refer('HttpStatus', _dartIo).property('ok')],
                {
                  'body': refer('result').property('stream'),
                  'headers': literalMap({
                    refer('HttpHeaders', _dartIo).property('contentTypeHeader'):
                        refer('result').property('mimeType'),
                    refer(
                      'HttpHeaders',
                      _dartIo,
                    ).property('contentLengthHeader'): refer(
                      'result',
                    ).property('size').property('toString').call([]),
                    refer(
                      'HttpHeaders',
                      _dartIo,
                    ).property('contentDisposition'): literalString(
                      r'attachment; filename="${result.fileName}"',
                    ),
                  }),
                },
              )
              .returned
              .statement,
        ] else ...[
          if (isSseRoute) ...[
            declareFinal('sessionId')
                .assign(refer('Uuid', _uuid).constInstance([]))
                .property('v7')
                .call([])
                .statement,
            declareFinal('result')
                .assign(
                  refer(route.functionName, route.import).call([
                    refer('request'),
                    refer('sessionId'),
                    ...route.pathParams.map(
                      (p) => refer('cleanParam').call([refer(p)]),
                    ),
                    ...route.bodyParams.map((p) => refer(p.name!)),
                  ]),
                )
                .statement,
            refer('sseHandler', _sseHandler)
                .call([refer('request'), refer('sessionId'), refer('result')])
                .returned
                .statement,
          ] else ...[
            declareFinal('result')
                .assign(
                  refer(route.functionName, route.import).call([
                    refer('request'),
                    ...route.pathParams.map(
                      (p) => refer('cleanParam').call([refer(p)]),
                    ),
                    ...route.bodyParams.map((p) => refer(p.name!)),
                  ]).awaited,
                )
                .statement,
            if (returnType == 'FutureOr<String>')
              refer('Response', _shelf)
                  .call(
                    [refer('HttpStatus', _dartIo).property('ok')],
                    {
                      'body': refer('result'),
                      'encoding': refer(
                        'Encoding',
                        _dartConvert,
                      ).property('getByName').call([literalString('utf-8')]),
                      'headers': literalMap({
                        refer(
                          'HttpHeaders',
                          _dartIo,
                        ).property('contentTypeHeader'): literalString(
                          'application/json',
                        ),
                      }),
                    },
                  )
                  .returned
                  .statement
            else
              _response(
                refer('HttpStatus', _dartIo).property('ok'),
                refer('result'),
              ).returned.statement,
          ],
        ],
      ]);
    });
  }

  Expression _response(Expression statusCode, [Expression? body]) {
    return refer('Response', _shelf).call(
      [statusCode],
      {
        if (body != null)
          'body': refer('jsonEncode', _dartConvert).call([body]),
        'encoding': refer(
          'Encoding',
          _dartConvert,
        ).property('getByName').call([literalString('utf-8')]),
        'headers': literalMap({
          refer('HttpHeaders', _dartIo).property('contentTypeHeader'):
              literalString('application/json'),
        }),
      },
    );
  }

  Expression parseParam(FormalParameterElement param) {
    return switch (param.type) {
      DartType type when type.getDisplayString() == 'DateTime' =>
        refer('DateTime').property('fromMillisecondsSinceEpoch').call([
          refer('body').index(literalString(param.name!)).asA(refer('int')),
        ]),
      DartType type
          when type is InterfaceType &&
              type.allSupertypes.any((e) => e.isDartCoreEnum) =>
        refer(
          type.getDisplayString(),
        ).property('values').property('byName').call([
          refer('body').index(literalString(param.name!)).asA(refer('String')),
        ]),
      DartType type when type.isDartCoreList => () {
        final typeNonNullable = type.getDisplayString().replaceAll('?', '');
        final internalType = (type as InterfaceType).typeArguments.first;
        var list = refer(
          'body',
        ).index(literalString(param.name!)).asA(refer('List'));

        if (internalType is InterfaceType &&
            internalType.allSupertypes.any(
              (e) => e.getDisplayString().contains('Mappable'),
            )) {
          list = list.property('map').call([
            CodeExpression(
              Code(
                '(e) => ${internalType.getDisplayString()}Mapper.fromJson(e)',
              ),
            ),
          ]);
        }

        if (type.nullabilitySuffix == NullabilitySuffix.question) {
          return refer('body')
              .index(literalString(param.name!))
              .asA(refer('List?'))
              .equalTo(literalNull)
              .conditional(
                literalNull,
                refer(typeNonNullable).property('from').call([list]),
              );
        }
        return refer(typeNonNullable).property('from').call([list]);
      }(),
      DartType type
          when type is InterfaceType &&
              type.allSupertypes.any(
                (e) => e.getDisplayString().contains('Mappable'),
              ) =>
        () {
          final typeNonNullable = type.getDisplayString().replaceAll('?', '');
          if (type.nullabilitySuffix == NullabilitySuffix.question) {
            return refer('body')
                .index(literalString(param.name!))
                .asA(refer('Map<String, dynamic>?'))
                .equalTo(literalNull)
                .conditional(
                  literalNull,
                  refer('${typeNonNullable}Mapper').property('fromJson').call([
                    refer('body')
                        .index(literalString(param.name!))
                        .asA(refer('Map<String, dynamic>')),
                  ]),
                );
          }

          return refer('${typeNonNullable}Mapper').property('fromJson').call([
            refer('body')
                .index(literalString(param.name!))
                .asA(refer('Map<String, dynamic>')),
          ]);
        }(),
      _ =>
        refer('body')
            .index(literalString(param.name!))
            .asA(refer(param.type.getDisplayString())),
    };
  }

  String _buildRoutesInfo(List<RouteDetail> routes) {
    final buffer = StringBuffer();
    buffer.writeln('// GENERATED CODE - DO NOT MODIFY BY HAND');
    buffer.writeln('');
    buffer.writeln('const routesInfo = <Map<String, Object?>>[');

    for (final route in routes) {
      // Extract the inner return type (unwrap Future/FutureOr/Stream)
      final rawReturnType = route.returnType;
      DartType innerType = rawReturnType;
      bool isStream = rawReturnType.isDartAsyncStream;

      if (rawReturnType is InterfaceType &&
          (rawReturnType.isDartAsyncFutureOr ||
              rawReturnType.isDartAsyncFuture ||
              rawReturnType.isDartAsyncStream)) {
        innerType = rawReturnType.typeArguments.first;
      }

      final innerTypeName = innerType.getDisplayString();
      final isList = innerType.isDartCoreList;
      final isBool = innerType.isDartCoreBool;
      final isString = innerType.isDartCoreString;
      final isNum = innerType.isDartCoreNum;
      final isMap = innerType.isDartCoreMap;
      final isVoid = innerTypeName == 'void';
      final isFileResponse = innerTypeName == 'FileResponse';

      String? listItemTypeName;
      if (isList && innerType is InterfaceType) {
        listItemTypeName = innerType.typeArguments.first.getDisplayString();
      }

      buffer.writeln('  {');
      buffer.writeln("    'functionName': '${route.functionName}',");
      buffer.writeln("    'method': '${route.method.name}',");
      buffer.writeln("    'path': '${route.path}',");
      buffer.writeln(
        "    'pathParams': <String>[${route.pathParams.map((p) => "'$p'").join(', ')}],",
      );

      // Body params
      buffer.writeln("    'bodyParams': <Map<String, Object?>>[");
      for (final param in route.bodyParams) {
        final paramType = param.type;
        final typeName = paramType.getDisplayString();
        final isOptional = param.isOptional;
        final isNullable =
            paramType.nullabilitySuffix == NullabilitySuffix.question;
        final isEnum = paramType is InterfaceType &&
            paramType.allSupertypes.any((e) => e.isDartCoreEnum);
        final isDateTime = typeName == 'DateTime';
        final isMappable = paramType is InterfaceType &&
            paramType.allSupertypes.any(
              (e) => e.getDisplayString().contains('Mappable'),
            );
        final isListParam = paramType.isDartCoreList;
        String? listItemType;
        bool listItemIsMappable = false;
        if (isListParam && paramType is InterfaceType) {
          final itemType = paramType.typeArguments.first;
          listItemType = itemType.getDisplayString();
          listItemIsMappable = itemType is InterfaceType &&
              itemType.allSupertypes.any(
                (e) => e.getDisplayString().contains('Mappable'),
              );
        }

        final defaultValue = param.defaultValueCode;

        buffer.writeln('      {');
        buffer.writeln("        'name': '${param.name}',");
        buffer.writeln("        'typeName': '$typeName',");
        buffer.writeln("        'isOptional': $isOptional,");
        buffer.writeln("        'isNullable': $isNullable,");
        buffer.writeln(
          "        'defaultValue': ${defaultValue == null ? 'null' : "'$defaultValue'"},",
        );
        buffer.writeln("        'isEnum': $isEnum,");
        buffer.writeln("        'isDateTime': $isDateTime,");
        buffer.writeln("        'isMappable': $isMappable,");
        buffer.writeln("        'isList': $isListParam,");
        buffer.writeln(
          "        'listItemTypeName': ${listItemType == null ? 'null' : "'$listItemType'"},",
        );
        buffer.writeln(
          "        'listItemIsMappable': $listItemIsMappable,",
        );
        buffer.writeln('      },');
      }
      buffer.writeln('    ],');

      buffer.writeln("    'returnTypeName': '$innerTypeName',");
      buffer.writeln("    'returnTypeFlags': <String, Object?>{");
      buffer.writeln("      'isStream': $isStream,");
      buffer.writeln("      'isList': $isList,");
      buffer.writeln("      'isBool': $isBool,");
      buffer.writeln("      'isString': $isString,");
      buffer.writeln("      'isNum': $isNum,");
      buffer.writeln("      'isMap': $isMap,");
      buffer.writeln("      'isVoid': $isVoid,");
      buffer.writeln("      'isFileResponse': $isFileResponse,");
      buffer.writeln(
        "      'listItemTypeName': ${listItemTypeName == null ? 'null' : "'$listItemTypeName'"},",
      );
      buffer.writeln("      'innerTypeName': '$innerTypeName',");
      buffer.writeln('    },');

      buffer.writeln("    'ignoreForClient': ${route.ignoreForClient},");
      buffer.writeln("    'requiresAuth': ${route.requiresAuth},");
      buffer.writeln(
        "    'requiresSuperUserAuth': ${route.requiresSuperUserAuth},",
      );
      buffer.writeln('  },');
    }

    buffer.writeln('];');
    return buffer.toString();
  }

  Method _buildRegisterRoutesFunction(List<RouteDetail> routes) {
    return Method((m) {
      m.name = 'registerRoutes';
      m.returns = refer('void');
      m.requiredParameters.addAll([
        Parameter(
          (p) => p
            ..name = 'router'
            ..type = refer('Router', _shelfRouter),
        ),
      ]);

      final code = StringBuffer();
      for (final (index, route) in routes.indexed) {
        code.writeln(
          "router.${route.method.name.toLowerCase()}('${route.path}',",
        );
        if (route.pathParams.isNotEmpty) {
          code.writeln(
            "(request, ${route.pathParams.join(', ')}) => catchError(() async => ${route.functionName}${index}Route(request, ${route.pathParams.join(', ')})));",
          );
        } else {
          code.writeln(
            "(request) => catchError(() async => ${route.functionName}${index}Route(request)));",
          );
        }
      }

      m.body = Code(code.toString());
    });
  }
}
