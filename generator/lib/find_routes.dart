import 'package:analyzer/dart/element/element.dart';
import 'package:analyzer/dart/element/type.dart';
import 'package:build/build.dart';
import 'package:glob/glob.dart';
import 'package:source_gen/source_gen.dart';

import 'package:vanestack_annotation/vanestack_annotation.dart';

/// Represents the details of a server route extracted from annotated functions.
typedef RouteDetail = ({
  String functionName,
  String import,
  HttpMethod method,
  List<FormalParameterElement> bodyParams,
  Set<String> pathParams,
  String path,
  bool ignoreForClient,
  DartType returnType,
  bool requiresAuth,
  bool requiresSuperUserAuth,
});

/// Scans the source code for functions annotated with @Route and extracts route details.
Future<List<RouteDetail>> findRoutes(BuildStep buildStep) async {
  final dartFiles = Glob('lib/**.dart');
  final routes = <RouteDetail>[];

  await for (final input in buildStep.findAssets(dartFiles)) {
    // Resolve library for each file
    if (!await buildStep.resolver.isLibrary(input)) continue;

    final library = await buildStep.resolver.libraryFor(input);
    final reader = LibraryReader(library);

    // Check for @Route annotations
    for (var annotatedElement in reader.annotatedWith(
      TypeChecker.typeNamed(Route),
    )) {
      final element = annotatedElement.element;
      final annotation = annotatedElement.annotation;

      final methodField = annotation.read('method');
      final enumValue = methodField.objectValue;
      final method = enumValue.getField('_name')?.toStringValue() ?? 'get';

      if (element is TopLevelFunctionElement) {
        final functionName = element.name ?? 'unknownFunction';
        final import = element.library.uri.toString();
        final params = element.formalParameters
            .where((e) => e.name != 'request' && e.name != 'sessionId')
            .toList();

        final path = annotation.read('path').stringValue;

        final pathParams = RegExp(
          r'<(\w+)>',
        ).allMatches(path).map((m) => m.group(1)).whereType<String>().toSet();

        final bodyParams = params
            .where((p) => !pathParams.contains(p.name))
            .toList();

        routes.add((
          path: path,
          method: HttpMethod.values.byName(method),
          functionName: functionName,
          import: import,
          bodyParams: bodyParams,
          pathParams: pathParams,
          returnType: element.returnType,
          ignoreForClient: annotation.read('ignoreForClient').boolValue,
          requiresAuth: annotation.read('requireAuth').boolValue,
          requiresSuperUserAuth: annotation
              .read('requireSuperUserAuth')
              .boolValue,
        ));
      }
    }
  }
  return routes;
}
