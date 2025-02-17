import 'dart:convert';

import 'package:analyzer/dart/element/element.dart';
import 'package:build/build.dart';
import 'package:exported/src/model/export.dart';
import 'package:exported/src/model/export_cache.dart';
import 'package:exported_annotation/exported_annotation.dart';
import 'package:source_gen/source_gen.dart';

/// Callback for reading an [Export] from an [annotatedElement], annotated with
/// [Exported] within a library at [uri].
typedef ExportAnnotationReader = Export Function(
  Uri uri,
  AnnotatedElement annotatedElement,
);

class ExportedCacheBuilder implements Builder {
  ExportedCacheBuilder({
    ExportCache? cache,
    ExportAnnotationReader annotationReader = Export.fromAnnotatedElement,
  })  : _cache = cache ?? ExportCache(),
        _annotationReader = annotationReader;

  static const jsonExtension = '.exported.json';

  @override
  final Map<String, List<String>> buildExtensions = const {
    '.dart': [jsonExtension],
  };

  final ExportCache _cache;
  final ExportAnnotationReader _annotationReader;

  void _readExports(Uri uri, LibraryElement library) {
    LibraryReader(library)
        .annotatedWith(const TypeChecker.fromRuntime(Exported))
        .map((annotatedElement) => _annotationReader(uri, annotatedElement))
        .forEach(_cache.add);
  }

  Future<void> _writeJson(BuildStep buildStep, AssetId outputId) =>
      buildStep.writeAsString(outputId, jsonEncode(_cache.toJson()));

  @override
  Future<void> build(BuildStep buildStep) async {
    final inputId = buildStep.inputId;
    final resolver = buildStep.resolver;
    if (!await resolver.isLibrary(inputId)) return;

    _readExports(inputId.uri, await resolver.libraryFor(inputId));

    await _writeJson(buildStep, inputId.changeExtension(jsonExtension));
  }
}
