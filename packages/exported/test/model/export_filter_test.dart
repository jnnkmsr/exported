import 'package:exported/src/builder/exported_option_keys.dart' as keys;
import 'package:exported/src/model/export_filter.dart';
import 'package:test/test.dart';

import '../helpers/expect.dart';

void main() {
  group('ExportFilter', () {
    group('.showElement()', () {
      test('Returns a show filter with a single combinator', () {
        expect(ExportFilter.showElement('foo'), ExportFilter.show(const {'foo'}));
      });
    });

    group('.fromInput() - show/hide input', () {
      void expectForShowAndHide(Set<String>? input, dynamic result) {
        if (result is ExportFilter) {
          expect(ExportFilter.fromInput(show: input), result);
          expect(ExportFilter.fromInput(hide: input), result);
        } else {
          result as Set<String>;
          expect(ExportFilter.fromInput(show: input), ExportFilter.show(result));
          expect(ExportFilter.fromInput(hide: input), ExportFilter.hide(result));
        }
      }

      void expectThrowsForShowAndHide(Set<String>? input) {
        expectArgumentError(() => ExportFilter.fromInput(show: input));
        expectArgumentError(() => ExportFilter.fromInput(hide: input));
      }

      test('Returns a show/hide filter for show/hide input', () {
        expectForShowAndHide(const {'foo', 'bar'}, const {'foo', 'bar'});
      });

      test('Returns a none filter for null or empty/blank input', () {
        expectForShowAndHide(null, ExportFilter.none);
        expectForShowAndHide(const <String>{}, ExportFilter.none);
        expectForShowAndHide(const {'', '   '}, ExportFilter.none);
      });

      test('Trims leading/trailing whitespace from all combinators', () {
        expectForShowAndHide(const {' foo ', ' bar '}, const {'foo', 'bar'});
      });

      test('Removes duplicates, ignoring leading/trailing whitespace', () {
        expectForShowAndHide(const {' foo ', 'foo'}, const {'foo'});
      });

      test('Is case-sensitive', () {
        expectForShowAndHide(const {'foo', 'Foo'}, const {'foo', 'Foo'});
      });

      test('Accepts all valid Dart identifiers', () {
        expectForShowAndHide(const {'a'}, const {'a'});
        expectForShowAndHide(const {'A'}, const {'A'});
        expectForShowAndHide(const {'foo'}, const {'foo'});
        expectForShowAndHide(const {'FooBar'}, const {'FooBar'});
        expectForShowAndHide(const {'foo123'}, const {'foo123'});
        expectForShowAndHide(const {'foo_bar'}, const {'foo_bar'});
        expectForShowAndHide(const {'foo__bar'}, const {'foo__bar'});
        expectForShowAndHide(const {r'$foo'}, const {r'$foo'});
        expectForShowAndHide(const {r'foo$bar'}, const {r'foo$bar'});
        expectForShowAndHide(const {'foo123_bar'}, const {'foo123_bar'});
      });

      test('Throws for invalid Dart identifiers', () {
        expectThrowsForShowAndHide(const {'_foo'});
        expectThrowsForShowAndHide(const {'1foo'});
        expectThrowsForShowAndHide(const {'foo bar'});
        expectThrowsForShowAndHide(const {'foo-bar'});
        expectThrowsForShowAndHide(const {'foo@bar'});
        expectThrowsForShowAndHide(const {'#foo'});
        expectThrowsForShowAndHide(const {'für'});
        expectThrowsForShowAndHide(const {'привет'});
        expectThrowsForShowAndHide(const {'こんにちは'});
      });

      test('Throws for non-null show and hide input', () {
        expectArgumentError(
          () => ExportFilter.fromInput(show: const {'foo'}, hide: const {'bar'}),
        );
        expectArgumentError(
          () => ExportFilter.fromInput(show: const <String>{}, hide: const <String>{}),
        );
      });
    });

    group('.fromInput() - options input', () {
      void expectForShowAndHide(dynamic input, dynamic result) {
        if (result is ExportFilter) {
          expect(ExportFilter.fromInput(show: input), result);
          expect(ExportFilter.fromInput(hide: input), result);
        } else {
          result as Set<String>;
          expect(ExportFilter.fromInput(show: input), ExportFilter.show(result));
          expect(ExportFilter.fromInput(hide: input), ExportFilter.hide(result));
        }
      }

      void expectThrows(dynamic input) {
        expectArgumentError(() => ExportFilter.fromInput(options: {keys.show: input}));
        expectArgumentError(() => ExportFilter.fromInput(options: {keys.hide: input}));
      }

      test('Returns a show/hide filter for show/hide input', () {
        expectForShowAndHide(const ['foo', 'bar'], const {'foo', 'bar'});
      });

      test('Accepts single-string input', () {
        expectForShowAndHide('foo', const {'foo'});
      });

      test('Returns a none filter for no show/hide keys or null/empty/blank input', () {
        expect(ExportFilter.fromInput(options: const {}), ExportFilter.none);
        expectForShowAndHide(null, ExportFilter.none);
        expectForShowAndHide(const <String>{}, ExportFilter.none);
        expectForShowAndHide(const {'', '   '}, ExportFilter.none);
      });

      test('Trims leading/trailing whitespace from all combinators', () {
        expectForShowAndHide(const [' foo ', ' bar '], const {'foo', 'bar'});
      });

      test('Removes duplicates, ignoring leading/trailing whitespace', () {
        expectForShowAndHide(const [' foo ', 'foo'], const {'foo'});
      });

      test('Is case-sensitive', () {
        expectForShowAndHide(const ['foo', 'Foo'], const {'foo', 'Foo'});
      });

      test('Accepts all valid Dart identifiers', () {
        expectForShowAndHide('a', const {'a'});
        expectForShowAndHide('A', const {'A'});
        expectForShowAndHide('foo', const {'foo'});
        expectForShowAndHide('FooBar', const {'FooBar'});
        expectForShowAndHide('foo123', const {'foo123'});
        expectForShowAndHide('foo_bar', const {'foo_bar'});
        expectForShowAndHide('foo__bar', const {'foo__bar'});
        expectForShowAndHide(r'$foo', const {r'$foo'});
        expectForShowAndHide(r'foo$bar', const {r'foo$bar'});
        expectForShowAndHide('foo123_bar', const {'foo123_bar'});
      });

      test('Throws for invalid Dart identifiers', () {
        expectThrows('_foo');
        expectThrows('1foo');
        expectThrows('foo bar');
        expectThrows('foo-bar');
        expectThrows('foo@bar');
        expectThrows('#foo');
        expectThrows('für');
        expectThrows('привет');
        expectThrows('こんにちは');
      });

      test('Throws for invalid types', () {
        expectThrows(123);
        expectThrows(true);
        expectThrows(const ['foo', 123]);
      });

      test('Throws for non-null show and hide input', () {
        expectArgumentError(
          () => ExportFilter.fromInput(
            options: const {
              keys.show: ['foo'],
              keys.hide: ['bar'],
            },
          ),
        );
        expectArgumentError(
          () => ExportFilter.fromInput(
            options: const {
              keys.show: <String>[],
              keys.hide: <String>[],
            },
          ),
        );
      });
    });

    group('.fromJson()', () {
      test('Returns a show filter when the input is a show list', () {
        expect(
          ExportFilter.fromJson(const {
            keys.show: ['foo', 'bar'],
          }),
          ExportFilter.show(const {'foo', 'bar'}),
        );
      });

      test('Returns a hide filter when the input is a hide list', () {
        expect(
          ExportFilter.fromJson(const {
            keys.hide: ['foo', 'bar'],
          }),
          ExportFilter.hide(const {'foo', 'bar'}),
        );
      });

      test('Returns a none filter when the input is an empty map', () {
        expect(ExportFilter.fromJson(const {}), ExportFilter.none);
      });
    });

    group('.toJson()', () {
      test('Returns a JSON representation of a show filter', () {
        expect(ExportFilter.show(const {'foo', 'bar'}).toJson(), {
          keys.show: ['foo', 'bar'],
        });
      });

      test('Returns a JSON representation of a hide filter', () {
        expect(ExportFilter.hide(const {'foo', 'bar'}).toJson(), {
          keys.hide: ['foo', 'bar'],
        });
      });

      test('Returns an empty map for a none filter', () {
        expect(ExportFilter.none.toJson(), isEmpty);
      });
    });

    group('.merge()', () {
      void expectMerge(ExportFilter a, ExportFilter b, ExportFilter result) {
        expect(a.merge(b), result);
        expect(b.merge(a), result);
      }

      test('Returns a none filter if either filter is none', () {
        expectMerge(ExportFilter.none, ExportFilter.show(const {'foo'}), ExportFilter.none);
        expectMerge(ExportFilter.none, ExportFilter.hide(const {'foo'}), ExportFilter.none);
        expectMerge(ExportFilter.none, ExportFilter.none, ExportFilter.none);
      });

      test('Combines the combinators of two show filters', () {
        expectMerge(
          ExportFilter.show(const {'foo', 'bar'}),
          ExportFilter.show(const {'bar', 'baz'}),
          ExportFilter.show(const {'foo', 'bar', 'baz'}),
        );
      });

      test('Keeps only the common combinators of two hide filter', () {
        expectMerge(
          ExportFilter.hide(const {'foo', 'bar'}),
          ExportFilter.hide(const {'bar', 'baz'}),
          ExportFilter.hide(const {'bar'}),
        );
      });

      test('Returns a none filter if two hide filters have no common combinators', () {
        expectMerge(
          ExportFilter.hide(const {'foo', 'bar'}),
          ExportFilter.hide(const {'baz'}),
          ExportFilter.none,
        );
      });

      test('Keeps only the non-conflicting combinators of a show and a hide filter', () {
        expectMerge(
          ExportFilter.show(const {'foo', 'bar'}),
          ExportFilter.hide(const {'bar', 'baz'}),
          ExportFilter.hide(const {'baz'}),
        );
      });

      test('Returns a none filter for a show and hide filter with the same combinators', () {
        expectMerge(
          ExportFilter.show(const {'foo', 'bar'}),
          ExportFilter.hide(const {'foo', 'bar'}),
          ExportFilter.none,
        );
      });

      test('Keeps only the entire hide filter if there are no conflicting show combinators', () {
        expectMerge(
          ExportFilter.show(const {'foo'}),
          ExportFilter.hide(const {'bar', 'baz'}),
          ExportFilter.hide(const {'bar', 'baz'}),
        );
      });
    });

    group('.==()', () {
      test('Returns true for equal-type filters with the same combinators', () {
        expect(
          ExportFilter.show(const {'foo', 'bar'}),
          equals(ExportFilter.show(const {'foo', 'bar'})),
        );
        expect(
          ExportFilter.hide(const {'foo', 'bar'}),
          equals(ExportFilter.hide(const {'foo', 'bar'})),
        );
        expect(ExportFilter.none, equals(ExportFilter.none));
      });

      test('Returns true for the same combinators with different order', () {
        expect(
          ExportFilter.show(const {'foo', 'bar'}),
          equals(ExportFilter.show(const {'bar', 'foo'})),
        );
        expect(
          ExportFilter.hide(const {'foo', 'bar'}),
          equals(ExportFilter.hide(const {'bar', 'foo'})),
        );
      });

      test('Returns false for equal-type filters with different combinators', () {
        expect(
          ExportFilter.show(const {'foo', 'bar'}),
          isNot(ExportFilter.show(const {'foo', 'baz'})),
        );
        expect(
          ExportFilter.hide(const {'foo', 'bar'}),
          isNot(ExportFilter.hide(const {'foo', 'baz'})),
        );
      });

      test('Returns false for a filters of different type', () {
        expect(
          ExportFilter.show(const {'foo', 'bar'}),
          isNot(ExportFilter.hide(const {'foo', 'bar'})),
        );
        expect(ExportFilter.show(const {'foo', 'bar'}), isNot(ExportFilter.none));
        expect(ExportFilter.hide(const {'foo', 'bar'}), isNot(ExportFilter.none));
      });
    });
  });
}
