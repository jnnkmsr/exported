import 'package:exported/src/builder/exported_option_keys.dart' as keys;
import 'package:source_gen/source_gen.dart';

typedef TagsFromJson = Tags Function(dynamic input);

extension type const Tags._(Set<Tag> _value) implements Set<Tag> {
  factory Tags.single(Tag tag) => tag == Tag.none ? Tags.none : Tags._({tag});

  factory Tags.fromAnnotation(ConstantReader annotation) =>
      Tags.parse(annotation.read(keys.tags).setValue.map((tag) => tag.toStringValue()));

  // ignore: avoid_unused_constructor_parameters
  factory Tags.fromCache(dynamic json) {
    // TODO: implement fromJson
    throw UnimplementedError();
  }

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

  Map<String, dynamic> toCache() => {
        keys.tags: _value.map((tag) => tag.toString()).toList(),
      };
}

extension type const Tag(String _) implements Object {
  factory Tag.parse(dynamic input) {
    if (input is! String?) {
      throw ArgumentError('Tags must be string');
    }
    final value = input?.trim().toLowerCase();
    return value != null && value.isNotEmpty ? Tag(value) : Tag.none;
  }

  static const Tag none = Tag('');
}
