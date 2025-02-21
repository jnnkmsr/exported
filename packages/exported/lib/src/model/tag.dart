import 'package:exported/src/builder/exported_option_keys.dart' as keys;
import 'package:exported/src/model/non_empty_set.dart';
import 'package:fast_immutable_collections/fast_immutable_collections.dart';

extension type const Tag._(String _) implements String {
  factory Tag.fromJson(dynamic json) {
    final value = json as String?;
    return value != null && value.isNotEmpty ? Tag._(value) : Tag.none;
  }

  static Tag? _fromInputOrNull(dynamic input) {
    if (input is! String?) {
      throw ArgumentError.value(input, keys.tags, 'Tags must be string');
    }
    final value = input?.trim().toLowerCase();
    return value != null && value.isNotEmpty ? Tag._(value) : null;
  }

  static const Tag none = Tag._('');

  bool matches(Tag other) => this == none || other == none || this == other;
}

extension type const Tags._(NonEmptySet<Tag> _) implements NonEmptySet<Tag> {
  factory Tags.fromInput(dynamic input) {
    if (input is Map) {
      input = input[keys.tags];
    }
    final tags = NonEmptySet.fromInput(input, Tag._fromInputOrNull);
    return tags != null ? Tags._(tags) : Tags.none;
  }

  static const Tags none = Tags._(NonEmptySet.unsafe(ISetConst({Tag.none})));

  Iterable<Tag> matching(Iterable<Tag> tags) =>
      this == none ? tags : where((tag) => tags.any(tag.matches));
}
