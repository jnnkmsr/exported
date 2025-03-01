import 'package:exported/src/model/barrel_file_path.dart';
import 'package:exported/src/model/exported_option_keys.dart' as keys;
import 'package:test/test.dart';

import '../util/fake_pubspec_reader.dart';

void main() {
  group('BarrelFilePath', () {
    group('.packageNamed()', () {
      test('Returns the default file name read from pubspec.yaml', () {
        final pubspecReader = FakePubspecReader(name: 'foo');
        expect(
          BarrelFilePath.packageNamed(pubspecReader),
          'foo.dart',
        );
      });
    });

    group('.fromInput()', () {
      const package = 'foo';

      void expectOutput(dynamic input, String expected) {
        final pubspecReader = FakePubspecReader(name: package);
        expect(BarrelFilePath.fromInput(input, pubspecReader), expected);
        expect(BarrelFilePath.fromInput({keys.path: input}, pubspecReader), expected);
      }

      void expectThrows(dynamic input) {
        final pubspecReader = FakePubspecReader(name: package);
        expect(() => BarrelFilePath.fromInput(input, pubspecReader), throwsArgumentError);
        expect(() => BarrelFilePath.fromInput({keys.path: input}, pubspecReader), throwsArgumentError);
      }

      test('Parses a valid file name with extension', () {
        expectOutput('foo.dart', 'foo.dart');
      });

      test('Adds a .dart extension if not specified', () {
        expectOutput('foo', 'foo.dart');
      });

      test('Parses a valid file path with directory', () {
        expectOutput('foo/bar.dart', 'foo/bar.dart');
        expectOutput('foo/bar', 'foo/bar.dart');
      });

      test('Returns the default file name for none or blank input', () {
        expectOutput(null, '$package.dart');
        expectOutput('', '$package.dart');
        expectOutput('   ', '$package.dart');
      });

      test('Adds the default file name if the input is a directory', () {
        expectOutput('foo/', 'foo/$package.dart');
      });

      test("Removes a leading 'lib/' directory", () {
        expectOutput('lib/foo/bar.dart', 'foo/bar.dart');
        expectOutput('lib/foo/bar', 'foo/bar.dart');
        expectOutput('lib/foo/', 'foo/$package.dart');
      });

      test('Normalizes directory paths', () {
        expectOutput('./lib/foo/./bar//baz/../qux.dart', 'foo/bar/qux.dart');
        expectOutput('./lib/foo/./bar//baz/../', 'foo/bar/$package.dart');
      });

      test('Trims leading and trailing whitespace', () {
        expectOutput('  foo  ', 'foo.dart');
        expectOutput('  foo/bar  ', 'foo/bar.dart');
        expectOutput('  lib/foo/bar  ', 'foo/bar.dart');
      });

      test('Allows snake-case for file and directory names', () {
        expectOutput('foo_bar/baz1/_qux.dart', 'foo_bar/baz1/_qux.dart');
      });

      test('Throws for invalid input types', () {
        expectThrows(42);
      });

      test('Throws for an absolute path', () {
        expectThrows('/foo.dart');
        expectThrows('/foo/bar.dart');
      });

      test("Throws for a file extension other than '.dart'", () {
        expectThrows('foo.txt');
        expectThrows('foo/bar.txt');
      });

      test('Throws non-snake-case paths', () {
        expectThrows('1foo');
        expectThrows('Foo');
        expectThrows('foo bar');
        expectThrows('foo-bar');
        expectThrows('foo#');
        expectThrows('foo:bar/foo.dart');
        expectThrows('foo.bar/foo.dart');
      });
    });

    group('.fromJson()', () {
      test('Parses a JSON object', () {
        expect(
          BarrelFilePath.fromJson({keys.path: 'foo.dart'}),
          'foo.dart',
        );
      });
    });

    group('.toJson()', () {
      test('Converts to a JSON object', () {
        expect(
          'foo.dart'.asBarrelFilePath.toJson(),
          {keys.path: 'foo.dart'},
        );
      });
    });
  });
}
