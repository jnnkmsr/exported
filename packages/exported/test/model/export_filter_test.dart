import 'package:exported/src/model/export_filter.dart';
import 'package:exported/src/model/exported_option_keys.dart' as keys;
import 'package:test/test.dart';

void main() {
  group('ExportFilter', () {
    group('.showSingle()', () {
      test('Returns a show filter with a single combinator', () {
        expect(ExportFilter.showSingle('foo'), {'foo'}.asShow);
      });
    });

    group('.fromInput()', () {
      void expectOutputForShowAndHide(Set<String>? input, dynamic result) {
        if (result is ExportFilter) {
          expect(ExportFilter.fromInput(show: input), result);
          expect(ExportFilter.fromInput(hide: input), result);
        } else {
          result as Set<String>;
          expect(ExportFilter.fromInput(show: input), result.asShow);
          expect(ExportFilter.fromInput(hide: input), result.asHide);
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
          expect(ExportFilter.fromInput(options: {keys.show: input}), result.asShow);
          expect(ExportFilter.fromInput(options: {keys.hide: input}), result.asHide);
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
          {'foo', 'bar'}.asShow,
        );
      });

      test('Returns a hide filter when the input is a hide list', () {
        expect(
          ExportFilter.fromJson(const {
            keys.hide: ['foo', 'bar'],
          }),
          {'foo', 'bar'}.asHide,
        );
      });

      test('Returns a none filter when the input is an empty map', () {
        expect(ExportFilter.fromJson(const {}), ExportFilter.none);
      });
    });

    group('.toJson()', () {
      test('Returns a JSON representation of a show filter', () {
        expect({'foo', 'bar'}.asShow.toJson(), {
          keys.show: ['foo', 'bar'],
        });
      });

      test('Returns a JSON representation of a hide filter', () {
        expect({'foo', 'bar'}.asHide.toJson(), {
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
        expectMerge(ExportFilter.none, {'foo'}.asShow, ExportFilter.none);
        expectMerge(ExportFilter.none, {'foo'}.asHide, ExportFilter.none);
        expectMerge(ExportFilter.none, ExportFilter.none, ExportFilter.none);
      });

      test('Combines the combinators of two show filters', () {
        expectMerge({'foo', 'bar'}.asShow, {'bar', 'baz'}.asShow, {'foo', 'bar', 'baz'}.asShow);
      });

      test('Keeps only the common combinators of two hide filter', () {
        expectMerge({'foo', 'bar'}.asHide, {'bar', 'baz'}.asHide, {'bar'}.asHide);
      });

      test('Returns a none filter if two hide filters have no common combinators', () {
        expectMerge({'foo', 'bar'}.asHide, {'baz'}.asHide, ExportFilter.none);
      });

      test('Keeps only the non-conflicting combinators of a show and a hide filter', () {
        expectMerge({'foo', 'bar'}.asShow, {'bar', 'baz'}.asHide, {'baz'}.asHide);
      });

      test('Returns a none filter for a show and hide filter with the same combinators', () {
        expectMerge({'foo', 'bar'}.asShow, {'foo', 'bar'}.asHide, ExportFilter.none);
      });

      test('Keeps only the entire hide filter if there are no conflicting show combinators', () {
        expectMerge({'foo'}.asShow, {'bar', 'baz'}.asHide, {'bar', 'baz'}.asHide);
      });
    });

    group('.==()', () {
      test('Returns true for equal-type filters with the same combinators', () {
        expect({'foo', 'bar'}.asShow, equals({'foo', 'bar'}.asShow));
        expect({'foo', 'bar'}.asHide, equals({'foo', 'bar'}.asHide));
        expect(ExportFilter.none, equals(ExportFilter.none));
      });

      test('Returns true for the same combinators with different order', () {
        expect({'foo', 'bar'}.asShow, equals({'bar', 'foo'}.asShow));
        expect({'foo', 'bar'}.asHide, equals({'bar', 'foo'}.asHide));
      });

      test('Returns false for equal-type filters with different combinators', () {
        expect({'foo', 'bar'}.asShow, isNot({'foo', 'baz'}.asShow));
        expect({'foo', 'bar'}.asHide, isNot({'foo', 'baz'}.asHide));
      });

      test('Returns false for a filters of different type', () {
        expect({'foo', 'bar'}.asShow, isNot({'foo', 'bar'}.asHide));
        expect({'foo', 'bar'}.asShow, isNot(ExportFilter.none));
        expect({'foo', 'bar'}.asHide, isNot(ExportFilter.none));
      });
    });
  });
}
