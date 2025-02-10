import 'package:exported/src/options/exported_option_keys.dart' as keys;
import 'package:exported/src/util/equals_util.dart';
import 'package:exported/src/validation/show_hide_sanitizer.dart';
import 'package:exported/src/validation/tags_sanitizer.dart';
import 'package:exported/src/validation/uri_sanitizer.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:meta/meta.dart';

part 'export_option.g.dart';

/// Represents an entry in the `exports` section of the builder options.
///
/// Handles conversion from JSON and input validation/sanitization.
@JsonSerializable(createToJson: false)
@immutable
class ExportOption {
  /// Internal constructor called by [ExportOption.fromJson],
  @protected
  ExportOption({
    required String uri,
    Set<String>? show,
    Set<String>? hide,
    Set<String>? tags,
  })  : uri = uriSanitizer.sanitize(uri),
        show = showSanitizer.sanitize(show),
        hide = hideSanitizer.sanitize(hide),
        tags = tagsSanitizer.sanitize(tags);

  /// Creates a [ExportOption] from a JSON (or YAML) map.
  ///
  /// Throws an [ArgumentError] if invalid inputs are provided.
  factory ExportOption.fromJson(Map json) => _$ExportOptionFromJson(json);

  /// The package name or URI of the export.
  ///
  /// This can be either:
  /// - a fully-qualified URI (e.g. `package:flutter_test/flutter_test.dart` or
  ///   `flutter_test/flutter_test.dart`), or
  /// - a package name (e.g. `flutter_test`), which translates to a package URI
  ///   'package:$package/$package.dart';
  ///
  /// Any constructor of JSON input will be sanitized to a valid package URI:
  /// - The input is trimmed and must not be null, empty, or blank.
  /// - If missing, a leading `'package:'` prefix is added.
  /// - If the input is just a package name, it is converted to a URI of the
  ///   form `'package:<packageName>/<packageName>.dart'`.
  /// - If missing, a `'.dart'` extension is appended to the library file name.
  /// - All URI components (package name, intermediate directories, and library
  ///   file name must be snake-case (i.e. only lowercase letters, numbers, and
  ///   underscores).
  /// - The path is normalized, but must not end with a trailing `'/'`.
  ///
  /// Throws an [ArgumentError] if the input cannot be sanitized to a valid
  /// Dart export URI.
  @JsonKey(name: keys.uri)
  late final String uri;

  /// The set of element names in the `show` statement of the `export`.
  ///
  /// If empty, no `show` filter is applied.
  @JsonKey(name: keys.show)
  late final Set<String> show;

  /// The set of element names in the `hide` statement of the `export`.
  ///
  /// If empty, no `hide` filter is applied.
  @JsonKey(name: keys.hide)
  late final Set<String> hide;

  /// The set of tags for selectively including this export in barrel files.
  ///
  /// If empty, this export is treated as untagged.
  @JsonKey(name: keys.tags)
  late final Set<String> tags;

  /// Sanitizer for the [uri] input. Exchangeable by test doubles.
  @visibleForTesting
  static UriSanitizer uriSanitizer = const UriSanitizer(inputName: keys.uri);

  /// Sanitizer for the [show] input. Exchangeable by test doubles.
  @visibleForTesting
  static ShowHideSanitizer showSanitizer = const ShowHideSanitizer(inputName: keys.show);

  /// Sanitizer for the [hide] input. Exchangeable by test doubles.
  @visibleForTesting
  static ShowHideSanitizer hideSanitizer = const ShowHideSanitizer(inputName: keys.hide);

  /// Sanitizer for the [tags] input. Exchangeable by test doubles.
  @visibleForTesting
  static TagsSanitizer tagsSanitizer = const TagsSanitizer();

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ExportOption &&
          runtimeType == other.runtimeType &&
          uri == other.uri &&
          setEquals(show, other.show) &&
          setEquals(hide, other.hide) &&
          setEquals(tags, other.tags);

  @override
  int get hashCode => uri.hashCode ^ setHash(show) ^ setHash(hide) ^ setHash(tags);
}
