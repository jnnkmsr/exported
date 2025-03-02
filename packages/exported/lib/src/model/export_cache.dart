import 'package:collection/collection.dart';
import 'package:exported/src/model/export.dart';
import 'package:exported/src/model/export_uri.dart';
import 'package:exported/src/model/tag.dart';

// TODO[ExportCache]: Documentation

class ExportCache {
  ExportCache(Iterable<Export> exports) : _exportsByTag = {} {
    add(exports);
  }

  ExportCache.merged(Iterable<ExportCache> caches) : _exportsByTag = {} {
    caches.forEach(merge);
  }

  ExportCache.fromJson(Map json) {
    final exports = json.cast<String, List>().map((tag, exportsJson) {
      final exports = exportsJson.cast<Map>().map(Export.fromJson);
      return MapEntry(tag.asTag, {for (final export in exports) export.uri: export});
    });
    _exportsByTag = exports;
  }

  late final Map<Tag, Map<ExportUri, Export>> _exportsByTag;

  Iterable<Export> matching(Tags tags) {
    final exports = <ExportUri, Export>{};
    final matchingTags = tags == Tags.none
        ? _exportsByTag.keys
        : tags.where(
            (tag) => _exportsByTag.keys.any(tag.matches),
          );
    for (final tag in matchingTags) {
      exports.merge(_exportsByTag[tag]);
    }
    return exports.values.sorted();
  }

  void add(Iterable<Export> exports) {
    for (final export in exports) {
      for (final tag in export.tags) {
        _exportsByTag.putIfAbsent(tag, () => {}).add(export);
      }
    }
  }

  void merge(ExportCache other) => other._exportsByTag.forEach(
        (tag, exportsByUri) => _exportsByTag.putIfAbsent(tag, () => {}).merge(exportsByUri),
      );

  Map toJson() => _exportsByTag.map(
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
