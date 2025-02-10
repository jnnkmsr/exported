/// Sanitizes barrel-file or export tag input based on the following rules:
/// - `null` is treated as an empty set.
/// - Leading and trailing whitespace will be trimmed from all tags.
/// - Empty or blank tags will be removed.
/// - Duplicate tags will be removed.
class TagsSanitizer {
  const TagsSanitizer();

  /// Validates the [input] and returns the sanitized set of tags.
  Set<String> sanitize(Set<String>? input) =>
      input?.map((tag) => tag.trim()).where((tag) => tag.isNotEmpty).toSet() ?? {};
}
