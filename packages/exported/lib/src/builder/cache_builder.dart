import 'dart:convert';

import 'package:analyzer/dart/element/element.dart';
import 'package:build/build.dart';
import 'package:collection/collection.dart';
import 'package:exported/src/builder/exported_option_keys.dart' as keys;
import 'package:exported/src/model/export.dart';
import 'package:exported/src/model/export_cache.dart';
import 'package:exported_annotation/exported_annotation.dart';
import 'package:source_gen/source_gen.dart';

/// Collects elements annotated with [Exported] and stores them as JSON into
/// the build cache.
class CacheBuilder extends LibraryBuilder {
  CacheBuilder()
      : super(
          _CacheGenerator(),
          generatedExtension: jsonExtension,
          allowSyntaxErrors: true,
          formatOutput: (json, _) => json,
          header: '',
          writeDescriptions: false,
        );

  static const jsonExtension = '.exported.json';
}

/// [Generator] for [CacheBuilder], converting annotated elements into JSON.
///
/// The JSON is a representation of [ExportCache], sorting and grouping exports
/// by tag and URI.
class _CacheGenerator extends Generator {
  static const _exportedTypeChecker = TypeChecker.fromRuntime(Exported);

  Iterable<Export> _readExport(String uri, AnnotatedElement annotatedElement) {
    final element = annotatedElement.element;
    final tags = _readTags(annotatedElement.annotation);

    return switch (element.kind) {
      ElementKind.IMPORT || ElementKind.EXPORT => throw InvalidGenerationSourceError(
          'Library imports and exports cannot be exported',
          element: element,
        ),
      ElementKind.PART => throw InvalidGenerationSourceError(
          'Part files cannot be exported',
          element: element,
        ),
      _ when element is LibraryElement => Export.library(
          uri: element.identifier,
          tags: tags,
        ),
      _ when element.name == null => throw InvalidGenerationSourceError(
          'Unnamed elements cannot be exported',
          element: element,
        ),
      _ => Export.element(uri: uri, name: element.name!, tags: tags),
    };
  }

  Iterable<String> _readTags(ConstantReader annotation) {
    final tagsReader = annotation.read(keys.tags);
    return tagsReader.isSet ? tagsReader.setValue.map((e) => e.toStringValue()!) : const [];
  }

  @override
  String? generate(LibraryReader library, BuildStep buildStep) {
    final uri = library.element.source.uri.toString();
    final exports = library
        .annotatedWith(_exportedTypeChecker)
        .map((annotatedElement) => _readExport(uri, annotatedElement))
        .flattened;
    return exports.isEmpty ? null : jsonEncode(ExportCache(exports).toJson());
  }
}
