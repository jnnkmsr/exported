import 'package:exported/src/builder/exported_option_keys.dart' as keys;
import 'package:exported/src/model/export_filter.dart';
import 'package:test/test.dart';

void main() {
  group('ExportFilter', () {
    group('.showElement()', () {
      test('Returns a show filter with a single combinator', () {
        expect(ExportFilter.showElement('foo'), ExportFilter.show(const {'foo'}));
      });
    });

    group('.fromInput()', () {
      void expectOutputForShowAndHide(Set<String>? input, dynamic result) {
        if (result is ExportFilter) {
          expect(ExportFilter.fromInput(show: input), result);
          expect(ExportFilter.fromInput(hide: input), result);
        } else {
          result as Set<String>;
          expect(ExportFilter.fromInput(show: input), ExportFilter.show(result));
          expect(ExportFilter.fromInput(hide: input), ExportFilter.hide(result));
        }
      }

      void expectThrowsForShowAndHide(Set<String>? input, [Set<String>? hide]) {
        if (hide != null) {
          expect(() => ExportFilter.fromInput(show: input, hide: hide), throwsArgumentError);
        } else {
          expect(() => ExportFilter.fromInput(show: input), throwsArgumentError);
          expect(() => ExportFilter.fromInput(hide: input), throwsArgumentError);
        }
      }

      void expectForOptions(dynamic input, dynamic result) {
        if (input is Map) {
          expect(ExportFilter.fromInput(options: input), result);
        } else if (result is ExportFilter) {
          expect(ExportFilter.fromInput(options: {keys.show: input}), result);
          expect(ExportFilter.fromInput(options: {keys.hide: input}), result);
        } else {
          result as Set<String>;
          expect(ExportFilter.fromInput(options: {keys.show: input}), ExportFilter.show(result));
          expect(ExportFilter.fromInput(options: {keys.hide: input}), ExportFilter.hide(result));
        }
      }

      void expectThrowsForOptions(dynamic input) {
        expect(() => ExportFilter.fromInput(options: {keys.show: input}), throwsArgumentError);
        expect(() => ExportFilter.fromInput(options: {keys.hide: input}), throwsArgumentError);
      }

      test('Returns a show/hide filter for show/hide input', () {
        expectOutputForShowAndHide(const {'foo', 'bar'}, const {'foo', 'bar'});
        expectForOptions(const ['foo', 'bar'], const {'foo', 'bar'});
      });

      test('Accepts single-string input for options', () {
        expectForOptions('foo', const {'foo'});
      });

      test('Returns a none filter for null or empty/blank input', () {
        expectOutputForShowAndHide(null, ExportFilter.none);
        expectOutputForShowAndHide(const <String>{}, ExportFilter.none);
        expectOutputForShowAndHide(const {'', '   '}, ExportFilter.none);

        expectForOptions(const <dynamic, dynamic>{}, ExportFilter.none);
        expectForOptions(null, ExportFilter.none);
        expectForOptions(const <String>{}, ExportFilter.none);
        expectForOptions(const {'', '   '}, ExportFilter.none);
      });

      test('Trims leading/trailing whitespace from all combinators', () {
        expectOutputForShowAndHide(const {' foo ', ' bar '}, const {'foo', 'bar'});
        expectForOptions(const [' foo ', ' bar '], const {'foo', 'bar'});
      });

      test('Removes duplicates, ignoring leading/trailing whitespace', () {
        expectOutputForShowAndHide(const {' foo ', 'foo'}, const {'foo'});
        expectForOptions(const [' foo ', 'foo'], const {'foo'});
      });

      test('Is case-sensitive', () {
        expectOutputForShowAndHide(const {'foo', 'Foo'}, const {'foo', 'Foo'});
        expectForOptions(const ['foo', 'Foo'], const {'foo', 'Foo'});
      });

      test('Accepts all valid Dart identifiers', () {
        expectOutputForShowAndHide(const {'a'}, const {'a'});
        expectOutputForShowAndHide(const {'A'}, const {'A'});
        expectOutputForShowAndHide(const {'foo'}, const {'foo'});
        expectOutputForShowAndHide(const {'FooBar'}, const {'FooBar'});
        expectOutputForShowAndHide(const {'foo123'}, const {'foo123'});
        expectOutputForShowAndHide(const {'foo_bar'}, const {'foo_bar'});
        expectOutputForShowAndHide(const {'foo__bar'}, const {'foo__bar'});
        expectOutputForShowAndHide(const {r'$foo'}, const {r'$foo'});
        expectOutputForShowAndHide(const {r'foo$bar'}, const {r'foo$bar'});
        expectOutputForShowAndHide(const {'foo123_bar'}, const {'foo123_bar'});

        expectForOptions('a', const {'a'});
        expectForOptions('A', const {'A'});
        expectForOptions('foo', const {'foo'});
        expectForOptions('FooBar', const {'FooBar'});
        expectForOptions('foo123', const {'foo123'});
        expectForOptions('foo_bar', const {'foo_bar'});
        expectForOptions('foo__bar', const {'foo__bar'});
        expectForOptions(r'$foo', const {r'$foo'});
        expectForOptions(r'foo$bar', const {r'foo$bar'});
        expectForOptions('foo123_bar', const {'foo123_bar'});
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

        expectThrowsForOptions('_foo');
        expectThrowsForOptions('1foo');
        expectThrowsForOptions('foo bar');
        expectThrowsForOptions('foo-bar');
        expectThrowsForOptions('foo@bar');
        expectThrowsForOptions('#foo');
        expectThrowsForOptions('für');
        expectThrowsForOptions('привет');
        expectThrowsForOptions('こんにちは');
      });

      test('Throws for invalid options types', () {
        expectThrowsForOptions(123);
        expectThrowsForOptions(true);
        expectThrowsForOptions(const ['foo', 123]);
      });

      test('Throws for non-null show and hide input', () {
        expectThrowsForShowAndHide(const {'foo'}, const {'bar'});
        expectThrowsForShowAndHide(const <String>{}, const <String>{});
        expectThrowsForOptions(const {
          keys.show: ['foo'],
          keys.hide: ['bar'],
        });
        expectThrowsForOptions(const {
          keys.show: <String>[],
          keys.hide: <String>[],
        });
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
