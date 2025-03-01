import 'package:exported/src/model/exported_option_keys.dart' as keys;
import 'package:exported/src/model/option_collections.dart';
import 'package:fast_immutable_collections/fast_immutable_collections.dart';
import 'package:meta/meta.dart';

/// Represents a unique tag for selective inclusion of exports in barrel files.
extension type const Tag._(String _) implements String {
  /// Restores a [Tag] from internal [json] without any validation.
  factory Tag.fromJson(dynamic json) {
    final value = json as String?;
    return value != null && value.isNotEmpty ? Tag._(value) : Tag.none;
  }

  /// Helper for [Tags.fromInput] to parse a single [Tag] from [input].
  /// - Trims leading/trailing whitespace.
  /// - Converts [input] to a lowercase string.
  ///
  /// Returns `null` if [input] is an empty/blank string.
  ///
  /// Throws an [ArgumentError] if [input] is not a [String].
  static Tag? _fromInputOrNull(dynamic input) {
    if (input is! String) {
      throw ArgumentError('Must be string');
    }
    final value = input.trim().toLowerCase();
    return value.isNotEmpty ? Tag._(value) : null;
  }

  /// The default tag marking an export for inclusion in all barrel files or
  /// a barrel file for including all exports.
  static const Tag none = Tag._('');

  /// Whether this tag matches [other]. Returns `true` if either tag is [none]
  /// or if they are equal.
  bool matches(Tag other) => this == none || other == none || this == other;
}

/// A set of [Tag]s assigned to an export or barrel file.
///
/// Cannot be empty. The untagged state is represented by [Tags.none].
extension type const Tags._(StringOptionSet<Tag> _) implements StringOptionSet<Tag> {
  /// Creates a [Tags] set from builder or annotation options [input], which
  /// may be either a [String], [Iterable], or a [Map] containing a `tags` key.
  ///
  /// Input validation/sanitization:
  /// - Trims leading/trailing whitespace from all tags.
  /// - Converts all tags to lowercase.
  /// - Removes empty/blank tags and duplicates.
  ///
  /// Returns [Tags.none] if the input is `null` or the parsed set would be
  /// empty.
  ///
  /// Throws an [ArgumentError] if the [input] or [Map] value is not a [String]
  /// or an [Iterable] of [String].
  factory Tags.fromInput(dynamic input) {
    try {
      final setInput = input is Map ? input[keys.tags] : input;
      final tags = StringOptionSet.fromInput(setInput, Tag._fromInputOrNull);
      return tags != null ? Tags._(tags) : Tags.none;
    } on ArgumentError catch (e) {
      throw ArgumentError.value(input, keys.tags, e.message);
    }
  }

  /// Represents the untagged state, containing only [Tag.none].
  static const Tags none = Tags._(StringOptionSet(ISetConst({Tag.none})));

  /// Returns all elements from [tags] that match this set of tags based on
  /// [Tag.matches].
  Iterable<Tag> matching(Iterable<Tag> tags) =>
      this == none ? tags : where((tag) => tags.any(tag.matches));
}

extension TagsIterableExtension on Iterable<String> {
  /// Converts an [Iterable] of [String] to a [Tags] set.
  @visibleForTesting
  Tags toTags() => Tags._(StringOptionSet(map(Tag._).toISet()));
}
