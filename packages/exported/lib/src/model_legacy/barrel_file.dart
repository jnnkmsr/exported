import 'package:collection/collection.dart';
import 'package:exported/src/model_legacy/equals_util.dart';
import 'package:exported/src/model_legacy/export.dart';
import 'package:exported/src/builder/exported_option_keys.dart' as keys;
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
  /// Input can be either a path string or a key-value map. For string inputs,
  /// the [path] is sanitized and [tags] are empty.
  ///
  /// Input validation and sanitization rules are as follows:
  ///
  /// **[path]:**
  /// - Trims leading/trailing whitespace.
  /// - Normalizes the path, ensures it is relative and snake-case, and removes
  ///   any leading `lib/`.
  /// - Ensures the file extension is `.dart` or adds it if missing. If an
  ///   extension is present, it must be `.dart`.
  /// - If [path] is not provided, is empty/blank, or ends with `/`, the
  ///   default barrel-file path `$package.dart` is used, reading `package`
  ///   from `pubspec.yaml`.
  ///
  /// **[tags]:**
  /// - Trims whitespace and converts to lowercase.
  /// - Removes empty/blank tags and duplicates.
  ///
  /// Any invalid input throws an [ArgumentError].
  factory BarrelFile.fromJson(dynamic json) => switch (json) {
        String _ => BarrelFile(path: pathParser.parse(json)),
        Map _ => BarrelFile._fromJson(json),
        // This should have been checked by a previous ExportsParser.
        _ => throw AssertionError('Unexpected JSON input: $json'),
      };

  /// Called by [BarrelFile.fromJson] if the input is a key-value map.
  factory BarrelFile._fromJson(Map json) {
    final invalidOptions = json.keys.toSet().difference(_options);
    if (invalidOptions.isNotEmpty) {
      throw ArgumentError('Invalid `${keys.barrelFiles}` options: $invalidOptions');
    }
    return BarrelFile(
      path: pathParser.parseJson(json[keys.path]),
      tags: tagsParser.parseJson(json[keys.tags]),
    );
  }

  /// The relative path within the target package’s `lib` directory.
  final String path;

  /// Tags for selectively including exports.
  final Set<String> tags;

  /// The keys of all `barrel_files` builder options.
  static const _options = {keys.path, keys.tags};

  /// Parser for [path] inputs.
  @visibleForTesting
  static FilePathParser pathParser = const FilePathParser(keys.path);

  /// Parser for [tags] inputs.
  @visibleForTesting
  static TagsParser tagsParser = const TagsParser(keys.tags);

  /// Builds a sorted and merged list of [Export]s to include in this barrel
  /// file, filtering out any that do not match the [tags].
  ///
  /// Includes an [Export] if it is untagged or if there is at least one
  /// matching tag.
  ///
  /// If duplicate there are multiple matching exports with the same URI, they
  /// are merged by combining `show` and `hide` filters.
  List<Export> buildExports(Iterable<Export> exports) {
    final matchingExportsByUri = <String, Export>{};
    for (final export in exports) {
      if (!_shouldInclude(export)) continue;
      matchingExportsByUri.update(
        export.uri,
        (existingExport) => existingExport.merge(export),
        ifAbsent: () => export,
      );
    }
    return matchingExportsByUri.values.sorted();
  }

  /// Whether the given [export] should be included in this barrel file.
  ///
  /// Returns `true` if this file or the [export] are untagged, or if there is
  /// at least one matching tag.
  bool _shouldInclude(Export export) =>
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
