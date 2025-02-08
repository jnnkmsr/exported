import 'package:barreled/src/validation/export_uri_sanitizer.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:meta/meta.dart';

part 'export_option.g.dart';

// TODO: Allow simple string lists of URIs?
// TODO: Sanitize [show]/[hide]/[tags].

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
    this.show = const {},
    this.hide = const {},
    this.tags = const {},
  }) {
    this.uri = uriSanitizer.sanitize(uri);
  }

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
  @JsonKey(name: uriKey)
  late final String uri;
  static const uriKey = 'uri';

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
  /// If empty, this export is treated as untagged.
  @JsonKey(name: tagsKey)
  final Set<String> tags;
  static const tagsKey = 'tags';

  @visibleForTesting
  static ExportUriSanitizer uriSanitizer = const ExportUriSanitizer(inputName: uriKey);
}
