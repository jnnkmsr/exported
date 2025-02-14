import 'package:exported/src/model/exported_option_keys.dart' as keys;
import 'package:exported/src/validation/tags_parser.dart';
import 'package:test/test.dart';

import '../helpers/input_parser_test_helpers.dart';

void main() {
  late TagsParser sut;

  setUp(() {
    sut = const TagsParser(keys.tags);
  });

  group('parse()', () {
    test('Leaves a valid set as-is', () {
      sut.expectParses(
        {'foo', 'bar'},
        {'foo', 'bar'},
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

    test('Converts to lower-case', () {
      sut.expectParses(
        {'FOO', 'Bar', 'baZ'},
        {'foo', 'bar', 'baz'},
      );
    });

    test('Removes duplicates after trimming and converting to lower-case', () {
      sut.expectParses(
        {'foo', '  foo', 'bar', 'Bar', 'baz', 'BAZ'},
        {'foo', 'bar', 'baz'},
      );
    });

    test('Remove empty or blank tags', () {
      sut.expectParses(
        {'foo', '', 'bar', '  '},
        {'foo', 'bar'},
      );
    });
  });

  group('parseJson()', () {
    test('Parses and sanitizes a JSON list', () {
      sut.expectParsesJson(['foo', 'Foo'], {'foo'});
    });

    test('Throws for an invalid JSON type', () {
      sut.expectThrowsJson('foo');
    });
  });
}
