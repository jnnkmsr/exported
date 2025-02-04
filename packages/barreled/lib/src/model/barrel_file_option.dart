// ignore_for_file: sort_constructors_first

import 'package:json_annotation/json_annotation.dart';

part 'barrel_file_option.g.dart';

/// Represents a Dart barrel file.
@JsonSerializable(createToJson: false)
class BarrelFileOption {
  const BarrelFileOption({
    this.name,
    this.dir,
    this.tags,
  });

  /// The name of the barrel file (`.dart` extensions can be omitted).
  ///
  /// If not specified, empty or `null`, the barrel file will be named as the
  /// package.
  final String? name;

  /// The relative path to the directory within the package where the barrel
  /// file should be created.
  ///
  /// If not specified, empty or `null`, the barrel file will be created in the
  /// default `lib` directory.
  final String? dir;

  /// The set of tags for selectively including exports in this barrel file.
  ///
  /// If not specified, empty or `null`, all exports are included.
  final Set<String>? tags;

  /// Creates a [BarrelFileOption] from a JSON (or YAML) map.
  factory BarrelFileOption.fromJson(Map json) => _$BarrelFileOptionFromJson(json);
}
