import 'package:exported/src/builder/exported_option_keys.dart' as keys;
import 'package:exported/src/model/export.dart';
import 'package:exported/src/util/equals_util.dart';
import 'package:exported/src/validation/file_path_parser.dart';
import 'package:exported/src/validation/tags_parser.dart';
import 'package:meta/meta.dart';

/// Represents a barrel file as defined in the `barrel_files` section of the
/// `exported` builder options. Parses and validates `build.yaml` input and
/// models the file during the build process.
///
/// The [path] determines the file’s relative location in the package’s `lib`
/// folder (normalized, snake-case, and ending with `.dart`), while [tags]
/// allow selective inclusion of exports.
@immutable
class BarrelFile {
  /// Internal constructor assigning sanitized values.
  @visibleForTesting
  const BarrelFile({
    required this.path,
    this.tags = const {},
  });

  /// Creates the default [BarrelFile] for the targeted package.
  ///
  /// The [path] defaults to `<package>.dart` (using the package name from
  /// `pubspec.yaml`), and [tags] are empty.
  factory BarrelFile.packageNamed() => BarrelFile(path: pathParser.parse());

  /// Creates a [BarrelFile] from JSON/YAML input, validating and sanitizing
  /// inputs.
  ///
  /// The following rules apply:
  ///
  /// **[path]:**
  /// - Trims leading/trailing whitespace.
  /// - Normalizes the path, ensures it is relative and snake-case, and removes
  ///   any leading `lib/`.
  /// - Ensures the file extension is `.dart` or adds it if missing.
  /// - If the path is empty, blank, or ends with `/`, the file name is set to
  ///   `$package.dart`, using the package name from `pubspec.yaml`.
  ///
  /// **[tags]:**
  /// - Trims whitespace and converts to lowercase.
  /// - Removes empty/blank tags and duplicates.
  ///
  /// Throws an [ArgumentError] for invalid inputs.
  factory BarrelFile.fromJson(Map json) => BarrelFile(
        path: pathParser.parseJson(json[keys.path]),
        tags: tagsParser.parseJson(json[keys.tags]),
      );

  /// The relative path within the target package’s `lib` directory.
  final String path;

  /// Tags for selectively including exports.
  final Set<String> tags;

  /// Parser for [path] inputs.
  @visibleForTesting
  static FilePathParser pathParser = const FilePathParser(keys.path);

  /// Parser for [tags] inputs.
  @visibleForTesting
  static TagsParser tagsParser = const TagsParser(keys.tags);

  /// Whether the given [export] should be included in this barrel file.
  ///
  /// Returns `true` if this file or the [export] are untagged, or if there is
  /// at least one matching tag.
  bool shouldInclude(Export export) =>
      tags.isEmpty || export.tags.isEmpty || tags.intersection(export.tags).isNotEmpty;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is BarrelFile &&
          runtimeType == other.runtimeType &&
          path == other.path &&
          setEquals(tags, other.tags);

  @override
  int get hashCode => path.hashCode ^ setHash(tags);

  @override
  String toString() => '$BarrelFile{path: $path, tags: $tags}';
}
