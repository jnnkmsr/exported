import 'dart:convert';

import 'package:analyzer/dart/element/element.dart';
import 'package:build/build.dart';
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

  Export _readExportFromAnnotation(Uri uri, AnnotatedElement annotatedElement) {
    final elementName = annotatedElement.element.name!;
    final tags =
        annotatedElement.annotation.read(keys.tags).setValue.map((e) => e.toStringValue()!);
    return Export.fromAnnotation(uri.toString(), elementName, tags);
  }

  ExportCache _readExportsFromLibrary(Uri uri, LibraryElement library) {
    final cache = ExportCache();
    LibraryReader(library)
        .annotatedWith(const TypeChecker.fromRuntime(Exported))
        .map((annotatedElement) => _readExportFromAnnotation(uri, annotatedElement))
        .forEach(cache.add);
    return cache;
  }

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
    await _writeJsonForLibrary(buildStep, inputId, exports);
  }
}
