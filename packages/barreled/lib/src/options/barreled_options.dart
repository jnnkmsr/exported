import 'package:barreled/src/options/barrel_file_option.dart';
import 'package:barreled/src/options/export_option.dart';
import 'package:barreled/src/validation/barrel_files_sanitizer.dart';
import 'package:barreled/src/validation/exports_sanitizer.dart';
import 'package:build/build.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:meta/meta.dart';

part 'barreled_options.g.dart';

// TODO: Allow simple string lists of export URIs and file names.

/// Builder options for generating Dart barrel files.
@JsonSerializable(createToJson: false)
@immutable
class BarreledOptions {
  /// Internal constructor called by [BarreledOptions.fromJson],
  @protected
  BarreledOptions({
    List<BarrelFileOption>? files,
    List<ExportOption>? exports,
  })  : files = filesSanitizer.sanitize(files),
        exports = exportsSanitizer.sanitize(exports);

  /// Creates [BarreledOptions] parsed from the given builder [options].
  ///
  /// Throws an [ArgumentError] if invalid [options] are provided.
  factory BarreledOptions.fromOptions(BuilderOptions options) =>
      BarreledOptions.fromJson(options.config);

  /// Creates [BarreledOptions] from a JSON (or YAML) map.
  ///
  /// Throws an [ArgumentError] if invalid inputs are provided.
  factory BarreledOptions.fromJson(Map json) => _$BarreledOptionsFromJson(json);

  /// The list of barrel files to generate. Set through the `files` field of
  /// the builder options.
  ///
  /// Input will be sanitized based on the following rules:
  /// - Duplicates with matching configuration are removed.
  /// - Path duplicates with conflicting configuration throw an [ArgumentError].
  /// - `null` is treated as an empty list.
  @JsonKey(name: filesKey)
  late final List<BarrelFileOption> files;
  static const filesKey = 'files';

  /// A list of exports to include in the generated barrel files in addition to
  /// the annotated elements in the source files. Set through the `exports`
  /// section of the builder options.
  ///
  /// Input will be sanitized based on the following rules:
  /// - Duplicates with matching configuration are removed.
  /// - URI duplicates with conflicting configuration throw an [ArgumentError].
  /// - `null` is treated as an empty list.
  @JsonKey(name: exportsKey)
  late final List<ExportOption> exports;
  static const exportsKey = 'exports';

  /// Sanitizer for the [exports] input. Exchangeable by test doubles.
  @visibleForTesting
  static BarrelFilesSanitizer filesSanitizer = const BarrelFilesSanitizer(inputName: filesKey);

  /// Sanitizer for the [files] input. Exchangeable by test doubles.
  @visibleForTesting
  static ExportsSanitizer exportsSanitizer = const ExportsSanitizer(inputName: exportsKey);
}
