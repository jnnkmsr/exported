import 'package:exported/src/model/export_uri.dart';
import 'package:exported/src/model/exported_option_keys.dart' as keys;
import 'package:test/test.dart';

void main() {
  group('ExportUri', () {
    group('.fromInput()', () {
      const package = 'foo';

      void expectOutput(dynamic input, String expected) {
        expect(
          ExportUri.fromInput(input, package: package),
          expected,
        );
        expect(
          ExportUri.fromInput({keys.uri: input}, package: package),
          expected,
        );
      }

      void expectThrows(dynamic input) {
        expect(
          () => ExportUri.fromInput(input, package: package),
          throwsArgumentError,
        );
        expect(
          () => ExportUri.fromInput({keys.uri: input}, package: package),
          throwsArgumentError,
        );
      }

      test("Parses a valid 'dart:' URI", () {
        expectOutput('dart:core', 'dart:core');
      });

      test("Parses a valid 'package:' path URI", () {
        expectOutput('package:foo/src/bar/foo.dart', 'package:foo/src/bar/foo.dart');
      });

      test("Adds a 'package:' prefix to a path", () {
        expectOutput('foo/src/bar/foo.dart', 'package:foo/src/bar/foo.dart');
      });

      test("Adds a '.dart' extension", () {
        expectOutput('foo/src/bar/foo', 'package:foo/src/bar/foo.dart');
      });

      test("Converts a package or file name to a 'package:' URI", () {
        expectOutput('foo', 'package:foo/foo.dart');
        expectOutput('package:foo', 'package:foo/foo.dart');
        expectOutput('foo.dart', 'package:foo/foo.dart');
        expectOutput('package:foo.dart', 'package:foo/foo.dart');
      });

      test("Converts a 'lib/' path to a 'package:' URI", () {
        expectOutput('lib/src/foo.dart', 'package:$package/src/foo.dart');
      });

      test('Trims leading/trailing whitespace', () {
        expectOutput('   foo   ', 'package:foo/foo.dart');
      });

      test('Normalizes the path', () {
        expectOutput('foo//./baz/../bar.dart', 'package:foo/bar.dart');
      });

      test('Accepts valid snake-case pattern', () {
        expectOutput('foo1', 'package:foo1/foo1.dart');
        expectOutput('foo_bar', 'package:foo_bar/foo_bar.dart');
      });

      test('Throws for null input', () {
        expectThrows(null);
      });

      test('Throws for empty/blank input', () {
        expectThrows('');
        expectThrows('   ');
      });

      test('Throws for invalid input types', () {
        expectThrows(42);
      });

      test('Throws for an absolute path', () {
        expectThrows('/foo.dart');
        expectThrows('/foo/bar.dart');
        expectThrows('package:/foo/bar.dart');
      });

      test("Throws for a file extension other than '.dart'", () {
        expectThrows('foo.txt');
        expectThrows('foo/bar.txt');
        expectThrows('package:foo/bar.txt');
      });

      test("Throws for a 'dart:' library that is not a single library name", () {
        expectThrows('dart:foo/foo');
        expectThrows('dart:foo.dart');
      });

      test('Throws non-snake-case paths', () {
        expectThrows('1foo');
        expectThrows('Foo');
        expectThrows('foo bar');
        expectThrows('foo-bar');
        expectThrows('foo#');
        expectThrows('package:foo:bar/foo.dart');
        expectThrows('foo.bar/foo.dart');
      });

      test('Throws and invalid scheme', () {
        expectThrows('file:foo/foo');
      });

      test('Throws for an empty path', () {
        expectThrows('package:');
      });
    });

    group('.fromJson()', () {
      test('Parses a JSON object', () {
        expect(
          ExportUri.fromJson({keys.uri: 'package:foo/foo.dart'}),
          'package:foo/foo.dart',
        );
      });
    });

    group('.toJson()', () {
      test('Converts to a JSON object', () {
        expect(
          'package:foo/foo.dart'.asExportUri.toJson(),
          {keys.uri: 'package:foo/foo.dart'},
        );
      });
    });
  });
}
