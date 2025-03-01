import 'package:exported/src/_legacy/export.dart';
import 'package:exported/src/_legacy/option_parser.dart';

/// Validates and sanitizes a list of `exports` builder options.
///
/// - Removes duplicate exports by [Export.merge].
/// - Missing input (`null`) is treated as an empty list.
class ExportsParser extends ListOptionParser<Export> {
  const ExportsParser(super.inputName);

  /// Validates the [input] and returns the deduplicated list of exports.
  @override
  List<Export> parse([List<Export>? input]) {
    if (input == null) return [];

    final exportsByUri = <String, Export>{};
    for (final export in input) {
      exportsByUri.update(
        export.uri,
        (existingExport) => existingExport.merge(export),
        ifAbsent: () => export,
      );
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
