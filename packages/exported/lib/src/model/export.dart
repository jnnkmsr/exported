import 'package:analyzer/dart/constant/value.dart';
import 'package:analyzer/dart/element/element.dart';
import 'package:build/build.dart';
import 'package:collection/collection.dart';
import 'package:exported/src/builder/exported_option_keys.dart' as keys;
import 'package:exported/src/util/equals_util.dart';
import 'package:exported/src/validation/show_hide_parser.dart';
import 'package:exported/src/validation/tags_parser.dart';
import 'package:exported/src/validation/uri_parser.dart';
import 'package:exported_annotation/exported_annotation.dart';
import 'package:meta/meta.dart';
import 'package:source_gen/source_gen.dart';

/// Represents a Dart `export` directive with a [uri] and an optional [show] or
/// [hide] filter.
///
/// The [tags] field is used to selectively include this export in barrel files.
///
/// [Export]s are collected both from elements annotated with `@exported` and
/// parsed from the `exports` section of the builder options.
@immutable
class Export implements Comparable<Export> {
  /// Internal constructor assigning sanitized values.
  @visibleForTesting
  const Export({
    required this.uri,
    this.show = const {},
    this.hide = const {},
    this.tags = const {},
  });

  /// Creates an [Export] from an [element] annotated with `@exported`, with:
  /// - the [uri] of the [library] containing the [element],
  /// - the [show] filter containing the [element]'s name, and
  /// - [tags] read from the [annotation] input.
  ///
  /// Sanitizes [tags]:
  /// - Trims whitespace and converts to lowercase.
  /// - Removes empty/blank tags and duplicates.
  ///
  /// Throws an [InvalidGenerationSourceError] if the [element] is an invalidly
  /// annotated (unnamed) element.
  factory Export.fromAnnotatedElement(
    AssetId library,
    Element element,
    ConstantReader annotation,
  ) {
    final show = element.name;
    if (show == null || show.isEmpty) {
      throw InvalidGenerationSourceError(
        '`@$exported` is used on an unnamed element',
        element: element,
      );
    }

    final tagReader = annotation.read(keys.tags);
    final tags = (tagReader.isSet ? tagReader.setValue : <DartObject>{})
        .map((tag) => tag.toStringValue()!)
        .toSet();

    return Export(
      uri: library.uri.toString(),
      show: {show},
      tags: tagsParser.parse(tags),
    );
  }

  /// Creates an [Export] from JSON/YAML input, validating and sanitizing
  /// inputs.
  ///
  /// **[uri]:**
  /// - Trims leading/trailing whitespace.
  /// - Normalizes the URI, ensuring a valid Dart `package:` URI:
  ///   - Normalizes the path, ensures snake-case, and adds a leading `package:`
  ///     prefix if missing.
  ///   - Ensures the file extension is `.dart` or adds it if missing.
  ///   - Converts a single package or library name to a URI of the form
  ///     `'package:$package/$package.dart'`.
  ///
  /// **[show]/[hide]:**
  /// - Trims whitespace and removes duplicate elements.
  /// - Ensures all elements are valid Dart identifiers.
  /// - Ensures only one of `show` or `hide` is present.
  ///
  /// **[tags]:**
  /// - Trims whitespace and converts to lowercase.
  /// - Removes empty/blank tags and duplicates.
  ///
  /// Throws an [ArgumentError] for invalid JSON input or inputs that cannot be
  /// sanitized.
  factory Export.fromJson(Map json) {
    final show = showParser.parseJson(json[keys.show]);
    final hide = hideParser.parseJson(json[keys.hide]);
    if (show.isNotEmpty && hide.isNotEmpty) {
      hideParser.throwArgumentError(keys.hide, 'Cannot have both `show` and `hide` filters');
    }
    return Export(
      uri: uriParser.parseJson(json[keys.uri]),
      show: show,
      hide: hide,
      tags: tagsParser.parseJson(json[keys.tags]),
    );
  }

  /// The URI of the `export` directive, sanitized to a Dart `package:` URI.
  final String uri;

  /// The element names in the `show` statement of the `export` directive.
  final Set<String> show;

  /// The element names in the `hide` statement of the `export` directive.
  final Set<String> hide;

  /// Tags for selectively including this export in barrel files.
  final Set<String> tags;

  /// Whether this export has any [show] or [hide] filters.
  bool get _hasFilters => show.isNotEmpty || hide.isNotEmpty;

  /// Parser for [uri] inputs.
  @visibleForTesting
  static UriParser uriParser = const UriParser(keys.uri);

  /// Parser for [show] inputs.
  @visibleForTesting
  static ShowHideParser showParser = const ShowHideParser(keys.show);

  /// Parser for [hide] inputs.
  @visibleForTesting
  static ShowHideParser hideParser = const ShowHideParser(keys.hide);

  /// Parser for [tags] inputs.
  @visibleForTesting
  static TagsParser tagsParser = const TagsParser(keys.tags);

  /// Merges this instance with [other], combining their [show] and [hide]
  /// filters if the [uri]s match.
  ///
  /// The resulting [Export] will contain the combined elements based on the
  /// [show] and [hide] filters from both instances:
  ///
  /// - If either instance has no filters (i.e., it exports everything), the
  ///   resulting [Export] will also have empty [show] and [hide] filters.
  /// - If both instances have [show] filters, the resulting [Export] will
  ///   include the union of the two [show] filters.
  /// - If both instances have [hide] filters, the resulting [Export] will only
  ///   hide the elements that are present in both [hide] filters.
  /// - If one instance has a [show] filter and the other has a [hide] filter,
  ///   the resulting [Export] will discard the [show] filter and retain the
  ///   [hide] filter. Any elements that are present in both the [show] and
  ///   [hide] filters will be excluded from the final export.
  ///
  /// If the [uri]s do not match, this instance is returned unmodified.
  Export merge(Export other) {
    if (uri != other.uri) return this;
    if (!_hasFilters || !other._hasFilters) {
      return Export(uri: uri, tags: tags);
    }
    final mergedShow = show.union(other.show);
    final mergedHide = hide.isNotEmpty && other.hide.isNotEmpty
        ? hide.intersection(other.hide)
        : hide.union(other.hide);
    return Export(
      uri: uri,
      show: (hide.isNotEmpty || other.hide.isNotEmpty) ? {} : mergedShow,
      hide: mergedHide.difference(mergedShow),
      tags: tags,
    );
  }

  /// Converts this [Export] to a single-line Dart `export` directive.
  String toDart() {
    final buffer = StringBuffer()..write("export '$uri'");
    if (show.isNotEmpty) buffer.write(' show ${show.sorted().join(', ')}');
    if (hide.isNotEmpty) buffer.write(' hide ${hide.sorted().join(', ')}');
    buffer.write(';');
    return buffer.toString();
  }

  /// Converts this [Export] to a JSON-serializable map.
  Map<String, dynamic> toJson() => {
        keys.uri: uri,
        keys.show: show.toList(),
        keys.hide: hide.toList(),
        keys.tags: tags.toList(),
      };

  @override
  int compareTo(Export other) => uri.compareTo(other.uri);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Export &&
          runtimeType == other.runtimeType &&
          uri == other.uri &&
          setEquals(show, other.show) &&
          setEquals(hide, other.hide) &&
          setEquals(tags, other.tags);

  @override
  int get hashCode => uri.hashCode ^ setHash(show) ^ setHash(hide) ^ setHash(tags);

  @override
  String toString() => '$Export{uri: $uri, show: $show, hide: $hide, tags: $tags}';
}
