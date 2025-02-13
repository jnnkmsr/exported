import 'package:exported/src/validation/input_parser.dart';
import 'package:exported/src/validation/validation_util.dart';

/// Validates and sanitizes `show`/`hide` filter input.
///
/// - Converts `null` (no) input to an empty set.
/// - Trims whitespace and removes empty/blank or duplicate elements.
/// - Ensures all elements are valid public Dart identifiers (only letters,
///   numbers and underscores, and must not start with a number or underscore).
///
/// Any invalid input throws an [ArgumentError].
class ShowHideParser extends StringSetParser {
  const ShowHideParser(super.inputName);

  @override
  Set<String> parse([Set<String>? input]) =>
      input?.map((e) => e.trim()).where((identifier) {
        if (identifier.isEmpty) return false;
        if (!isPublicDartIdentifier(identifier)) {
          throwArgumentError(identifier, '"$identifier" is not a valid Dart identifier');
        }
        return true;
      }).toSet() ??
      {};
}
