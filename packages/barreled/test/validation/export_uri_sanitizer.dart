import 'package:barreled/src/validation/export_uri_sanitizer.dart';
import 'package:test/test.dart';

void main() {
  group('$ExportUriSanitizer', () {
    late ExportUriSanitizer sut;

    setUp(() {
      sut = const ExportUriSanitizer(inputName: 'package');
    });

    group('Valid input', () {
      test('Accepts fully-qualified URI', () {
        expect(
          sut.sanitize('package:foo_bar/foo_bar.dart'),
          'package:foo_bar/foo_bar.dart',
        );
      });

      test('Accepts a URI with sub-directories', () {
        expect(
          sut.sanitize('package:foo/bar/baz/qux/quux.dart'),
          'package:foo/bar/baz/qux/quux.dart',
        );
      });

      test("Adds missing 'package:' prefix", () {
        expect(
          sut.sanitize('foo/bar.dart'),
          'package:foo/bar.dart',
        );
      });

      test("Adds missing '.dart' extension", () {
        expect(
          sut.sanitize('foo/bar'),
          'package:foo/bar.dart',
        );
      });

      test('Converts package name to URI', () {
        expect(
          sut.sanitize('foo_bar'),
          'package:foo_bar/foo_bar.dart',
        );
      });

      test('Trims leading and trailing whitespace', () {
        expect(
          sut.sanitize('  foo/bar   '),
          'package:foo/bar.dart',
        );
      });

      test('Normalizes path', () {
        expect(
          sut.sanitize('package:foo//./baz/../bar.dart'),
          'package:foo/bar.dart',
        );
      });
    });

    group('Invalid input', () {
      test('Throws for null, empty or blank input', () {
        expect(() => sut.sanitize(null), throwsArgumentError);
        expect(() => sut.sanitize(''), throwsArgumentError);
        expect(() => sut.sanitize('   '), throwsArgumentError);
      });

      test('Throws for invalid package name', () {
        expect(() => sut.sanitize('FoO/bar.dart'), throwsArgumentError);
        expect(() => sut.sanitize('f!oo/bar.dart'), throwsArgumentError);
      });

      test("Throws for directory path with a trailing '/'", () {
        expect(() => sut.sanitize('foo/bar/'), throwsArgumentError);
      });

      test("Throws for directory path with a trailing '/'", () {
        expect(() => sut.sanitize('foo/bar/'), throwsArgumentError);
      });

      test('Throws an invalid file extension', () {
        expect(() => sut.sanitize('foo/bar.txt'), throwsArgumentError);
      });

      test('Throws for invalid scheme', () {
        expect(() => sut.sanitize('http:foo/bar.dart'), throwsArgumentError);
      });
    });
  });
}
