import 'dart:convert';

import 'package:analyzer/dart/element/element.dart';
import 'package:build/build.dart';
import 'package:exported/src/builder/export_cache.dart';
import 'package:exported/src/model/export.dart';
import 'package:exported/src/model/exported_option_keys.dart' as keys;
import 'package:exported_annotation/exported_annotation.dart';
import 'package:source_gen/source_gen.dart';

/// Collects elements annotated with [Exported] and stores them as JSON into
/// the build cache.
final class ExportCacheBuilder extends LibraryBuilder {
  ExportCacheBuilder()
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

/// [Generator] for [ExportCacheBuilder], converting annotated elements into JSON.
///
/// The JSON is a representation of [ExportCache], sorting and grouping exports
/// by tag and URI.
final class _CacheGenerator extends Generator {
  static const _exportedTypeChecker = TypeChecker.fromRuntime(Exported);

  @override
  String? generate(LibraryReader library, BuildStep buildStep) {
    final annotatedElements = library.annotatedWith(_exportedTypeChecker);
    return annotatedElements.isNotEmpty
        ? jsonEncode(_buildCache(library, annotatedElements).toJson())
        : null;
  }

  ExportCache _buildCache(LibraryReader library, Iterable<AnnotatedElement> annotatedElements) {
    final uri = library.element.source.uri.toString();
    return ExportCache(annotatedElements.map((e) => _readExport(uri, e)));
  }

  Export _readExport(String uri, AnnotatedElement annotatedElement) {
    final element = annotatedElement.element;
    if (element.kind case ElementKind.IMPORT || ElementKind.EXPORT || ElementKind.PART) {
      throw InvalidGenerationSourceError(
        'Invalid annotation on ${element.kind.displayName}',
        element: element,
      );
    }
    return element is LibraryElement
        ? _readLibraryExport(uri, element, annotatedElement.annotation)
        : _readNamedExport(uri, element, annotatedElement.annotation);
  }

  Export _readLibraryExport(
    String uri,
    LibraryElement element,
    ConstantReader annotation,
  ) =>
      Export.library(
        uri: element.identifier,
        show: annotation.readSetOrNull(keys.show),
        hide: annotation.readSetOrNull(keys.hide),
        tags: annotation.readSetOrNull(keys.tags),
      );

  Export _readNamedExport(
    String uri,
    Element element,
    ConstantReader annotation,
  ) {
    if (element.name case final name?) {
      return Export.element(
        uri: uri,
        name: name,
        tags: annotation.readSetOrNull(keys.tags),
      );
    } else {
      throw InvalidGenerationSourceError(
        'Invalid annotation on unnamed element',
        element: element,
      );
    }
  }
}

extension on ConstantReader {
  Set<String>? readSetOrNull(String key) {
    final reader = read(key);
    return reader.isNull ? null : reader.setValue.map((e) => e.toStringValue()!).toSet();
  }
}
