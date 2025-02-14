import 'package:exported/src/validation/show_hide_parser.dart';
import 'package:test/test.dart';

import '../helpers/option_parser_test_helpers.dart';

void main() {
  late ShowHideParser sut;

  setUp(() {
    sut = const ShowHideParser('show');
  });

  group('parse()', () {
    test('Leaves a valid set as-is', () {
      sut.expectParse(
        {'foo', 'bar'},
        {'foo', 'bar'},
      );
    });

    test('Accepts valid Dart identifiers', () {
      sut.expectParse(
        {'foo', 'Bar', 'baz_qux', 'quux1', 'corge_2', 'GraultGarply_3_'},
        {'foo', 'Bar', 'baz_qux', 'quux1', 'corge_2', 'GraultGarply_3_'},
      );
    });

    test('Accepts an empty set', () {
      sut.expectParse({}, {});
    });

    test('Treats null as an empty set', () {
      sut.expectParse(null, {});
    });

    test('Trims leading and trailing whitespace', () {
      sut.expectParse(
        {'  foo', 'bar  ', '  baz  '},
        {'foo', 'bar', 'baz'},
      );
    });

    test('Removes duplicates', () {
      sut.expectParse(
        {'foo', '  foo', 'bar', 'bar  ', 'baz', '  baz  '},
        {'foo', 'bar', 'baz'},
      );
    });

    test('Remove empty or blank elements', () {
      sut.expectParse(
        {'foo', '', 'bar', '  '},
        {'foo', 'bar'},
      );
    });

    test('Throws for invalid identifiers', () {
      sut.expectParseThrows({'foo bar'});
      sut.expectParseThrows({'foo-bar'});
      sut.expectParseThrows({'1foo'});
      sut.expectParseThrows({'_foo'});
      sut.expectParseThrows({'foo!'});
      sut.expectParseThrows({'FooBar@'});
      sut.expectParseThrows({'foo/bar'});
    });
  });

  group('parseJson()', () {
    test('Parses and sanitizes a JSON list', () {
      sut.expectParseJson(['foo', ' foo'], {'foo'});
    });

    test('Throws for a invalid JSON list elements', () {
      sut.expectParseJsonThrows(['foo bar']);
    });

    test('Throws for an invalid JSON type', () {
      sut.expectParseJsonThrows('foo');
    });
  });
}
