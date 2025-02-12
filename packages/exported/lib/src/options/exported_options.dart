import 'package:build/build.dart';
import 'package:exported/src/builder/exported_option_keys.dart' as keys;
import 'package:exported/src/model/barrel_file.dart';
import 'package:exported/src/model/export.dart';
import 'package:exported/src/validation/barrel_files_sanitizer.dart';
import 'package:exported/src/validation/exports_sanitizer.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:meta/meta.dart';

part 'exported_options.g.dart';

// TODO: Allow simple string lists of export URIs and file names.

/// Configuration options for the `exported` builder.
@JsonSerializable(createToJson: false)
@immutable
class ExportedOptions {
  /// Internal constructor called by [ExportedOptions.fromJson],
  @protected
  ExportedOptions({
    List<BarrelFile>? files,
    List<Export>? exports,
  })  : files = filesSanitizer.sanitize(files),
        exports = exportsSanitizer.sanitize(exports);

  /// Creates [ExportedOptions] parsed from the given builder [options].
  ///
  /// Throws an [ArgumentError] if invalid [options] are provided.
  factory ExportedOptions.fromOptions(BuilderOptions options) =>
      ExportedOptions.fromJson(options.config);

  /// Creates [ExportedOptions] from a JSON (or YAML) map.
  ///
  /// Throws an [ArgumentError] if invalid inputs are provided.
  factory ExportedOptions.fromJson(Map json) => _$ExportedOptionsFromJson(json);
  

  /// The list of barrel files to generate. Set through the `files` field of
  /// the builder options.
  ///
  /// Input will be sanitized based on the following rules:
  /// - Duplicates with matching configuration are removed.
  /// - Path duplicates with conflicting configuration throw an [ArgumentError].
  /// - `null` is treated as an empty list.
  @JsonKey(name: keys.barrelFiles)
  late final List<BarrelFile> files;

  /// A list of exports to include in the generated barrel files in addition to
  /// the annotated elements in the source files. Set through the `exports`
  /// section of the builder options.
  ///
  /// Input will be sanitized based on the following rules:
  /// - Duplicates with matching configuration are removed.
  /// - URI duplicates with conflicting configuration throw an [ArgumentError].
  /// - `null` is treated as an empty list.
  @JsonKey(name: keys.exports)
  late final List<Export> exports;

  /// Sanitizer for the [exports] input. Exchangeable by test doubles.
  @visibleForTesting
  static BarrelFilesSanitizer filesSanitizer = const BarrelFilesSanitizer(keys.barrelFiles);

  /// Sanitizer for the [files] input. Exchangeable by test doubles.
  @visibleForTesting
  static ExportsSanitizer exportsSanitizer = const ExportsSanitizer(keys.exports);
}
