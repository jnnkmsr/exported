import 'package:collection/collection.dart';
import 'package:exported/src/builder/cache_builder.dart';
import 'package:exported/src/builder/exported_builder.dart';
import 'package:exported/src/model/barrel_file.dart';
import 'package:exported/src/model/export.dart';
import 'package:exported/src/model/export_uri.dart';
import 'package:exported/src/model/tag.dart';

/// Stores [Export] instances grouped by [Tag].
///
/// Created by [CacheBuilder] from annotated elements, and stored as JSON per
/// library in the build cache. Read by [ExportedBuilder] and merged with the
/// [Export]s from the builder options to create a combined package cache, from
/// which generated barrel files are filled with exports matching their tags.
class ExportCache {
  /// Creates an [ExportCache] containing the given [exports].
  ///
  /// Used by [CacheBuilder] to create a cache from annotated elements in a
  /// single library.
  ExportCache(Iterable<Export> exports) : _exportsByTag = {} {
    add(exports);
  }

  /// Creates a new [ExportCache] by merging multiple [caches].
  ///
  /// Used by [ExportedBuilder] to create a combined package cache from all
  /// library caches stored in the build cache.
  ExportCache.merged(Iterable<ExportCache> caches) : _exportsByTag = {} {
    caches.forEach(merge);
  }

  /// Restores an [ExportCache] from [json].
  ExportCache.fromJson(Map json) {
    final exports = json.cast<String, List>().map((tag, exportsJson) {
      final exports = exportsJson.cast<Map>().map(Export.fromJson);
      return MapEntry(tag.asTag, {for (final export in exports) export.uri: export});
    });
    _exportsByTag = exports;
  }

  /// Exports grouped by tag and URI.
  ///
  /// When [add]ing exports, they are split into single-tag groups and merged
  /// by URI, allowing to merge the correct export filter per barrel file.
  late final Map<Tag, Map<ExportUri, Export>> _exportsByTag;

  /// Returns all exports matching the tags of the given [file], merging and
  /// sorting by URI.
  Iterable<Export> matchingExports(BarrelFile file) {
    final exports = <ExportUri, Export>{};
    final matchingTags = file.tags == Tags.none
        ? _exportsByTag.keys
        : _exportsByTag.keys.where((tag) => file.tags.any(tag.matches));
    for (final tag in matchingTags) {
      exports.merge(_exportsByTag[tag]);
    }
    return exports.values.sorted();
  }

  /// Adds [exports] to the cache, grouping them by tag and merging by URI.
  void add(Iterable<Export> exports) {
    for (final export in exports) {
      for (final tag in export.tags) {
        _exportsByTag.putIfAbsent(tag, () => {}).add(export);
      }
    }
  }

  /// Merges [other] into this cache, merging exports by tag and URI.
  void merge(ExportCache other) => other._exportsByTag.forEach(
        (tag, exportsByUri) => _exportsByTag.putIfAbsent(tag, () => {}).merge(exportsByUri),
      );

  /// Converts this [ExportCache] to JSON for storage in the build cache.
  Map toJson() => _exportsByTag.map(
        (tag, exportsByUri) => MapEntry(
          tag,
          exportsByUri.values.map((export) => export.toJson()).toList(),
        ),
      );
}

extension on Map<ExportUri, Export> {
  /// Adds the given [export] to this map, merging if an export with the same
  /// URI already exists.
  void add(Export export) => update(export.uri, export.merge, ifAbsent: () => export);

  /// Merges all exports from [other] into this map by calling [add] to either
  /// add or merge by URI.
  void merge(Map<ExportUri, Export>? other) => other?.values.forEach(add);
}
