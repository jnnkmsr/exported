import 'package:barreled/src/validation/file_path_sanitizer.dart';
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
    String? path,
    Set<String>? tags,
  }) : path = pathSanitizer.sanitize(path),
       tags = tagsSanitizer.sanitize(tags);

  /// Creates a [BarrelFileOption] from a JSON (or YAML) map.
  ///
  /// Throws an [ArgumentError] if invalid inputs are provided.
  factory BarrelFileOption.fromJson(Map json) => _$BarrelFileOptionFromJson(json);

  /// The name of the barrel file.
  ///
  /// Input will be validated and sanitized based on the following rules:
  /// - Leading and trailing whitespace will be trimmed.
  /// - Paths are normalized.
  /// - Paths must be relative and are assumed to be relative to the `lib`
  ///   directory. A leading `lib/` directory is removed.
  /// - All path components must be snake-case (only lowercase letters, numbers,
  ///   and underscores).
  /// - For `null`, empty or blank inputs, or directory inputs ending with a
  ///   `/`, the default file name `<package>.dart` is used, reading the package
  ///   name from the `pubspec.yaml`.
  /// - For file-path inputs, a missing `.dart` extension is appended. If an
  ///   extension is specified, it must be `.dart`.
  @JsonKey(name: pathKey)
  late final String path;
  static const pathKey = 'path';

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

  /// Sanitizer for the [path] input. Exchangeable by test doubles.
  @visibleForTesting
  static FilePathSanitizer pathSanitizer = FilePathSanitizer(inputName: pathKey);

  /// Sanitizer for the [tags] input. Exchangeable by test doubles.
  @visibleForTesting
  static TagsSanitizer tagsSanitizer = const TagsSanitizer();

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is BarrelFileOption &&
          runtimeType == other.runtimeType &&
          path == other.path &&
          _setEquality.equals(tags, other.tags);

  @override
  int get hashCode => path.hashCode ^ _setEquality.hash(tags);

  static const _setEquality = SetEquality<String>();
}
