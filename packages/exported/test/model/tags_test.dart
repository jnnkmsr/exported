import 'package:exported/src/model/exported_option_keys.dart' as keys;
import 'package:exported/src/model/tags.dart';
import 'package:test/test.dart' hide Tags;

void main() {
  group('Tags', () {
    group('.()', () {
      test('Leaves a valid set as-is', () {
        expect(Tags.parse({'foo', 'bar'}), {'foo', 'bar'});
      });

      test('Trims leading and trailing whitespace', () {
        expect(Tags.parse({'  foo', 'bar  ', '  baz  '}), {'foo', 'bar', 'baz'});
      });

      test('Removes empty or blank tags', () {
        expect(Tags.parse({'foo', '', 'bar', '  '}), {'foo', 'bar'});
      });

      test('Converts tags to lowercase', () {
        expect(Tags.parse({'FOO', 'Bar', 'baZ'}), {'foo', 'bar', 'baz'});
      });

      test('Maps empty sets or null to the empty instance', () {
        expect(identical(Tags.parse(<String>{}), Tags.empty), isTrue);
        expect(identical(Tags.parse({' '}), Tags.empty), isTrue);
        expect(identical(Tags.parse(null), Tags.empty), isTrue);
      });

      test('Removes duplicates after trimming and converting to lowercase', () {
        expect(
          Tags.parse({'foo', '  foo', 'bar', 'Bar', 'baz', 'BAZ'}),
          {'foo', 'bar', 'baz'},
        );
      });

      test('Parses and sanitizes a single string', () {
        expect(Tags.parse('  FOO  '), {'foo'});
      });

      test('Parses and sanitizes and a JSON list', () {
        expect(Tags.parse(['foo', 'Foo', ' BAR ']), {'foo', 'bar'});
      });

      test('Parses and sanitizes the tags field from a JSON map', () {
        expect(
          Tags.parse({
            keys.uri: 'package:foo/foo.dart',
            keys.tags: '  FOO  ',
          }),
          {'foo'},
        );
        expect(
          Tags.parse({
            keys.uri: 'package:foo/foo.dart',
            keys.tags: ['foo', 'Foo', ' BAR '],
          }),
          {'foo', 'bar'},
        );
      });

      test('Throws for invalid input types', () {
        expect(() => Tags.parse(42), throwsArgumentError);
        expect(() => Tags.parse(['foo', 42]), throwsArgumentError);
        expect(() => Tags.parse({keys.tags: 42}), throwsArgumentError);
        expect(() => Tags.parse({keys.tags: ['foo', 42]}), throwsArgumentError);
      });
    });

    group('.empty', () {
      test('Returns an empty set', () {
        expect(Tags.empty, <String>{});
      });
    });

    group('.matches()', () {
      test('Returns true for two empty sets', () {
        expect(Tags.empty.matches(Tags.empty), isTrue);
      });

      test('Returns true for an empty set and a non-empty set', () {
        expect(Tags.empty.matches(Tags({'foo'})), isTrue);
        expect(Tags({'foo'}).matches(Tags.empty), isTrue);
      });

      test('Returns true for two sets with common tags', () {
        expect(Tags({'foo', 'bar'}).matches(Tags({'bar', 'baz'})), isTrue);
      });

      test('Returns false for two sets with no common tags', () {
        expect(Tags({'foo', 'bar'}).matches(Tags({'baz', 'qux'})), isFalse);
      });
    });

    group('.merge()', () {
      test('Merges two empty sets', () {
        expect(Tags.empty.merge(Tags.empty), Tags.empty);
      });

      test('Merges an empty set with a non-empty set', () {
        expect(Tags.empty.merge(Tags({'foo'})), {'foo'});
        expect(Tags({'foo'}).merge(Tags.empty), {'foo'});
      });

      test('Merges two sets with common tags', () {
        expect(
          Tags({'foo', 'bar'}).merge(Tags({'bar', 'baz'})),
          {'foo', 'bar', 'baz'},
        );
      });

      test('Merges two sets with no common tags', () {
        expect(
          Tags.parse({'foo', 'bar'}).merge(Tags.parse({'baz', 'qux'})),
          {'foo', 'bar', 'baz', 'qux'},
        );
      });
    });
  });
}
