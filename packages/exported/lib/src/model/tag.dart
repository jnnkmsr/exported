import 'package:exported/src/builder/exported_option_keys.dart' as keys;

typedef TagsFromJson = Tags Function(dynamic input);

extension type const Tags._(Set<Tag> _value) implements Set<Tag> {
  factory Tags.parse(dynamic input) {
    try {
      return switch (input) {
        null => Tags.none,
        Iterable _ => Tags._fromIterable(input.map(Tag.parse)),
        Map _ => Tags.parse(input[keys.tags]),
        _ => Tags.parse([input]),
      };
    } on ArgumentError catch (e) {
      throw ArgumentError.value(input, keys.tags, e.message);
    }
  }

  factory Tags._fromIterable(Iterable<Tag> input) {
    final tags = input.toSet()..remove(Tag.none);
    return tags.isEmpty ? Tags.none : Tags._(tags);
  }

  static const Tags none = Tags._({Tag.none});

  bool matches(Tag tag) => _value.contains(tag);
}

extension type const Tag(String _value) implements Object {
  factory Tag.fromJson(Map json) {
    final value = json[keys.tags] as String?;
    return value != null && value.isNotEmpty ? Tag(value) : Tag.none;
  }

  factory Tag.parse(dynamic input) {
    if (input is! String?) {
      throw ArgumentError('Tags must be string');
    }
    final value = input?.trim().toLowerCase();
    return value != null && value.isNotEmpty ? Tag(value) : Tag.none;
  }

  static const Tag none = Tag('');

  Map<String, dynamic> toJson() => {keys.tags: _value};
}
