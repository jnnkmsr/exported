import 'package:exported/src/model/exported_option_keys.dart' as keys;

extension type const Tags._(Set<Tag> _value) implements Object {
  factory Tags.parse(dynamic input) {
    try {
      if (input == null) return Tags.none;
      final tags = switch (input) {
        Map _ => Tags.parse(input[keys.tags]),
        Iterable _ => Tags._(input.map(Tag.parse).where((t) => t != Tag.none).toSet()),
        _ => Tags.parse([input]),
      };
      return tags._value.isEmpty ? Tags.none : tags;
    } on ArgumentError catch (e) {
      throw ArgumentError.value(input, keys.tags, e.message);
    }
  }


  static const Tags none = Tags._({Tag.none});

  bool matches(Tag tag) => _value.contains(tag);
}

extension type const Tag._(String _) implements Object {
  factory Tag.parse(dynamic input) {
    if (input is! String?) {
      throw ArgumentError('Tags must be string');
    }
    final value = input?.trim().toLowerCase();
    return value != null && value.isNotEmpty ? Tag._(value) : Tag.none;
  }

  static const Tag none = Tag._('');
}
