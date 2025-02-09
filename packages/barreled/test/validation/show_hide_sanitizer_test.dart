import 'package:barreled/src/validation/show_hide_sanitizer.dart';
import 'package:test/test.dart';

void main() {
  group('$ShowHideSanitizer', () {
    late ShowHideSanitizer sut;

    setUp(() {
      sut = const ShowHideSanitizer(inputName: 'show');
    });

    group('Valid input', () {
      void expectSanitized(Set<String>? input, Set<String> expected) =>
          expect(sut.sanitize(input), expected);

      test('Leaves a valid set as-is', () {
        expectSanitized(
          {'foo', 'bar'},
          {'foo', 'bar'},
        );
      });

      test('Accepts valid Dart identifiers', () {
        expectSanitized(
          {'foo', 'Bar', 'baz_qux', 'quux1', 'corge_2', 'GraultGarply_3_'},
          {'foo', 'Bar', 'baz_qux', 'quux1', 'corge_2', 'GraultGarply_3_'},
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

      test('Remove empty or blank elements', () {
        expectSanitized(
          {'foo', '', 'bar', '  '},
          {'foo', 'bar'},
        );
      });
    });

    group('Invalid input', () {
      void expectArgumentError(Set<String> input) {
        expect(() => sut.sanitize(input), throwsArgumentError);
      }

      test('Throws for invalid identifiers', () {
        expectArgumentError({'foo bar'});
        expectArgumentError({'foo-bar'});
        expectArgumentError({'1foo'});
        expectArgumentError({'_foo'});
        expectArgumentError({'foo!'});
        expectArgumentError({'FooBar@'});
        expectArgumentError({'foo/bar'});
      });
    });
  });
}
