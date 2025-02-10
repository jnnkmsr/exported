import 'package:barreled/src/options/barrel_file_option.dart';
import 'package:barreled/src/validation/validation_util.dart';

/// Sanitizes a list of `files` builder options based on the following rules:
/// - Duplicates with matching configuration are removed.
/// - Path duplicates with conflicting configuration throw an [ArgumentError].
/// - If the input is `null` or empty, the default barrel file will be added.
class BarrelFilesSanitizer with InputValidator {
  const BarrelFilesSanitizer({required this.inputName});

  @override
  final String inputName;

  /// Validates the [input] and returns the deduplicated list of exports.
  List<BarrelFileOption> sanitize(List<BarrelFileOption>? input) {
    if (input == null || input.isEmpty) return [BarrelFileOption()];

    final filesByPath = <String, BarrelFileOption>{};
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
