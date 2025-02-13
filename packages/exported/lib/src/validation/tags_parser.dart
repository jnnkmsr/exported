// TODO: Test and document lower-case conversion.

import 'package:exported/src/validation/input_parser.dart';

/// Validates and sanitizes barrel-file or export tag input.
///
/// - Converts `null` (no) input to an empty set.
/// - Converts all tags to lower-case for case-insensitive matching.
/// - Trims whitespace and removes empty/blank or duplicate elements.
///
/// Any invalid input throws an [ArgumentError].
class TagsParser extends StringSetParser {
  const TagsParser(super.inputName);

  @override
  Set<String> parse([Set<String>? input]) =>
      input?.map((tag) => tag.trim().toLowerCase()).where((tag) => tag.isNotEmpty).toSet() ?? {};
}
