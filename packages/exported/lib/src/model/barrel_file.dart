import 'package:exported/src/model/barrel_file_path.dart';
import 'package:exported/src/model/exported_option_keys.dart' as keys;
import 'package:exported/src/model/option_collections.dart';
import 'package:exported/src/model/tag.dart';
import 'package:meta/meta.dart';

/// Represents a barrel file to be generated during the build process.
///
/// Created from the `barrel_files` builder options by [BarrelFile.fromInput]
/// or by [BarrelFile.packageNamed], returning the default `'$package.dart'`
/// file.
///
/// The [path] specifies the relative location in the target package’s `lib`
/// directory, [tags] allow selective inclusion of matching exports.
@immutable
class BarrelFile {
  @visibleForTesting
  BarrelFile({
    required String path,
    Set<String>? tags,
  }) : this._(path.asBarrelFilePath, tags?.asTags ?? Tags.none);

  /// Creates the default [BarrelFile] for the targeted package.
  ///
  /// The [path] will be `'$package.dart'`, using the given [package] name, and
  /// [tags] will be [Tags.none].
  BarrelFile.packageNamed({required String package})
      : this._(BarrelFilePath.packageNamed(package: package));

  /// Creates a list of [BarrelFile]s from the `barrel_files` builder options
  /// [input].
  ///
  /// Input may either be a single element or a list of elements, each of which
  /// can be a string or a map. String input is parsed as a path, with [tags]
  /// defaulting to [Tags.none]. Map input may contain `path` and `tags` keys.
  ///
  /// If the input is empty or null, a single [BarrelFile.packageNamed] is
  /// returned. Elements without a `path` key will also default to the
  /// [BarrelFilePath.packageNamed] path.
  ///
  /// Duplicate files with matching [path] are removed if they have the same
  /// [tags] or throw an [ArgumentError] otherwise.
  ///
  /// See [BarrelFilePath.fromInput] and [Tags.fromInput] for input validation
  /// and sanitization of [path] and [tags].
  static OptionList<BarrelFile> fromInput(
    dynamic input, {
    required String package,
  }) {
    final files = OptionList.fromInput(
      input,
      (element) => fromInputMapOrString(
        element,
        parentKey: keys.barrelFiles,
        validKeys: const {keys.path, keys.tags},
        fromMap: (Map input) => BarrelFile._(
          BarrelFilePath.fromInput(input, package: package),
          Tags.fromInput(input),
        ),
        fromString: (String input) => BarrelFile._(
          BarrelFilePath.fromInput(input, package: package),
        ),
      ),
    );
    final paths = <String>{};
    for (final file in files) {
      if (!paths.add(file.path)) {
        throw ArgumentError.value(file.path, keys.barrelFiles, 'Duplicate barrel file path');
      }
    }
    return files.isEmpty ? OptionList.single(BarrelFile.packageNamed(package: package)) : files;
  }

  const BarrelFile._(
    this.path, [
    this.tags = Tags.none,
  ]);

  /// Specifies the relative location in the target package’s `lib` directory.
  final BarrelFilePath path;

  /// Optional tags for selective inclusion of exports with matching tags.
  /// Defaults to [Tags.none], which includes all exports.
  final Tags tags;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is BarrelFile &&
          runtimeType == other.runtimeType &&
          path == other.path &&
          tags == other.tags;

  @override
  int get hashCode => Object.hash(runtimeType, path, tags);

  @override
  String toString() => '$BarrelFile{path: $path, tags: $tags}';
}
