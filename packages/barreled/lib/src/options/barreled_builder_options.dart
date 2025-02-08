import 'package:barreled/src/options//barrel_file_option.dart';
import 'package:build/build.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:meta/meta.dart';
import 'package:path/path.dart' as p;

part 'barreled_builder_options.g.dart';

/// Builder options for generating Dart barrel files.
@JsonSerializable(createToJson: false)
class BarreledBuilderOptions {
  /// Internal constructor called by [BarreledBuilderOptions.fromJson],
  @protected
  BarreledBuilderOptions({
    List<BarrelFileOption>? files,
  }) : files = _sanitizeFiles(files);

  /// Creates [BarreledBuilderOptions] parsed from the given builder [options].
  ///
  /// Throws an [ArgumentError] if invalid [options] are provided.
  factory BarreledBuilderOptions.fromOptions(BuilderOptions options) {
    return BarreledBuilderOptions.fromJson(options.config);
  }

  /// Creates [BarreledBuilderOptions] from a JSON (or YAML) map.
  ///
  /// Throws an [ArgumentError] if invalid inputs are provided.
  factory BarreledBuilderOptions.fromJson(Map json) => _$BarreledBuilderOptionsFromJson(json);

  /// The list of Dart barrel files to generate, specified in the `barrel_files`
  /// field of the builder options.
  ///
  /// Empty lists or null-input are replaced with the default barrel file.
  ///
  /// Throws an [ArgumentError] if there are duplicate file names.
  @JsonKey(name: 'barrel_files')
  late final List<BarrelFileOption> files;

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
