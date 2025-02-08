import 'package:barreled/src/options/barrel_file_option.dart';
import 'package:build/build.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:meta/meta.dart';
import 'package:path/path.dart' as p;

part 'barreled_options.g.dart';

/// Builder options for generating Dart barrel files.
@JsonSerializable(createToJson: false)
@immutable
class BarreledOptions {
  /// Internal constructor called by [BarreledOptions.fromJson],
  @protected
  BarreledOptions({
    List<BarrelFileOption>? files,
  }) : files = _sanitizeFiles(files);

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

  /// The list of Dart barrel files to generate, specified in the `barrel_files`
  /// field of the builder options.
  ///
  /// Empty lists or null-input are replaced with the default barrel file.
  ///
  /// Throws an [ArgumentError] if there are duplicate file names.
  @JsonKey(name: filesKey)
  late final List<BarrelFileOption> files;
  static const filesKey = 'barrel_files';

  /// Sanitizes the input [files], treating empty input as `null` and validating
  /// that all file names are unique.
  static List<BarrelFileOption> _sanitizeFiles(List<BarrelFileOption>? files) {
    if (files == null || files.isEmpty) return [BarrelFileOption()];

    final paths = <String>{};
    for (final file in files) {
      final path = p.join(file.dir, file.name);
      if (!paths.add(path)) {
        throw ArgumentError.value(files, 'files', 'Duplicate barrel file: $path');
      }
    }
    return files;
  }
}
