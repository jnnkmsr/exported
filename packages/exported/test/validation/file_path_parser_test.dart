import 'package:exported/src/util/pubspec_reader.dart';
import 'package:exported/src/validation/file_path_parser.dart';
import 'package:test/test.dart';

import '../helpers/fake_pubspec_reader.dart';
import '../helpers/input_parser_test_helpers.dart';

void main() {
  late FilePathParser sut;

  const packageName = 'foo';

  setUp(() {
    PubspecReader.$instance = FakePubspecReader(name: packageName);
    sut = const FilePathParser('file');
  });

  group('parse()', () {
    test('Accepts a file name', () {
      sut.expectParses(
        'foo.dart',
        'foo.dart',
      );
    });

    test('Adds a .dart extension if not specified', () {
      sut.expectParses(
        'foo',
        'foo.dart',
      );
    });

    test('Accepts a relative directory prefix', () {
      sut.expectParses(
        'foo/bar/baz/qux',
        'foo/bar/baz/qux.dart',
      );
    });

    test('Returns the default file name for none or blank input', () {
      sut.expectParses(null, '$packageName.dart');
      sut.expectParses('', '$packageName.dart');
      sut.expectParses('   ', '$packageName.dart');
    });

    test('Appends the default file name if the input is a directory', () {
      sut.expectParses(
        'foo/bar/baz/',
        'foo/bar/baz/$packageName.dart',
      );
    });

    test('Removes a leading `lib/` if present', () {
      sut.expectParses(
        'lib/foo/bar/baz/qux.dart',
        'foo/bar/baz/qux.dart',
      );
    });

    test('Normalizes directory paths', () {
      sut.expectParses(
        './lib/foo/./bar//baz/../qux.dart',
        'foo/bar/qux.dart',
      );
    });

    test('Trims leading and trailing whitespace', () {
      sut.expectParses('   foo.dart   ', 'foo.dart');
      sut.expectParses('   foo/bar/baz.dart   ', 'foo/bar/baz.dart');
      sut.expectParses('   lib/foo/bar/baz.dart   ', 'foo/bar/baz.dart');
    });

    test('Allows snake-case for file and directory names', () {
      sut.expectParses(
        'foo_bar/baz1/_qux.dart',
        'foo_bar/baz1/_qux.dart',
      );
    });

    test("Throws for an extension other than '.dart'", () {
      sut.expectThrows('foo.txt');
    });

    test('Throws if the input is only an extension', () {
      sut.expectThrows('.dart');
    });

    test('Throws for an absolute path', () {
      sut.expectThrows('/foo.dart');
      sut.expectThrows('/foo/bar/baz.dart');
    });

    test('Throws for any non-snake-case file name or directory', () {
      sut.expectThrows('Foo.dart');
      sut.expectThrows('foo-bar.dart');
      sut.expectThrows('foo bar.dart');
      sut.expectThrows('f!oo.dart');
      sut.expectThrows('Foo/bar/baz.dart');
      sut.expectThrows('foo-bar/baz/qux.dart');
      sut.expectThrows('foo bar/baz/qux.dart');
      sut.expectThrows('foo/ bar/qux.dart');
      sut.expectThrows('f!oo/bar/baz.dart');
      sut.expectThrows('package:foo/bar/baz.dart');
    });
  });

  group('parseJson()', () {
    test('Parses and sanitizes a JSON string', () {
      sut.expectParsesJson('foo', 'foo.dart');
    });

    test('Throws for an invalid JSON string', () {
      sut.expectThrowsJson('/foo');
    });

    test('Throws for an invalid JSON type', () {
      sut.expectThrowsJson(123);
    });
  });
}
