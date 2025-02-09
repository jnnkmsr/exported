import 'package:barreled/src/options/barrel_file_option.dart';
import 'package:barreled/src/validation/validation_util.dart';
import 'package:path/path.dart' as p;

/// Sanitizes a list of `files` builder options based on the following rules:
/// - Duplicates with matching configuration are removed.
/// - Path duplicates with conflicting configuration throw an [ArgumentError].
/// - `null` is treated as an empty list.
class BarrelFilesSanitizer with InputValidator {
  const BarrelFilesSanitizer({required this.inputName});

  @override
  final String inputName;

  /// Validates the [input] and returns the deduplicated list of exports.
  List<BarrelFileOption> sanitize(List<BarrelFileOption>? input) {
    if (input == null) return [];

    final filesByPath = <String, BarrelFileOption>{};
    for (final export in input) {
      final path = p.join(export.dir, export.file);
      final existing = filesByPath[path];
      if (existing != null && existing != export) {
        throwArgumentError(path, 'Duplicate conflicting files: $path');
      } else if (existing == null) {
        filesByPath[path] = export;
      }
    }
    return filesByPath.values.toList();
  }
}
