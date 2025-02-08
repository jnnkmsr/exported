import 'package:json_annotation/json_annotation.dart';
import 'package:meta/meta.dart';
import 'package:path/path.dart' as p;

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
    String? name,
    String? dir,
    Set<String>? tags,
  }) {
    final (sanitizedDir, sanitizedName) = _sanitizePath(dir, name);
    this.name = sanitizedName;
    this.dir = sanitizedDir;
    this.tags = _sanitizeTags(tags);
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
  @JsonKey(name: nameKey)
  late final String? name;
  static const nameKey = 'name';

  /// The relative path to the directory within the package where the barrel
  /// file should be created.
  ///
  /// Input will be sanitized based on the following rules:
  /// - Leading and trailing whitespace will be trimmed.
  /// - Any directory path in the [name] input will be appended.
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
  late final Set<String>? tags;
  static const tagsKey = 'tags';

  /// The default [dir] if no directory is specified.
  static const _defaultDir = 'lib';

  /// Sanitizes the [dir] and [file] inputs, separating file and directory
  /// components, normalizing paths and validating the input.
  ///
  /// Returns a tuple of the sanitized directory and file paths.
  static (String, String?) _sanitizePath(String? dir, String? file) {
    var sanitizedDir = dir?.trim();

    if (sanitizedDir == null || sanitizedDir.isEmpty) {
      sanitizedDir = null;
    } else {
      sanitizedDir = p.normalize(sanitizedDir);

      if (!p.isRelative(sanitizedDir)) {
        throw ArgumentError.value(dir, 'dir', 'Directory path must be relative');
      }
      if (p.extension(sanitizedDir).isNotEmpty) {
        throw ArgumentError.value(dir, 'dir', 'Directory path cannot be a file');
      }
    }

    var sanitizedFile = file?.trim();

    if (sanitizedFile == null || sanitizedFile.isEmpty) {
      sanitizedFile = null;
    } else {
      final extension = p.extension(sanitizedFile);
      final dir = p.dirname(p.normalize(sanitizedFile));
      sanitizedFile = p.basename(p.setExtension(sanitizedFile, '.dart'));

      if (extension.isNotEmpty && extension != '.dart') {
        throw ArgumentError.value(file, 'file', 'Invalid file extension: $extension');
      }

      if (dir != '.' && dir.isNotEmpty) {
        if (!p.isRelative(dir)) {
          throw ArgumentError.value(file, 'file', 'Directory path must be relative');
        }
        sanitizedDir = sanitizedDir != null ? p.normalize(p.join(sanitizedDir, dir)) : dir;
      }

      final validFilePattern = RegExp(r'^[^.][a-zA-Z0-9._\-/]*[^.]$');
      if (!validFilePattern.hasMatch(sanitizedFile)) {
        throw ArgumentError.value(file, 'name', 'Invalid barrel-file name');
      }
    }

    return (sanitizedDir ?? _defaultDir, sanitizedFile);
  }

  /// Sanitizes the [tags] input, removing any empty, blank or duplicate tags.
  ///
  /// Returns the sanitized set of tags or `null` if the remaining set is empty.
  static Set<String>? _sanitizeTags(Set<String>? tags) {
    if (tags == null) return null;

    final sanitizedTags = tags.map((tag) => tag.trim()).where((tag) => tag.isNotEmpty);
    if (sanitizedTags.isEmpty) return null;

    return sanitizedTags.toSet();
  }
}
