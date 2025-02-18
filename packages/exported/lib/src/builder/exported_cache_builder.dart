import 'dart:convert';

import 'package:analyzer/dart/element/element.dart';
import 'package:build/build.dart';
import 'package:collection/collection.dart';
import 'package:exported/src/builder/exported_option_keys.dart' as keys;
import 'package:exported/src/model/export.dart';
import 'package:exported/src/model/export_cache.dart';
import 'package:exported_annotation/exported_annotation.dart';
import 'package:source_gen/source_gen.dart';

class ExportedCacheBuilder implements Builder {
  static const jsonExtension = '.exported.json';

  @override
  final Map<String, List<String>> buildExtensions = const {
    '.dart': [jsonExtension],
  };

  // TODO[ExportedCacheBuilder]: Validate element is named/exclude directives
  Iterable<Export> _readExportFromAnnotation(Uri uri, AnnotatedElement annotatedElement) {
    final tagsReader = annotatedElement.annotation.read(keys.tags);
    return Export.fromAnnotation(
      uri: uri.toString(),
      element: annotatedElement.element.name!,
      tags: tagsReader.isSet
          ? tagsReader.setValue.map((e) => e.toStringValue()!).toList()
          : const <String>[],
    );
  }

  Iterable<Export> _readExportsFromLibrary(Uri uri, LibraryElement library) =>
      LibraryReader(library)
          .annotatedWith(const TypeChecker.fromRuntime(Exported))
          .map((annotatedElement) => _readExportFromAnnotation(uri, annotatedElement))
          .flattened;

  Future<void> _writeJsonForLibrary(BuildStep buildStep, AssetId inputId, ExportCache cache) {
    final outputId = inputId.changeExtension(jsonExtension);
    final json = jsonEncode(cache.toJson());
    return buildStep.writeAsString(outputId, json);
  }

  @override
  Future<void> build(BuildStep buildStep) async {
    final inputId = buildStep.inputId;
    final resolver = buildStep.resolver;
    if (!await resolver.isLibrary(inputId)) return;

    final exports = _readExportsFromLibrary(inputId.uri, await resolver.libraryFor(inputId));
    if (exports.isEmpty) return;

    await _writeJsonForLibrary(buildStep, inputId, ExportCache(exports));
  }
}
