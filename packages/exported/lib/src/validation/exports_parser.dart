import 'package:exported/src/model/export.dart';
import 'package:exported/src/validation/input_parser.dart';

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

  @override
  Export elementFromJson(dynamic json) => Export.fromJson(json as Map);
}
