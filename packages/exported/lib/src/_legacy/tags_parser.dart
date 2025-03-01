import 'package:exported/src/_legacy/option_parser.dart';

/// Validates and sanitizes barrel-file or export tag input.
///
/// - Converts missing input (`null`) to an empty set.
/// - Converts all tags to lower-case for case-insensitive matching.
/// - Trims whitespace and removes empty/blank or duplicate elements.
///
/// Any invalid input throws an [ArgumentError].
class TagsParser extends StringSetOptionParser {
  const TagsParser(super.inputName);

  @override
  Set<String> parse([Set<String>? input]) => input?.map(_parseTag).nonNulls.toSet() ?? {};

  /// Trims and converts the [input] to a lower-case tag. Returns `null` if
  /// empty or blank.
  String? _parseTag(String input) {
    final tag = input.trim().toLowerCase();
    return tag.isEmpty ? null : tag;
  }
}
