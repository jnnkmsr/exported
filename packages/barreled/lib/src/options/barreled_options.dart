import 'package:barreled/src/options/barrel_file_option.dart';
import 'package:barreled/src/options/export_option.dart';
import 'package:build/build.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:meta/meta.dart';
import 'package:path/path.dart' as p;

part 'barreled_options.g.dart';

// TODO: Unit test `BarreledOptions.packageExports`.
// TODO: Check for duplicate package exports?

/// Builder options for generating Dart barrel files.
@JsonSerializable(createToJson: false)
@immutable
class BarreledOptions {
  /// Internal constructor called by [BarreledOptions.fromJson],
  @protected
  BarreledOptions({
    List<BarrelFileOption>? files,
    List<ExportOption>? exports,
  })  : files = _sanitizeFiles(files),
        exports = _sanitizePackageExports(exports);

  /// Creates [BarreledOptions] parsed from the given builder [options].
  ///
  /// Throws an [ArgumentError] if invalid [options] are provided.
  factory BarreledOptions.fromOptions(BuilderOptions options) {
    return BarreledOptions.fromJson(options.config);
  }

  /// Creates [BarreledOptions] from a JSON (or YAML) map.
  ///
  /// Throws an [ArgumentError] if invalid inputs are provided.
  factory BarreledOptions.fromJson(Map json) => _$BarreledOptionsFromJson(json);

  /// The list of barrel files to generate. Set through the `files`
  /// field of the builder options.
  ///
  /// Empty lists or null-input are replaced with the default barrel file.
  ///
  /// Throws an [ArgumentError] if there are duplicate file names.
  @JsonKey(name: filesKey)
  late final List<BarrelFileOption> files;
  static const filesKey = 'files';

  /// A list of exports to include in the generated barrel files in addition to
  /// the annotated elements in the source files. Set through the `exports`
  /// section of the builder options.
  // TODO: Add documentation.
  @JsonKey(name: exportsKey)
  late final List<ExportOption> exports;
  static const exportsKey = 'exports';

  /// Sanitizes the input [files], treating empty input as `null` and validating
  /// that all file names are unique.
  static List<BarrelFileOption> _sanitizeFiles(List<BarrelFileOption>? files) {
    if (files == null || files.isEmpty) return [BarrelFileOption()];

    final paths = <String>{};
    for (final file in files) {
      final path = p.join(file.dir, file.file);
      if (!paths.add(path)) {
        throw ArgumentError.value(files, 'files', 'Duplicate barrel file: $path');
      }
    }
    return files;
  }

  /// Sanitizes the input [packageExports], treating `null` input as an empty
  /// list.
  static List<ExportOption> _sanitizePackageExports(
    List<ExportOption>? packageExports,
  ) {
    return packageExports ?? [];
  }
}
