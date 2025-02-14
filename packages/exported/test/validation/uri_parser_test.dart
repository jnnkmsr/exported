import 'package:exported/src/model/exported_option_keys.dart' as keys;
import 'package:exported/src/validation/uri_parser.dart';
import 'package:test/test.dart';

import '../helpers/option_parser_test_helpers.dart';

void main() {
  late UriParser sut;

  setUp(() {
    sut = const UriParser(keys.uri);
  });

  group('parse()', () {
    test('Accepts fully-qualified URI', () {
      sut.expectParse(
        'package:foo/bar.dart',
        'package:foo/bar.dart',
      );
    });

    test('Accepts a URI with sub-directories', () {
      sut.expectParse(
        'package:foo/bar/baz/qux/quux.dart',
        'package:foo/bar/baz/qux/quux.dart',
      );
    });

    test("Adds missing 'package:' prefix", () {
      sut.expectParse(
        'foo/bar.dart',
        'package:foo/bar.dart',
      );
    });

    test("Adds missing '.dart' extension", () {
      sut.expectParse(
        'package:foo/bar',
        'package:foo/bar.dart',
      );
    });

    test('Converts package name to URI', () {
      sut.expectParse(
        'foo',
        'package:foo/foo.dart',
      );
    });

    test('Converts library file to URI', () {
      sut.expectParse(
        'foo_bar.dart',
        'package:foo_bar/foo_bar.dart',
      );
    });

    test('Trims leading and trailing whitespace', () {
      sut.expectParse(
        '  foo/bar   ',
        'package:foo/bar.dart',
      );
    });

    test('Normalizes path', () {
      sut.expectParse(
        'package:foo//./baz/../bar.dart',
        'package:foo/bar.dart',
      );
    });

    test('Throws for null, empty or blank input', () {
      sut.expectParseThrows(null);
      sut.expectParseThrows('');
      sut.expectParseThrows('   ');
    });

    test('Throws for an invalid package or file name', () {
      sut.expectParseThrows('Foo/bar.dart');
      sut.expectParseThrows('f!oo/bar.dart');
      sut.expectParseThrows('foo-bar/baz.dart');
      sut.expectParseThrows('foo bar/baz.dart');
      sut.expectParseThrows('foo/Bar.dart');
      sut.expectParseThrows('foo/b!ar.dart');
      sut.expectParseThrows('foo/bar baz.dart');
      sut.expectParseThrows('foo/bar-baz.dart');
    });

    test("Throws for a directory path with a trailing '/'", () {
      sut.expectParseThrows('foo/bar/');
    });

    test('Throws for an invalid file extension', () {
      sut.expectParseThrows('foo/bar.txt');
    });

    test('Throws for an invalid scheme', () {
      sut.expectParseThrows('http:foo/bar.dart');
    });
  });

  group('parseJson()', () {
    test('Parses and sanitizes a JSON string', () {
      sut.expectParseJson('foo', 'package:foo/foo.dart');
    });

    test('Throws for an invalid JSON string', () {
      sut.expectParseJsonThrows('/foo');
    });

    test('Throws for an invalid JSON type', () {
      sut.expectParseJsonThrows(123);
    });
  });
}
