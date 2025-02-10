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
class ShowHideSanitizer with InputValidator {
  const ShowHideSanitizer({required this.inputName});

  @override
  final String inputName;

  /// Validates the [input] and returns the sanitized set of identifiers.
  Set<String> sanitize(Set<String>? input, [Set<String>? other]) {
    final output = input?.map((tag) => tag.trim()).where((tag) {
        if (tag.isEmpty) return false;
        if (!isPublicDartIdentifier(tag)) {
          throwArgumentError(tag, 'Invalid $inputName element: $tag');
        }
        return true;
      }).toSet() ??
      {};
    if (output.isNotEmpty && (other?.isNotEmpty ?? false)) {
      throwArgumentError(inputName, 'Cannot have both `show` and `hide` filters');
    }

    return output;
  }
}
