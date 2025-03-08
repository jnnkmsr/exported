import 'package:exported/src/model/barrel_file.dart';
import 'package:exported/src/model/export.dart';
import 'package:exported/src/model/exported_option_keys.dart' as keys;
import 'package:exported/src/model/option_collections.dart';
import 'package:meta/meta.dart';

/// Configuration options for the `exported` builder.
@immutable
class ExportedOptions {
  @visibleForTesting
  const ExportedOptions(
    this.barrelFiles,
    this.exports,
  );

  /// Creates [ExportedOptions] by setting [barrelFiles] and [exports] from the
  /// respective builder options, validating and sanitizing inputs.
  ///
  /// Input validation/sanitization:
  /// - Removes duplicate barrel files or exports with matching configuration.
  /// - Throws an [ArgumentError] for barrel files or exports that have the
  ///   same path/URI but conflicting configuration.
  /// - Validates and sanitizes every [BarrelFile] and [Export] input, throwing
  ///   an [ArgumentError] for any invalid input or option keys.
  /// - Treats missing or empty sections as empty lists, using defaults. For an
  ///   empty `barrel_files` list, a single barrel file will be generated, named
  ///   after the [package].
  /// - Throws an [ArgumentError] if input validation/sanitization fails for
  ///   any nested [BarrelFile] or [Export].
  factory ExportedOptions.fromInput(
    Map options, {
    required String package,
  }) =>
      fromInputMapOrString(
        options,
        parentKey: 'exported',
        validKeys: const {keys.barrelFiles, keys.exports},
        fromMap: (options) => ExportedOptions(
          BarrelFile.fromInput(options[keys.barrelFiles], package: package),
          Export.fromInput(options[keys.exports], package: package),
        ),
      );

  /// Barrel files to generate, set through the `barrel_files` builder option.
  ///
  /// If empty, a single barrel file will be generated, named after the package.
  final OptionList<BarrelFile> barrelFiles;

  /// Exports to include in the generated barrel files in addition to annotated
  /// source-file elements, set through the `exports` builder option.
  final OptionList<Export> exports;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ExportedOptions &&
          runtimeType == other.runtimeType &&
          barrelFiles == other.barrelFiles &&
          exports == other.exports;

  @override
  int get hashCode => Object.hash(runtimeType, barrelFiles, exports);

  @override
  String toString() => '$ExportedOptions{'
      'barrelFiles: $barrelFiles, '
      'exports: $exports}';
}
