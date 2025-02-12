import 'package:exported/src/builder/exported_option_keys.dart' as keys;
import 'package:exported/src/validation/tags_sanitizer.dart';
import 'package:test/test.dart';

void main() {
  group('$TagsSanitizer', () {
    late TagsSanitizer sut;

    setUp(() {
      sut = const TagsSanitizer(keys.tags);
    });

    void expectSanitized(Set<String>? input, Set<String> expected) =>
        expect(sut.sanitize(input), expected);

    test('Leaves a valid set as-is', () {
      expectSanitized(
        {'foo', 'bar'},
        {'foo', 'bar'},
      );
    });

    test('Accepts an empty set', () {
      expectSanitized(
        {},
        {},
      );
    });

    test('Treats null as an empty set', () {
      expectSanitized(
        null,
        {},
      );
    });

    test('Trims leading and trailing whitespace', () {
      expectSanitized(
        {'  foo', 'bar  ', '  baz  '},
        {'foo', 'bar', 'baz'},
      );
    });

    test('Removes duplicates', () {
      expectSanitized(
        {'foo', '  foo', 'bar', 'bar  ', 'baz', '  baz  '},
        {'foo', 'bar', 'baz'},
      );
    });

    test('Remove empty or blank tags', () {
      expectSanitized(
        {'foo', '', 'bar', '  '},
        {'foo', 'bar'},
      );
    });
  });
}
