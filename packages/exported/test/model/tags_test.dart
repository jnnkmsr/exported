import 'package:exported/src/model/tag.dart';
import 'package:test/test.dart' hide Tags;

void main() {
  group('Tag', () {
    group('.fromJson()', () {
      test('Converts a string to a Tag', () {
        expect(Tag.fromJson('foo'), 'foo'.asTag);
      });

      test('Returns Tag.none if input is null or empty', () {
        expect(Tag.fromJson(null), Tag.none);
        expect(Tag.fromJson(''), Tag.none);
      });
    });

    group('.matches()', () {
      test('Returns true if either tag is none', () {
        expect(Tag.none.matches('foo'.asTag), isTrue);
        expect('foo'.asTag.matches(Tag.none), isTrue);
      });

      test('Returns true if tags are equal', () {
        expect('foo'.asTag.matches('foo'.asTag), isTrue);
      });

      test('Returns false if tags are different', () {
        expect('foo'.asTag.matches('bar'.asTag), isFalse);
      });
    });
  });

  group('Tags', () {
    group('.fromInput()', () {
      test('Converts a string to a Tags set', () {
        expect(Tags.fromInput('foo'), {'foo'}.asTags);
      });

      test('Converts an iterable to a Tags set', () {
        expect(Tags.fromInput(['foo', 'bar']), {'foo', 'bar'}.asTags);
      });

      test('Converts a map to a Tags set', () {
        expect(
          Tags.fromInput({
            'tags': ['foo', 'bar'],
          }),
          {'foo', 'bar'}.asTags,
        );
      });

      test('Returns Tags.none if input is null or empty', () {
        expect(Tags.fromInput(null), Tags.none);
        expect(Tags.fromInput(''), Tags.none);
        expect(Tags.fromInput(const <String>[]), Tags.none);
        expect(Tags.fromInput(const {'tags': <dynamic>[]}), Tags.none);
      });

      test('Trims leading/trailing whitespace from all tags', () {
        expect(
          Tags.fromInput(['  foo', 'bar  ', '  baz  ']),
          {'foo', 'bar', 'baz'}.asTags,
        );
      });

      test('Converts all tags to lowercase', () {
        expect(Tags.fromInput(['Foo', 'BAR']), {'foo', 'bar'}.asTags);
      });

      test('Removes empty/blank tags and duplicates case-insensitively', () {
        expect(
          Tags.fromInput(['foo', '', 'bar', 'FOO', 'baz', '  ', 'Bar']),
          {'foo', 'bar', 'baz'}.asTags,
        );
        expect(Tags.fromInput(['', '   ']), Tags.none);
      });

      test('Throws an ArgumentError if input is not a string or iterable', () {
        expect(() => Tags.fromInput(42), throwsArgumentError);
      });

      test('Throws an ArgumentError if map value is not a string or iterable', () {
        expect(() => Tags.fromInput({'tags': 42}), throwsArgumentError);
      });
    });
  });
}
