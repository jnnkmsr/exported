import 'package:build/build.dart';
import 'package:exported/src/builder/exported_option_keys.dart' as keys;
import 'package:exported/src/model/barrel_file.dart';
import 'package:exported/src/model/export.dart';
import 'package:exported/src/validation/barrel_files_parser.dart';
import 'package:exported/src/validation/exports_parser.dart';
import 'package:meta/meta.dart';

// TODO: Allow simple string lists of export URIs and file names.

/// Configuration options for the `exported` builder.
@immutable
class ExportedOptions {
  /// Internal constructor assigning sanitized values.
  @visibleForTesting
  const ExportedOptions({
    this.files = const [],
    this.exports = const [],
  });

  factory ExportedOptions.defaults() => ExportedOptions(
        files: filesParser.parse(),
        exports: exportsParser.parse(),
      );

  /// Creates [ExportedOptions] parsed from the given builder [options].
  ///
  /// Throws an [ArgumentError] if invalid [options] are provided.
  factory ExportedOptions.fromOptions(BuilderOptions options) =>
      ExportedOptions.fromJson(options.config);

  /// Creates [ExportedOptions] from a JSON (or YAML) map.
  ///
  /// Throws an [ArgumentError] if invalid inputs are provided.
  factory ExportedOptions.fromJson(Map json) => ExportedOptions(
        files: filesParser.parseJson(json[keys.barrelFiles]),
        exports: exportsParser.parseJson(json[keys.exports]),
      );

  /// The list of barrel files to generate. Set through the `files` field of
  /// the builder options.
  ///
  /// Input will be sanitized based on the following rules:
  /// - Duplicates with matching configuration are removed.
  /// - Path duplicates with conflicting configuration throw an [ArgumentError].
  /// - `null` is treated as an empty list.
  final List<BarrelFile> files;

  /// A list of exports to include in the generated barrel files in addition to
  /// the annotated elements in the source files. Set through the `exports`
  /// section of the builder options.
  ///
  /// Input will be sanitized based on the following rules:
  /// - Duplicates with matching configuration are removed.
  /// - URI duplicates with conflicting configuration throw an [ArgumentError].
  /// - `null` is treated as an empty list.
  final List<Export> exports;

  /// Parser for the [exports] input. Exchangeable by test doubles.
  @visibleForTesting
  static BarrelFilesParser filesParser = const BarrelFilesParser(keys.barrelFiles);

  /// Parser for the [files] input. Exchangeable by test doubles.
  @visibleForTesting
  static ExportsParser exportsParser = const ExportsParser(keys.exports);
}
