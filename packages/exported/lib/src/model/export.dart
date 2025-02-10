import 'package:analyzer/dart/constant/value.dart';
import 'package:analyzer/dart/element/element.dart';
import 'package:build/build.dart';
import 'package:exported/src/options/export_option.dart';
import 'package:exported_annotation/exported_annotation.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:meta/meta.dart';
import 'package:source_gen/source_gen.dart';

part 'export.g.dart';

// TODO: Unit test `Export.fromAnnotatedElement`.
// TODO: Unit test `Export.fromPackageExportOption`.
// TODO: Unit test `Export.compareTo()`.

/// Represents an `export` directive within a Dart barrel file.
@JsonSerializable()
@immutable
class Export implements Comparable<Export> {
  /// Creates a [Export] with the given [uri], [show], [hide] and
  /// [tags].
  const Export({
    required this.uri,
    this.show = const {},
    this.hide = const {},
    this.tags = const {},
  });

  /// Creates a [Export] from an annotated [element] with
  /// - the [uri] given by the URI of the current [buildStep]'s input,
  /// - the [show] filter containing the [element]'s name, and
  /// - [tags] read from the [Exported.tags] annotation input.
  ///
  /// Throws an [InvalidGenerationSourceError] if the annotated [element] is
  /// an invalidly annotated unnamed element.
  factory Export.fromAnnotatedElement(
    Element element,
    ConstantReader annotation,
    BuildStep buildStep,
  ) {
    final show = element.name;
    if (show == null || show.isEmpty) {
      throw InvalidGenerationSourceError(
        '`@$exported` is used on an unnamed element',
        element: element,
      );
    }
    final tagReader = annotation.read('tags');

    return Export(
      uri: buildStep.inputId.uri.toString(),
      show: {show},
      tags: (tagReader.isSet ? tagReader.setValue : <DartObject>{})
          .map((tag) => tag.toStringValue()!)
          .toSet(),
    );
  }

  /// Creates a [Export] from a [ExportOption].
  factory Export.fromPackageExportOption(ExportOption option) {
    return Export(
      uri: option.uri,
      show: option.show,
      hide: option.hide,
      tags: option.tags,
    );
  }

  /// Creates a [Export] from a JSON (or YAML) map.
  factory Export.fromJson(Map json) => _$ExportFromJson(json);

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

  /// Merges this [Export] with [other] by combining their `show` and
  /// `hide` filters.
  Export merge(Export other) {
    if (uri != other.uri) {
      throw ArgumentError(
        'Cannot merge exports of different libraries: $uri and ${other.uri}',
      );
    }
    return Export(
      uri: uri,
      show: show.union(other.show),
      hide: hide.union(other.hide),
      tags: tags,
    );
  }

  /// Converts this [Export] to a JSON map.
  Map<String, dynamic> toJson() => _$ExportToJson(this);

  @override
  int compareTo(Export other) => uri.compareTo(other.uri);
}
