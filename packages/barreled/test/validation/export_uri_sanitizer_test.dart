import 'package:barreled/src/validation/export_uri_sanitizer.dart';
import 'package:test/test.dart';

void main() {
  group('$ExportUriSanitizer', () {
    late ExportUriSanitizer sut;

    setUp(() {
      sut = const ExportUriSanitizer(inputName: 'package');
    });

    group('Valid input', () {
      void expectSanitized(String input, String expected) {
        expect(sut.sanitize(input), expected);
      }

      test('Accepts fully-qualified URI', () {
        expectSanitized(
          'package:foo/bar.dart',
          'package:foo/bar.dart',
        );
      });

      test('Accepts a URI with sub-directories', () {
        expectSanitized(
          'package:foo/bar/baz/qux/quux.dart',
          'package:foo/bar/baz/qux/quux.dart',
        );
      });

      test("Adds missing 'package:' prefix", () {
        expectSanitized(
          'foo/bar.dart',
          'package:foo/bar.dart',
        );
      });

      test("Adds missing '.dart' extension", () {
        expectSanitized(
          'package:foo/bar',
          'package:foo/bar.dart',
        );
      });

      test('Converts package name to URI', () {
        expectSanitized(
          'foo_bar',
          'package:foo_bar/foo_bar.dart',
        );
      });

      test('Converts library file to URI', () {
        expectSanitized(
          'foo_bar.dart',
          'package:foo_bar/foo_bar.dart',
        );
      });

      test('Trims leading and trailing whitespace', () {
        expectSanitized(
          '  foo/bar   ',
          'package:foo/bar.dart',
        );
      });

      test('Normalizes path', () {
        expectSanitized(
          'package:foo//./baz/../bar.dart',
          'package:foo/bar.dart',
        );
      });
    });

    group('Invalid input', () {
      void expectArgumentError(String? input) {
        expect(() => sut.sanitize(input), throwsArgumentError);
      }

      test('Throws for null, empty or blank input', () {
        expectArgumentError(null);
        expectArgumentError('');
        expectArgumentError('   ');
      });

      test('Throws for invalid package or file name', () {
        expectArgumentError('Foo/bar.dart');
        expectArgumentError('f!oo/bar.dart');
        expectArgumentError('foo-bar/baz.dart');
        expectArgumentError('foo bar/baz.dart');
        expectArgumentError('foo/Bar.dart');
        expectArgumentError('foo/b!ar.dart');
        expectArgumentError('foo/bar baz.dart');
        expectArgumentError('foo/bar-baz.dart');
      });

      test("Throws for directory path with a trailing '/'", () {
        expectArgumentError('foo/bar/');
      });

      test('Throws an invalid file extension', () {
        expectArgumentError('foo/bar.txt');
      });

      test('Throws for invalid scheme', () {
        expectArgumentError('http:foo/bar.dart');
      });
    });
  });
}
