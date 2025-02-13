import 'package:exported/src/validation/show_hide_parser.dart';
import 'package:test/test.dart';

import '../helpers/input_parser_test_helpers.dart';

void main() {
  late ShowHideParser sut;

  setUp(() {
    sut = const ShowHideParser('show');
  });

  group('parse()', () {
    test('Leaves a valid set as-is', () {
      sut.expectParses(
        {'foo', 'bar'},
        {'foo', 'bar'},
      );
    });

    test('Accepts valid Dart identifiers', () {
      sut.expectParses(
        {'foo', 'Bar', 'baz_qux', 'quux1', 'corge_2', 'GraultGarply_3_'},
        {'foo', 'Bar', 'baz_qux', 'quux1', 'corge_2', 'GraultGarply_3_'},
      );
    });

    test('Accepts an empty set', () {
      sut.expectParses({}, {});
    });

    test('Treats null as an empty set', () {
      sut.expectParses(null, {});
    });

    test('Trims leading and trailing whitespace', () {
      sut.expectParses(
        {'  foo', 'bar  ', '  baz  '},
        {'foo', 'bar', 'baz'},
      );
    });

    test('Removes duplicates', () {
      sut.expectParses(
        {'foo', '  foo', 'bar', 'bar  ', 'baz', '  baz  '},
        {'foo', 'bar', 'baz'},
      );
    });

    test('Remove empty or blank elements', () {
      sut.expectParses(
        {'foo', '', 'bar', '  '},
        {'foo', 'bar'},
      );
    });

    test('Throws for invalid identifiers', () {
      sut.expectThrows({'foo bar'});
      sut.expectThrows({'foo-bar'});
      sut.expectThrows({'1foo'});
      sut.expectThrows({'_foo'});
      sut.expectThrows({'foo!'});
      sut.expectThrows({'FooBar@'});
      sut.expectThrows({'foo/bar'});
    });
  });

  group('parseJson()', () {
    test('Parses and sanitizes a JSON list', () {
      sut.expectParsesJson(['foo', ' foo'], {'foo'});
    });

    test('Throws for a invalid JSON list elements', () {
      sut.expectThrowsJson(['foo bar']);
    });

    test('Throws for an invalid JSON type', () {
      sut.expectThrowsJson('foo');
    });
  });
}
