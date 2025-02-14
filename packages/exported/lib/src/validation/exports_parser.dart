import 'package:exported/src/model/export.dart';
import 'package:exported/src/validation/input_parser.dart';

// TODO[ExportsParser]: Clean up doc comment.
// TODO[ExportsParser]: Merge duplicate exports instead of throwing?

/// Sanitizes a list of `exports` builder options based on the following rules:
/// - Duplicates with matching configuration are removed.
/// - URI duplicates with conflicting configuration throw an [ArgumentError].
/// - `null` is treated as an empty list.
class ExportsParser extends ListParser<Export> {
  const ExportsParser(super.inputName);

  /// Validates the [input] and returns the deduplicated list of exports.
  @override
  List<Export> parse([List<Export>? input]) {
    if (input == null) return [];

    final exportsByUri = <String, Export>{};
    for (final export in input) {
      final existing = exportsByUri[export.uri];
      if (existing != null && existing != export) {
        throwArgumentError(export.uri, 'Duplicate conflicting exports');
      } else if (existing == null) {
        exportsByUri[export.uri] = export;
      }
    }
    return exportsByUri.values.toList();
  }

  @override
  Export elementFromJson(dynamic json) {
    if (json is! String && json is! Map) {
      throwArgumentError(json, 'Only URI strings or key-value maps are allowed');
    }
    return Export.fromJson(json);
  }
}
