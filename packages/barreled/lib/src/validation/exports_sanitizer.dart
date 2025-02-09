import 'package:barreled/src/options/export_option.dart';
import 'package:barreled/src/validation/validation_util.dart';

/// Sanitizes a list of `exports` builder options based on the following rules:
/// - Duplicates with matching configuration are removed.
/// - URI duplicates with conflicting configuration throw an [ArgumentError].
/// - `null` is treated as an empty list.
class ExportsSanitizer with InputValidator {
  const ExportsSanitizer({required this.inputName});

  @override
  final String inputName;

  /// Validates the [input] and returns the deduplicated list of exports.
  List<ExportOption> sanitize(List<ExportOption>? input) {
    if (input == null) return [];

    final exportsByUri = <String, ExportOption>{};
    for (final export in input) {
      final uri = export.uri;
      final existing = exportsByUri[uri];
      if (existing != null && existing != export) {
        throwArgumentError(uri, 'Duplicate conflicting exports: $uri');
      } else if (existing == null) {
        exportsByUri[uri] = export;
      }
    }
    return exportsByUri.values.toList();
  }
}
