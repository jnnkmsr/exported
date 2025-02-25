import 'package:exported/src/model/export.dart';
import 'package:exported/src/model/export_uri.dart';
import 'package:exported/src/model/tag.dart';

// TODO[ExportCache]: Documentation

class ExportCache {
  ExportCache() : _exports = {};

  ExportCache.fromJson(Map json) {
    final exports = json.cast<String, List>().map((tag, exportsJson) {
      final exports = exportsJson.cast<Map>().map(Export.fromJson);
      return MapEntry(
        Tag.fromJson(tag),
        {for (final export in exports) export.uri: export},
      );
    });
    _exports = exports;
  }

  late final Map<Tag, Map<ExportUri, Export>> _exports;

  Iterable<Export> operator [](Tags tags) {
    final exports = <ExportUri, Export>{};
    for (final tag in tags.matching(_exports.keys)) {
      exports.merge(_exports[tag]);
    }
    return exports.values;
  }

  void add(Export export, Tags tags) {
    for (final tag in tags) {
      _exports.putIfAbsent(tag, () => {}).add(export);
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
