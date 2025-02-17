import 'package:exported/src/builder/exported_option_keys.dart' as keys;
import 'package:exported/src/model_legacy/export_filter.dart';
import 'package:test/test.dart';

void main() {
  group('Show/Hide', () {
    group('.()', () {
      test('Leaves a valid set as-is', () {
        expect(Show.parse({'foo', 'bar'}), {'foo', 'bar'});
        expect(Hide.parse({'foo', 'bar'}), {'foo', 'bar'});
      });

      test('Accepts valid names of public Dart elements', () {
        expect(
          Show.parse({'foo', 'Bar', 'baz_qux', 'quux1', 'corge_2', 'GraultGarply_3_'}),
          {'foo', 'Bar', 'baz_qux', 'quux1', 'corge_2', 'GraultGarply_3_'},
        );
        expect(
          Hide.parse({'foo', 'Bar', 'baz_qux', 'quux1', 'corge_2', 'GraultGarply_3_'}),
          {'foo', 'Bar', 'baz_qux', 'quux1', 'corge_2', 'GraultGarply_3_'},
        );
      });

      test('Trims leading and trailing whitespace', () {
        expect(Show.parse({'  foo', 'bar  ', '  baz  '}), {'foo', 'bar', 'baz'});
        expect(Hide.parse({'  foo', 'bar  ', '  baz  '}), {'foo', 'bar', 'baz'});
      });

      test('Remove empty or blank elements', () {
        expect(Show.parse({'foo', '', 'bar', '  '}), {'foo', 'bar'});
        expect(Hide.parse({'foo', '', 'bar', '  '}), {'foo', 'bar'});
      });

      test('Maps empty sets or null to the empty instance', () {
        expect(identical(Show.parse(<String>{}), Show.empty), isTrue);
        expect(identical(Hide.parse(<String>{}), Hide.empty), isTrue);
        expect(identical(Show.parse({' '}), Show.empty), isTrue);
        expect(identical(Hide.parse({' '}), Hide.empty), isTrue);
        expect(identical(Show.parse(null), Show.empty), isTrue);
        expect(identical(Hide.parse(null), Hide.empty), isTrue);
      });

      test('Removes duplicates after trimming', () {
        expect(
          Show.parse({'foo', '  foo', 'bar', 'bar  ', 'baz', '  baz  '}),
          {'foo', 'bar', 'baz'},
        );
        expect(
          Hide.parse({'foo', '  foo', 'bar', 'bar  ', 'baz', '  baz  '}),
          {'foo', 'bar', 'baz'},
        );
      });

      test('Is case-insensitive', () {
        expect(Show.parse({'FOO', 'foo', 'Bar', 'baZ'}), {'FOO', 'foo', 'Bar', 'baZ'});
        expect(Hide.parse({'FOO', 'foo', 'Bar', 'baZ'}), {'FOO', 'foo', 'Bar', 'baZ'});
      });

      test('Parses and sanitizes a single string', () {
        expect(Show.parse('  Foo  '), {'Foo'});
        expect(Hide.parse('  Foo  '), {'Foo'});
      });

      test('Parses and sanitizes and a JSON list', () {
        expect(Show.parse(['foo', ' foo ', ' Bar ']), {'foo', 'Bar'});
        expect(Hide.parse(['foo', ' foo ', ' Bar ']), {'foo', 'Bar'});
      });

      test('Parses and sanitizes the tags field from a JSON map', () {
        const foo = {
          keys.uri: 'package:foo/foo.dart',
          keys.hide: '  Foo  ',
          keys.show: '  Foo  ',
        };
        expect(Show.parse(foo), {'Foo'});
        expect(Hide.parse(foo), {'Foo'});

        const fooBar = {
          keys.uri: 'package:foo/foo.dart',
          keys.hide: ['foo', 'Foo', ' Bar '],
          keys.show: ['foo', 'Foo', ' Bar '],
        };
        expect(Show.parse(fooBar), {'foo', 'Foo', 'Bar'});
        expect(Hide.parse(fooBar), {'foo', 'Foo', 'Bar'});
      });

      test('Throws for invalid element names', () {
        expect(() => Show.parse({'foo bar'}), throwsArgumentError);
        expect(() => Hide.parse({'foo bar'}), throwsArgumentError);
        expect(() => Show.parse({'foo-bar'}), throwsArgumentError);
        expect(() => Hide.parse({'foo-bar'}), throwsArgumentError);
        expect(() => Show.parse({'1foo'}), throwsArgumentError);
        expect(() => Hide.parse({'1foo'}), throwsArgumentError);
        expect(() => Show.parse({'_foo'}), throwsArgumentError);
        expect(() => Hide.parse({'_foo'}), throwsArgumentError);
        expect(() => Show.parse({'foo!'}), throwsArgumentError);
        expect(() => Hide.parse({'foo!'}), throwsArgumentError);
        expect(() => Show.parse({'FooBar@'}), throwsArgumentError);
        expect(() => Hide.parse({'FooBar@'}), throwsArgumentError);
        expect(() => Show.parse({'foo/bar'}), throwsArgumentError);
        expect(() => Hide.parse({'foo/bar'}), throwsArgumentError);
      });

      test('Throws for invalid input types', () {
        expect(() => Show.parse(42), throwsArgumentError);
        expect(() => Hide.parse(42), throwsArgumentError);
        expect(() => Show.parse(['foo', 42]), throwsArgumentError);
        expect(() => Hide.parse(['foo', 42]), throwsArgumentError);
        expect(() => Show.parse({keys.show: 42}), throwsArgumentError);
        expect(() => Hide.parse({keys.hide: 42}), throwsArgumentError);
        expect(
            () => Show.parse({
                  keys.show: ['foo', 42]
                }),
            throwsArgumentError);
        expect(
            () => Hide.parse({
                  keys.hide: ['foo', 42]
                }),
            throwsArgumentError);
      });
    });

    group('.names', () {
      test('Returns a sorted list of names', () {
        expect(Show({'foo', 'bar', 'baz'}).names, ['bar', 'baz', 'foo']);
        expect(Hide({'foo', 'bar', 'baz'}).names, ['bar', 'baz', 'foo']);
      });

      test('Returns an empty list for an empty set', () {
        expect(Show.empty.names, <String>[]);
        expect(Hide.empty.names, <String>[]);
      });
    });

    group('.isEmpty', () {
      test('Returns true for an empty set', () {
        expect(Show.empty.isEmpty, isTrue);
        expect(Hide.empty.isEmpty, isTrue);
      });

      test('Returns false for a non-empty set', () {
        expect(Show({'foo'}).isEmpty, isFalse);
        expect(Hide({'foo'}).isEmpty, isFalse);
      });
    });

    group('.merge', () {
      test('Merges empty sets', () {
        expect(Show.empty.merge(Show.empty, Hide.empty), Show.empty);
        expect(Hide.empty.merge(Show.empty, Hide.empty), Hide.empty);
      });

      test('Clears Show and Hide when other has empty filters', () {
        expect(Show({'foo', 'bar'}).merge(Show.empty, Hide.empty), Show.empty);
        expect(Hide({'foo', 'bar'}).merge(Show.empty, Hide.empty), Hide.empty);
      });

      test('Clears Show when other has empty or Hide filters', () {
        expect(Show({'foo', 'bar'}).merge(Show.empty, Hide({'bar', 'baz'})), Show.empty);
        expect(Show.empty.merge(Show({'bar', 'baz'}), Hide.empty), Show.empty);
      });

      test('Merges Show when both have Show filters', () {
        expect(
          Show({'foo', 'bar'}).merge(Show({'bar', 'baz'}), Hide.empty),
          Show({'foo', 'bar', 'baz'}),
        );
      });

      test('Keeps Hide when other has only non-conflicting Show filters', () {
        expect(
          Hide({'foo', 'bar'}).merge(Show({'baz'}), Hide.empty),
          Hide({'foo', 'bar'}),
        );
      });

      test('Removes conflicting Show filters from Hide', () {
        expect(
          Hide({'foo', 'bar'}).merge(Show({'bar', 'baz'}), Hide.empty),
          Hide({'foo'}),
        );
      });
    });
  });
}
