import 'package:collection/collection.dart';
import 'package:exported/src/model/export.dart';
import 'package:exported/src/model/export_uri.dart';
import 'package:exported/src/model/reader.dart';
import 'package:exported/src/model/tag.dart';

abstract interface class ExportCache {
  factory ExportCache() = _ExportCache.new;

  factory ExportCache.fromCache(Map json) = _ExportCache.fromCache;

  void add(Export export);

  Set<Export> operator [](Tags tags);

  Map<String, dynamic> toJson();
}

final class _ExportCache implements ExportCache {
  _ExportCache({
    Map<Tag, Map<ExportUri, Export>>? exports,
  }) : _exports = exports ?? {};

  factory _ExportCache.fromCache(
    Map json, {
    CacheReader<Export> exportParser = Export.fromCache,
  }) =>
      _ExportCache(
        exports: json.map((tag, exportListJson) {
          final exports = (exportListJson as List).cast<Map>().map(exportParser);
          return MapEntry(
            Tag(tag as String),
            {for (final export in exports) export.uri: export},
          );
        }),
      );

  final Map<Tag, Map<ExportUri, Export>> _exports;

  @override
  void add(Export export) {
    final exportsByTag = export.splitByTag();
    for (final MapEntry(key: tag, value: export) in exportsByTag.entries) {
      _exports.putIfAbsent(tag, Map.new).update(export.uri, export.merge, ifAbsent: () => export);
    }
  }

  @override
  Set<Export> operator [](Tags tags) {
    var exports = const <ExportUri, Export>{};
    for (final tag in tags) {
      exports = mergeMaps(
        exports,
        _exports[tag] ?? const {},
        value: (a, b) => a.merge(b),
      );
    }
    return Set.of(exports.values);
  }

  @override
  Map<String, dynamic> toJson() => _exports.map(
        (tag, exportsByUri) => MapEntry(
          tag as String,
          exportsByUri.values.map((export) => export.toCache()).toList(),
        ),
      );
}
