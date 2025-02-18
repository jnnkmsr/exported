import 'package:exported/src/model/export.dart';
import 'package:exported/src/model/export_uri.dart';
import 'package:exported/src/model/tag.dart';

class ExportCache {
  ExportCache([Iterable<Export>? exports]) {
    _exports = {};
    if (exports == null) return;
    for (final export in exports) {
      add(export);
    }
  }

  ExportCache.fromJson(Map json)
      : _exports = json.cast<String, List>().map((tag, exportsJson) {
          final exports = exportsJson.cast<Map>().map(Export.fromJson);
          return MapEntry(
            Tag(tag),
            {for (final export in exports) export.uri: export},
          );
        });

  late final Map<Tag, Map<ExportUri, Export>> _exports;

  void add(Export export) {
    _exports.putIfAbsent(export.tag, Map.new).update(
          export.uri,
          export.merge,
          ifAbsent: () => export,
        );
  }

  Map toJson() => _exports.map(
        (tag, exportsByUri) => MapEntry(
          tag as String,
          exportsByUri.values.map((export) => export.toJson()).toList(),
        ),
      );
}

// Set<Export> operator [](Tags tags) {
//   var exports = const <ExportUri, Export>{};
//   for (final tag in tags) {
//     exports = mergeMaps(
//       exports,
//       _exports[tag] ?? const {},
//       value: (a, b) => a.merge(b),
//     );
//   }
//   return Set.of(exports.values);
// }
