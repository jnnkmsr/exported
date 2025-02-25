import 'package:exported/src/builder/exported_option_keys.dart' as keys;
import 'package:exported/src/model_legacy/barrel_file.dart';
import 'package:exported/src/model_legacy/export.dart';
import 'package:exported/src/model_legacy/parser_helpers.dart';
import 'package:meta/meta.dart';

/// A set of tags for selectively including [Export]s in [BarrelFile]s.
extension type const Tags._(Set<Tag> _value) implements Object {
  @visibleForTesting
  factory Tags(Set<String> tags) => Tags._(tags.map(Tag._).toSet());

  /// Parses a set of tags from [input].
  ///
  /// Accepts either [String] or [Iterable] input, or a [Map] with a  `tags`
  /// key, sanitizing and converting the input to a set of tags.
  ///
  /// - Convert missing input (`null`) to [Tags.empty].
  /// - Trims whitespace and converts to lowercase.
  /// - Removes empty/blank tags and duplicates.
  ///
  /// Throws an [ArgumentError] for invalid non-string input types.
  factory Tags.parse(dynamic input) =>
      parseSet(input, keys.tags, Tags._, Tag.parse, () => Tags.empty);

  /// An empty set of tags.
  static const Tags empty = Tags._({});

  /// Whether this set of tags matches [other].
  ///
  /// Returns `true` if either set is empty or if they have any common tags.
  bool matches(Tags other) =>
      _value.isEmpty || other._value.isEmpty || _value.intersection(other._value).isNotEmpty;

  /// Merges this set of tags with [other].
  Tags merge(Tags other) => Tags._(_value.union(other._value));
}

/// A single tag within a [Tags] set.
@protected
extension type const Tag._(String _) implements Object {
  /// Parses a single tag from [input].
  ///
  /// - Converts [input] to a lowercase string and trims leading/trailing.
  /// - Returns `null` if [input] is `null` or an empty/blank string.
  ///
  /// Non-string input is silently converted by calling `toString()`.
  static Tag? parse(dynamic input) {
    if (input == null) return null;
    if (input is! String) {
      throw ArgumentError('Tags must be single');
    }
    final value = input.trim().toLowerCase();
    return value.isNotEmpty ? Tag._(value) : null;
  }
}
