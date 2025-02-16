import 'package:exported/src/model_legacy/barrel_file.dart';
import 'package:exported/src/validation/option_parser.dart';

/// Validates and sanitizes a list of `barrel_files` builder options.
///
/// - Removes duplicate paths by merging tags.
/// - If the input is `null` or empty, the default package-named barrel file
///   will be added.
class BarrelFilesParser extends ListOptionParser<BarrelFile> {
  const BarrelFilesParser(super.inputName);

  /// Validates the [input] and returns the deduplicated list of exports.
  @override
  List<BarrelFile> parse([List<BarrelFile>? input]) {
    if (input == null || input.isEmpty) return [BarrelFile.packageNamed()];

    final filesByPath = <String, BarrelFile>{};
    for (final file in input) {
      filesByPath.update(
        file.path,
        (existingFile) => BarrelFile(
          path: existingFile.path,
          tags: existingFile.tags.union(file.tags),
        ),
        ifAbsent: () => file,
      );
    }
    return filesByPath.values.toList();
  }

  @override
  BarrelFile elementFromJson(dynamic json) {
    if (json is! String && json is! Map) {
      throwArgumentError(json, 'Only path strings or key-value maps are allowed');
    }
    return BarrelFile.fromJson(json);
  }
}
