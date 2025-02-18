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
          CacheGenerator(),
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
class CacheGenerator extends Generator {
  static const _exportedTypeChecker = TypeChecker.fromRuntime(Exported);

  Iterable<Export> _readExports(LibraryReader library) {
    final uri = library.element.source.uri.toString();
    return library
        .annotatedWith(_exportedTypeChecker)
        .map(
          (annotatedElement) => Export.fromAnnotation(
            uri: uri,
            symbol: _readSymbol(annotatedElement.element),
            tags: _readTags(annotatedElement.annotation),
          ),
        )
        .flattened;
  }

  // TODO[ExportedCacheBuilder]: Validate element is named/exclude directives
  String _readSymbol(Element element) {
    return element.name!;
  }

  Iterable<String> _readTags(ConstantReader annotation) {
    final tagsReader = annotation.read(keys.tags);
    return tagsReader.isSet ? tagsReader.setValue.map((e) => e.toStringValue()!) : const [];
  }

  @override
  String? generate(LibraryReader library, BuildStep buildStep) {
    final exports = _readExports(library);
    return exports.isEmpty ? null : jsonEncode(ExportCache(exports).toJson());
  }
}
