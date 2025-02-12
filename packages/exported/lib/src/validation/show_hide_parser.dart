import 'package:exported/src/validation/input_parser.dart';
import 'package:exported/src/validation/validation_util.dart';

// TODO: Test show/hide conflict resolution.
// TODO: Document show/hide conflict resolution.

/// Sanitizes `show`/`hide` filter input based on the following rules:
/// - `null` is treated as an empty set.
/// - Leading and trailing whitespace will be trimmed from all elements.
/// - Empty or blank elements will be removed.
/// - Duplicate elements will be removed.
/// - All elements must be valid public Dart identifiers (only letters, numbers,
///   and underscores, and must not start with a number or underscore).
///
/// Throws an [ArgumentError] if any of the identifiers is not valid.
class ShowHideParser extends StringSetParser {
  const ShowHideParser(super.inputName);

  /// Validates the [input] and returns the sanitized set of identifiers.
  @override
  Set<String> parse([Set<String>? input]) =>
      input?.map((tag) => tag.trim()).where((tag) {
        if (tag.isEmpty) return false;
        if (!isPublicDartIdentifier(tag)) {
          throwArgumentError(tag, 'Invalid $inputName element: $tag');
        }
        return true;
      }).toSet() ??
      {};
}
