import 'package:exported/src/model/exported_option_keys.dart' as keys;
import 'package:exported/src/validation/tags_parser.dart';
import 'package:test/test.dart';

import '../helpers/option_parser_helpers.dart';

void main() {
  late TagsParser sut;

  setUp(() {
    sut = const TagsParser(keys.tags);
  });

  group('parse()', () {
    test('Leaves a valid set as-is', () {
      sut.expectParse(
        {'foo', 'bar'},
        {'foo', 'bar'},
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

    test('Converts to lower-case', () {
      sut.expectParse(
        {'FOO', 'Bar', 'baZ'},
        {'foo', 'bar', 'baz'},
      );
    });

    test('Removes duplicates after trimming and converting to lower-case', () {
      sut.expectParse(
        {'foo', '  foo', 'bar', 'Bar', 'baz', 'BAZ'},
        {'foo', 'bar', 'baz'},
      );
    });

    test('Remove empty or blank tags', () {
      sut.expectParse(
        {'foo', '', 'bar', '  '},
        {'foo', 'bar'},
      );
    });
  });

  group('parseJson()', () {
    test('Parses and sanitizes a JSON list', () {
      sut.expectParseJson(['foo', 'Foo'], {'foo'});
    });

    test('Throws for an invalid JSON type', () {
      sut.expectParseJsonThrows('foo');
    });
  });
}
