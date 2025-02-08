import 'package:json_annotation/json_annotation.dart';

part 'barrel_export.g.dart';

/// Represents an `export` directive within a Dart barrel file.
@JsonSerializable()
class BarrelExport {
  /// Creates a [BarrelExport] with the given [library], [show], [hide] and
  /// [tags].
  const BarrelExport({
    required this.library,
    this.show = const {},
    this.hide = const {},
    this.tags = const {},
  });

  /// Creates a [BarrelExport] from a JSON (or YAML) map.
  factory BarrelExport.fromJson(Map json) => _$BarrelExportFromJson(json);

  /// The URI of the library being exported.
  ///
  /// Must be a valid `export` directive URI.
  final String library;

  /// The set of element names in the `show` statement of the `export`.
  ///
  /// If empty, no `show` filter is applied.
  final Set<String> show;

  /// The set of element names in the `hide` statement of the `export`.
  ///
  /// If empty, no `hide` filter is applied.
  final Set<String> hide;

  /// The set of tags for selectively including this export in barrel files.
  ///
  /// If empty, this export is included in all barrel files.
  final Set<String> tags;

  /// Merges this [BarrelExport] with [other] by combining their `show` and
  /// `hide` filters.
  BarrelExport merge(BarrelExport other) {
    if (library != other.library) {
      throw ArgumentError(
        'Cannot merge exports of different libraries: $library and ${other.library}',
      );
    }
    return BarrelExport(
      library: library,
      show: show.union(other.show),
      hide: hide.union(other.hide),
      tags: tags,
    );
  }

  /// Converts this [BarrelExport] to a JSON map.
  Map<String, dynamic> toJson() => _$BarrelExportToJson(this);
}
