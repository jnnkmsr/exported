import 'package:build/build.dart';
import 'package:exported/src/builder/exported_option_keys.dart' as keys;
import 'package:exported/src/model_legacy/barrel_file.dart';
import 'package:exported/src/model_legacy/export.dart';
import 'package:exported/src/validation/barrel_files_parser.dart';
import 'package:exported/src/validation/exports_parser.dart';
import 'package:meta/meta.dart';

/// Configuration options for the `exported` builder.
@immutable
class ExportedOptions {
  /// Creates [ExportedOptions] parsed from builder [options], validating and
  /// sanitizing inputs.
  ///
  /// Set [barrelFiles] and [exports] from the `barrel_files` and `exports`
  /// sections of the builder options, respectively. Removes duplicates with
  /// matching configuration and throws an [ArgumentError] for barrel files or
  /// exports that have the same path/URI but conflicting configuration.
  ///
  /// Missing or empty sections are treated as empty lists.
  ///
  /// Validates and sanitizes every [BarrelFile] and [Export] input and throws
  /// an [ArgumentError] for any invalid input or option keys.
  factory ExportedOptions.fromOptions(BuilderOptions options) =>
      ExportedOptions._fromJson(options.config);

  /// Called by [ExportedOptions.fromOptions] to parse, validate and sanitize
  /// the builder options.
  factory ExportedOptions._fromJson(Map json) {
    final invalidOptions = json.keys.toSet().difference(_options);
    if (invalidOptions.isNotEmpty) {
      throw ArgumentError('Invalid options: $invalidOptions');
    }
    return ExportedOptions._(
      barrelFiles: filesParser.parseJson(json[keys.barrelFiles]),
      exports: exportsParser.parseJson(json[keys.exports]),
    );
  }

  /// Internal constructor assigning sanitized values.
  const ExportedOptions._({
    this.barrelFiles = const [],
    this.exports = const [],
  });

  /// The list of barrel files to generate.
  ///
  /// Set through the `barrel_files` field of the builder options.
  final List<BarrelFile> barrelFiles;

  /// A list of exports to include in the generated barrel files in addition to
  /// the annotated elements in the source files.
  ///
  /// Set through the `exports` section of the builder options.
  final List<Export> exports;

  /// The keys of all builder options.
  static const _options = {keys.barrelFiles, keys.exports};

  /// Parser for the [exports] input.
  @visibleForTesting
  static BarrelFilesParser filesParser = const BarrelFilesParser(keys.barrelFiles);

  /// Parser for the [barrelFiles] input.
  @visibleForTesting
  static ExportsParser exportsParser = const ExportsParser(keys.exports);
}
