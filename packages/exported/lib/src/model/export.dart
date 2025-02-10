import 'package:analyzer/dart/constant/value.dart';
import 'package:analyzer/dart/element/element.dart';
import 'package:build/build.dart';
import 'package:collection/collection.dart';
import 'package:exported/src/builder/exported_option_keys.dart' as keys;
import 'package:exported/src/util/equals_util.dart';
import 'package:exported/src/validation/show_hide_sanitizer.dart';
import 'package:exported/src/validation/tags_sanitizer.dart';
import 'package:exported/src/validation/uri_sanitizer.dart';
import 'package:exported_annotation/exported_annotation.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:meta/meta.dart';
import 'package:source_gen/source_gen.dart';

part 'export.g.dart';

/// Represents a Dart `export` directive with a [uri] and an optional [show] or
/// [hide] filter.
///
/// The [tags] field is used to selectively include this export in barrel files.
///
/// [Export]s are collected both from elements annotated with `@exported` and
/// parsed from the `exports` section of the builder options.
@JsonSerializable(constructor: '_sanitized')
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
      tags: tagsSanitizer.sanitize(tags),
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
    try {
      return _$ExportFromJson(json);
    } on CheckedFromJsonException catch (_) {
      const name = keys.exports;
      throw ArgumentError.value(json, name, 'Invalid $name options');
    }
  }

  /// Private constructor called by [Export.fromJson], validating and
  /// sanitizing inputs.
  @protected
  factory Export._sanitized({
    required String uri,
    Set<String>? show,
    Set<String>? hide,
    Set<String>? tags,
  }) {
    final sanitizedShow = showSanitizer.sanitize(show);
    return Export(
      uri: uriSanitizer.sanitize(uri),
      show: sanitizedShow,
      hide: hideSanitizer.sanitize(hide, sanitizedShow),
      tags: tagsSanitizer.sanitize(tags),
    );
  }

  /// The URI of the `export` directive, sanitized to a Dart `package:` URI.
  @JsonKey(name: keys.uri)
  final String uri;

  /// The element names in the `show` statement of the `export` directive.
  @JsonKey(name: keys.show)
  final Set<String> show;

  /// The element names in the `hide` statement of the `export` directive.
  @JsonKey(name: keys.hide)
  final Set<String> hide;

  /// Tags for selectively including this export in barrel files.
  @JsonKey(name: keys.tags)
  final Set<String> tags;

  /// Sanitizer for [uri] inputs.
  @visibleForTesting
  static UriSanitizer uriSanitizer = const UriSanitizer(inputName: keys.uri);

  /// Sanitizer for [show] inputs.
  @visibleForTesting
  static ShowHideSanitizer showSanitizer = const ShowHideSanitizer(inputName: keys.show);

  /// Sanitizer for [hide] inputs.
  @visibleForTesting
  static ShowHideSanitizer hideSanitizer = const ShowHideSanitizer(inputName: keys.hide);

  /// Sanitizer for [tags] inputs.
  @visibleForTesting
  static TagsSanitizer tagsSanitizer = const TagsSanitizer();

  /// Copies this instance, combining [show] and [hide] filters with the ones
  /// from [other] if the [uri]s match.
  Export merge(Export other) {
    if (uri != other.uri) return this;
    return Export(
      uri: uri,
      show: show.union(other.show),
      hide: hide.union(other.hide),
      tags: tags,
    );
  }

  /// Converts this [Export] to a JSON-serializable map.
  Map<String, dynamic> toJson() => _$ExportToJson(this);

  /// Converts this [Export] to a single-line Dart `export` directive.
  String toDart() {
    final buffer = StringBuffer()..write("export '$uri'");
    if (show.isNotEmpty) buffer.write(' show ${show.sorted().join(',')}');
    if (hide.isNotEmpty) buffer.write(' hide ${hide.sorted().join(',')}');
    buffer.write(';');
    return buffer.toString();
  }

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
