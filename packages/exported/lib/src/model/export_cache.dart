import 'package:collection/collection.dart';
import 'package:exported/src/model/export.dart';
import 'package:exported/src/model/export_uri.dart';
import 'package:exported/src/model/tag.dart';

// TODO[ExportCache]: Documentation

class ExportCache {
  ExportCache(Iterable<Export> exports) : _exports = {} {
    add(exports);
  }

  ExportCache.merged(Iterable<ExportCache> caches) : _exports = {} {
    caches.forEach(merge);
  }

  ExportCache.fromJson(Map json) {
    final exports = json.cast<String, List>().map((tag, exportsJson) {
      final exports = exportsJson.cast<Map>().map(Export.fromJson);
      return MapEntry(tag, {for (final export in exports) export.uri: export});
    });
    _exports = exports;
  }

  late final Map<String, Map<ExportUri, Export>> _exports;
  Tags get _exportTags => _exports.keys.asTags;

  Iterable<Export> matching(Tags tags) {
    final exports = <ExportUri, Export>{};
    final exportTags = _exportTags;
    for (final tag in tags.matching(exportTags)) {
      exports.merge(_exports[tag]);
    }
    return exports.values.sorted();
  }

  void add(Iterable<Export> exports) {
    for (final export in exports) {
      for (final tag in export.tags) {
        _exports.putIfAbsent(tag, () => {}).add(export);
      }
    }
  }

  void merge(ExportCache other) => other._exports.forEach(
        (tag, exportsByUri) => _exports.putIfAbsent(tag, () => {}).merge(exportsByUri),
      );

  Map toJson() => _exports.map(
        (tag, exportsByUri) => MapEntry(
          tag,
          exportsByUri.values.map((export) => export.toJson()).toList(),
        ),
      );
}

extension on Map<ExportUri, Export> {
  void add(Export export) => update(export.uri, export.merge, ifAbsent: () => export);

  void merge(Map<ExportUri, Export>? other) => other?.values.forEach(add);
}
