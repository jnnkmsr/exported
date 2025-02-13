import 'package:exported/src/model/barrel_file.dart';
import 'package:exported/src/validation/input_parser.dart';

/// Sanitizes a list of `files` builder options based on the following rules:
/// - Duplicates with matching configuration are removed.
/// - Path duplicates with conflicting configuration throw an [ArgumentError].
/// - If the input is `null` or empty, the default barrel file will be added.
class BarrelFilesParser extends ListParser<BarrelFile> {
  const BarrelFilesParser(super.inputName);

  /// Validates the [input] and returns the deduplicated list of exports.
  @override
  List<BarrelFile> parse([List<BarrelFile>? input]) {
    if (input == null || input.isEmpty) return [BarrelFile.packageNamed()];

    final filesByPath = <String, BarrelFile>{};
    for (final file in input) {
      final existing = filesByPath[file.path];
      if (existing != null && existing != file) {
        throwArgumentError(file.path, 'Duplicate conflicting files: ${file.path}');
      } else if (existing == null) {
        filesByPath[file.path] = file;
      }
    }
    return filesByPath.values.toList();
  }

  @override
  BarrelFile elementFromJson(dynamic json) {
    if (json is! String && json is! Map) {
      throwArgumentError(json, 'Must be either path strings or key-value maps');
    }
    return BarrelFile.fromJson(json);
  }
}
