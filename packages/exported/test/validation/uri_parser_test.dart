import 'package:exported/src/builder/exported_option_keys.dart' as keys;
import 'package:exported/src/validation/uri_parser.dart';
import 'package:test/test.dart';

import '../helpers/input_parser_test_helpers.dart';

void main() {
  late UriParser sut;

  setUp(() {
    sut = const UriParser(keys.uri);
  });

  group('parse()', () {
    test('Accepts fully-qualified URI', () {
      sut.expectParses(
        'package:foo/bar.dart',
        'package:foo/bar.dart',
      );
    });

    test('Accepts a URI with sub-directories', () {
      sut.expectParses(
        'package:foo/bar/baz/qux/quux.dart',
        'package:foo/bar/baz/qux/quux.dart',
      );
    });

    test("Adds missing 'package:' prefix", () {
      sut.expectParses(
        'foo/bar.dart',
        'package:foo/bar.dart',
      );
    });

    test("Adds missing '.dart' extension", () {
      sut.expectParses(
        'package:foo/bar',
        'package:foo/bar.dart',
      );
    });

    test('Converts package name to URI', () {
      sut.expectParses(
        'foo',
        'package:foo/foo.dart',
      );
    });

    test('Converts library file to URI', () {
      sut.expectParses(
        'foo_bar.dart',
        'package:foo_bar/foo_bar.dart',
      );
    });

    test('Trims leading and trailing whitespace', () {
      sut.expectParses(
        '  foo/bar   ',
        'package:foo/bar.dart',
      );
    });

    test('Normalizes path', () {
      sut.expectParses(
        'package:foo//./baz/../bar.dart',
        'package:foo/bar.dart',
      );
    });

    test('Throws for null, empty or blank input', () {
      sut.expectThrows(null);
      sut.expectThrows('');
      sut.expectThrows('   ');
    });

    test('Throws for an invalid package or file name', () {
      sut.expectThrows('Foo/bar.dart');
      sut.expectThrows('f!oo/bar.dart');
      sut.expectThrows('foo-bar/baz.dart');
      sut.expectThrows('foo bar/baz.dart');
      sut.expectThrows('foo/Bar.dart');
      sut.expectThrows('foo/b!ar.dart');
      sut.expectThrows('foo/bar baz.dart');
      sut.expectThrows('foo/bar-baz.dart');
    });

    test("Throws for a directory path with a trailing '/'", () {
      sut.expectThrows('foo/bar/');
    });

    test('Throws for an invalid file extension', () {
      sut.expectThrows('foo/bar.txt');
    });

    test('Throws for an invalid scheme', () {
      sut.expectThrows('http:foo/bar.dart');
    });
  });

  group('parseJson()', () {
    test('Parses and sanitizes a JSON string', () {
      sut.expectParsesJson('foo', 'package:foo/foo.dart');
    });

    test('Throws for an invalid JSON string', () {
      sut.expectThrowsJson('/foo');
    });

    test('Throws for an invalid JSON type', () {
      sut.expectThrowsJson(123);
    });
  });
}
