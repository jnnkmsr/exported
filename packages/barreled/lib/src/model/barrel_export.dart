import 'package:analyzer/dart/constant/value.dart';
import 'package:analyzer/dart/element/element.dart';
import 'package:barreled/src/options/package_export_option.dart';
import 'package:barreled_annotation/barreled_annotation.dart';
import 'package:build/build.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:meta/meta.dart';
import 'package:source_gen/source_gen.dart';

part 'barrel_export.g.dart';

// TODO: Unit test `BarrelExport.fromAnnotatedElement`.
// TODO: Unit test `BarrelExport.fromPackageExportOption`.
// TODO: Unit test `BarrelExport.compareTo()`.

/// Represents an `export` directive within a Dart barrel file.
@JsonSerializable()
@immutable
class BarrelExport implements Comparable<BarrelExport> {
  /// Creates a [BarrelExport] with the given [uri], [show], [hide] and
  /// [tags].
  const BarrelExport({
    required this.uri,
    this.show = const {},
    this.hide = const {},
    this.tags = const {},
  });

  /// Creates a [BarrelExport] from an annotated [element] with
  /// - the [uri] given by the URI of the current [buildStep]'s input,
  /// - the [show] filter containing the [element]'s name, and
  /// - [tags] read from the [Barreled.tags] annotation input.
  ///
  /// Throws an [InvalidGenerationSourceError] if the annotated [element] is
  /// an invalidly annotated unnamed element.
  factory BarrelExport.fromAnnotatedElement(
    Element element,
    ConstantReader annotation,
    BuildStep buildStep,
  ) {
    final shownName = element.name;
    if (shownName == null || shownName.isEmpty) {
      throw InvalidGenerationSourceError(
        '`@$barreled` is used on an unnamed element',
        element: element,
      );
    }
    final tagReader = annotation.read('tags');

    return BarrelExport(
      uri: buildStep.inputId.uri.toString(),
      show: {shownName},
      tags: (tagReader.isSet ? tagReader.setValue : <DartObject>{})
          .map((tag) => tag.toStringValue()!)
          .toSet(),
    );
  }

  /// Creates a [BarrelExport] from a [PackageExportOption].
  factory BarrelExport.fromPackageExportOption(PackageExportOption option) {
    return BarrelExport(
      uri: option.package,
      show: option.show,
      hide: option.hide,
      tags: option.tags,
    );
  }

  /// Creates a [BarrelExport] from a JSON (or YAML) map.
  factory BarrelExport.fromJson(Map json) => _$BarrelExportFromJson(json);

  /// The URI of the library being exported.
  ///
  /// Must be a valid `export` directive URI.
  @JsonKey(name: uriKey)
  final String uri;
  static const uriKey = 'library';

  /// The set of element names in the `show` statement of the `export`.
  ///
  /// If empty, no `show` filter is applied.
  @JsonKey(name: showKey)
  final Set<String> show;
  static const showKey = 'show';

  /// The set of element names in the `hide` statement of the `export`.
  ///
  /// If empty, no `hide` filter is applied.
  @JsonKey(name: hideKey)
  final Set<String> hide;
  static const hideKey = 'hide';

  /// The set of tags for selectively including this export in barrel files.
  ///
  /// If empty, this export is included in all barrel files.
  @JsonKey(name: tagsKey)
  final Set<String> tags;
  static const tagsKey = 'tags';

  /// Merges this [BarrelExport] with [other] by combining their `show` and
  /// `hide` filters.
  BarrelExport merge(BarrelExport other) {
    if (uri != other.uri) {
      throw ArgumentError(
        'Cannot merge exports of different libraries: $uri and ${other.uri}',
      );
    }
    return BarrelExport(
      uri: uri,
      show: show.union(other.show),
      hide: hide.union(other.hide),
      tags: tags,
    );
  }

  /// Converts this [BarrelExport] to a JSON map.
  Map<String, dynamic> toJson() => _$BarrelExportToJson(this);

  @override
  int compareTo(BarrelExport other) => uri.compareTo(other.uri);
}
