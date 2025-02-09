import 'package:barreled/src/validation/barrel_file_path_sanitizer.dart';
import 'package:barreled/src/validation/tags_sanitizer.dart';
import 'package:collection/collection.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:meta/meta.dart';

part 'barrel_file_option.g.dart';

/// Representation of a `barrel_files` option in the `barreled` builder
/// configuration.
///
/// Handles conversion from JSON and validates and sanitizes input.
@JsonSerializable(createToJson: false)
@immutable
class BarrelFileOption {
  /// Internal constructor called by [BarrelFileOption.fromJson],
  @protected
  BarrelFileOption({
    String? file,
    String? dir,
    Set<String>? tags,
  }) {
    final path = pathSanitizer.sanitize(fileInput: file, dirInput: dir);
    this.file = path.file;
    this.dir = path.dir;
    this.tags = tagsSanitizer.sanitize(tags);
  }

  /// Creates a [BarrelFileOption] from a JSON (or YAML) map.
  ///
  /// Throws an [ArgumentError] if invalid inputs are provided.
  factory BarrelFileOption.fromJson(Map json) => _$BarrelFileOptionFromJson(json);

  /// The name of the barrel file.
  ///
  /// Input will be sanitized based on the following rules:
  /// - Leading and trailing whitespace will be trimmed.
  /// - Missing `.dart` extension will be added to the input.
  /// - Empty or blank inputs will be treated as `null`.
  /// - Any leading directory path will be removed and merged into [dir].
  ///
  /// Throws an [ArgumentError] if
  /// - the name is not a valid file name,
  /// - a file extension other than `.dart` is specified,
  /// - the name is an absolute path.
  @JsonKey(name: fileKey)
  late final String? file;
  static const fileKey = 'file';

  /// The relative path to the directory within the package where the barrel
  /// file should be created.
  ///
  /// Input will be sanitized based on the following rules:
  /// - Leading and trailing whitespace will be trimmed.
  /// - Any directory path in the [file] input will be appended.
  /// - The resulting path will be normalized.
  /// - If no directory is specified, the default directory `lib` will be used.
  ///
  /// Throws an [ArgumentError] if
  /// - the directory path is not relative,
  /// - the path points to a file instead of a directory.
  @JsonKey(name: dirKey)
  late final String dir;
  static const dirKey = 'dir';

  /// The set of tags for selectively including exports in this barrel file.
  ///
  /// Input will be sanitized based on the following rules:
  /// - Leading and trailing whitespace will be trimmed from all tags.
  /// - Empty or blank tags will be removed.
  /// - Duplicate tags will be removed.
  /// - If the resulting set is empty, it will be treated as `null`.
  @JsonKey(name: tagsKey)
  late final Set<String> tags;
  static const tagsKey = 'tags';

  /// Sanitizer for the [file] and [dir] inputs. Exchangeable by test doubles.
  @visibleForTesting
  static BarrelFilePathSanitizer pathSanitizer = BarrelFilePathSanitizer(
    fileInputName: fileKey,
    dirInputName: dirKey,
  );

  /// Sanitizer for the [tags] input. Exchangeable by test doubles.
  @visibleForTesting
  static TagsSanitizer tagsSanitizer = const TagsSanitizer();

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is BarrelFileOption &&
          runtimeType == other.runtimeType &&
          file == other.file &&
          dir == other.dir &&
          _setEquality.equals(tags, other.tags);

  @override
  int get hashCode => file.hashCode ^ dir.hashCode ^ _setEquality.hash(tags);

  static const _setEquality = SetEquality<String>();
}
