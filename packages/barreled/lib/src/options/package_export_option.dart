import 'package:barreled/src/validation/export_uri_sanitizer.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:meta/meta.dart';

part 'package_export_option.g.dart';

// TODO: Allow simple string lists of URIs?
// TODO: Sanitize [show]/[hide]/[tags].
// TODO: Rename [PackageExportOption] to `ExportOption` and [package] input to `uri`.

/// Representation of an `package_exports` option in the `barreled` builder
/// configuration.
///
/// Handles conversion from JSON and validates and sanitizes input.
@JsonSerializable(createToJson: false)
@immutable
class PackageExportOption {
  /// Internal constructor called by [PackageExportOption.fromJson],
  @protected
  PackageExportOption({
    required String package,
    this.show = const {},
    this.hide = const {},
    this.tags = const {},
  }) {
    this.package = packageSanitizer.sanitize(package);
  }

  /// Creates a [PackageExportOption] from a JSON (or YAML) map.
  ///
  /// Throws an [ArgumentError] if invalid inputs are provided.
  factory PackageExportOption.fromJson(Map json) => _$PackageExportOptionFromJson(json);

  /// The package name or library URI of the export.
  ///
  /// This can be either:
  /// - a fully-qualified URI (e.g. `package:flutter_test/flutter_test.dart` or
  ///   `flutter_test/flutter_test.dart`), or
  /// - a package name (e.g. `flutter_test`), which translates to a package URI
  ///   'package:$package/$package.dart';
  ///
  /// Throws an [ArgumentError] if the package is not a valid package name or
  /// library URI.
  @JsonKey(name: packageKey)
  late final String package;
  static const packageKey = 'package';

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

  @visibleForTesting
  static ExportUriSanitizer packageSanitizer = const ExportUriSanitizer(inputName: packageKey);
}
