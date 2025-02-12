import 'package:exported/src/model/barrel_file.dart';
import 'package:exported/src/validation/input_sanitizer.dart';

/// Sanitizes a list of `files` builder options based on the following rules:
/// - Duplicates with matching configuration are removed.
/// - Path duplicates with conflicting configuration throw an [ArgumentError].
/// - If the input is `null` or empty, the default barrel file will be added.
class BarrelFilesSanitizer extends InputSanitizer<List<BarrelFile>?, List<BarrelFile>> {
  const BarrelFilesSanitizer(super.inputName);

  /// Validates the [input] and returns the deduplicated list of exports.
  @override
  List<BarrelFile> sanitize(List<BarrelFile>? input) {
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
}
