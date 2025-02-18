import 'package:collection/collection.dart';
import 'package:exported/src/model/export.dart';
import 'package:exported/src/model/export_uri.dart';
import 'package:exported/src/model/tag.dart';

class ExportCache {
  ExportCache({
    Map<Tag, Map<ExportUri, Export>>? exports,
  }) : _exports = exports ?? {};

  factory ExportCache.fromCache(Map json) => ExportCache(
        exports: json.cast<String, List>().map((tag, exportsJson) {
          final exports = exportsJson.cast<Map>().map(Export.fromCache);
          return MapEntry(
            Tag(tag),
            {for (final export in exports) export.uri: export},
          );
        }),
      );

  final Map<Tag, Map<ExportUri, Export>> _exports;

  void add(Export export) {
    final exportsByTag = export.splitByTag();

    for (final MapEntry(key: tag, value: export) in exportsByTag.entries) {
      _exports.putIfAbsent(tag, Map.new).update(
            export.uri,
            export.merge,
            ifAbsent: () => export,
          );
    }
  }

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

  Map<String, dynamic> toJson() => _exports.map(
        (tag, exportsByUri) => MapEntry(
          tag as String,
          exportsByUri.values.map((export) => export.toCache()).toList(),
        ),
      );
}
