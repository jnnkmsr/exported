// TODO: Test and document lower-case conversion.

import 'package:exported/src/validation/input_sanitizer.dart';

/// Sanitizes barrel-file or export tag input based on the following rules:
/// - `null` is treated as an empty set.
/// - Leading and trailing whitespace will be trimmed from all tags.
/// - Empty or blank tags will be removed.
/// - Duplicate tags will be removed.
class TagsSanitizer extends InputSanitizer<Set<String>?, Set<String>> {
  const TagsSanitizer(super.inputName);

  /// Validates the [input] and returns the sanitized set of tags.
  @override
  Set<String> sanitize(Set<String>? input) =>
      input?.map((tag) => tag.trim().toLowerCase()).where((tag) => tag.isNotEmpty).toSet() ?? {};
}
