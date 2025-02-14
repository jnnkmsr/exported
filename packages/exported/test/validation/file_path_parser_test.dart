import 'package:exported/src/util/pubspec_reader.dart';
import 'package:exported/src/validation/file_path_parser.dart';
import 'package:test/test.dart';

import '../helpers/option_parser_test_helpers.dart';
import '../helpers/pubspec_reader_test_doubles.dart';

void main() {
  late FilePathParser sut;

  const packageName = 'foo';

  setUp(() {
    PubspecReader.$instance = FakePubspecReader(name: packageName);
    sut = const FilePathParser('file');
  });

  group('parse()', () {
    test('Accepts a file name', () {
      sut.expectParse(
        'foo.dart',
        'foo.dart',
      );
    });

    test('Adds a .dart extension if not specified', () {
      sut.expectParse(
        'foo',
        'foo.dart',
      );
    });

    test('Accepts a relative directory prefix', () {
      sut.expectParse(
        'foo/bar/baz/qux',
        'foo/bar/baz/qux.dart',
      );
    });

    test('Returns the default file name for none or blank input', () {
      sut.expectParse(null, '$packageName.dart');
      sut.expectParse('', '$packageName.dart');
      sut.expectParse('   ', '$packageName.dart');
    });

    test('Appends the default file name if the input is a directory', () {
      sut.expectParse(
        'foo/bar/baz/',
        'foo/bar/baz/$packageName.dart',
      );
    });

    test('Removes a leading `lib/` if present', () {
      sut.expectParse(
        'lib/foo/bar/baz/qux.dart',
        'foo/bar/baz/qux.dart',
      );
    });

    test('Normalizes directory paths', () {
      sut.expectParse(
        './lib/foo/./bar//baz/../qux.dart',
        'foo/bar/qux.dart',
      );
    });

    test('Trims leading and trailing whitespace', () {
      sut.expectParse('   foo.dart   ', 'foo.dart');
      sut.expectParse('   foo/bar/baz.dart   ', 'foo/bar/baz.dart');
      sut.expectParse('   lib/foo/bar/baz.dart   ', 'foo/bar/baz.dart');
    });

    test('Allows snake-case for file and directory names', () {
      sut.expectParse(
        'foo_bar/baz1/_qux.dart',
        'foo_bar/baz1/_qux.dart',
      );
    });

    test("Throws for an extension other than '.dart'", () {
      sut.expectParseThrows('foo.txt');
    });

    test('Throws if the input is only an extension', () {
      sut.expectParseThrows('.dart');
    });

    test('Throws for an absolute path', () {
      sut.expectParseThrows('/foo.dart');
      sut.expectParseThrows('/foo/bar/baz.dart');
    });

    test('Throws for any non-snake-case file name or directory', () {
      sut.expectParseThrows('Foo.dart');
      sut.expectParseThrows('foo-bar.dart');
      sut.expectParseThrows('foo bar.dart');
      sut.expectParseThrows('f!oo.dart');
      sut.expectParseThrows('Foo/bar/baz.dart');
      sut.expectParseThrows('foo-bar/baz/qux.dart');
      sut.expectParseThrows('foo bar/baz/qux.dart');
      sut.expectParseThrows('foo/ bar/qux.dart');
      sut.expectParseThrows('f!oo/bar/baz.dart');
      sut.expectParseThrows('package:foo/bar/baz.dart');
    });
  });

  group('parseJson()', () {
    test('Parses and sanitizes a JSON string', () {
      sut.expectParseJson('foo', 'foo.dart');
    });

    test('Throws for an invalid JSON string', () {
      sut.expectParseJsonThrows('/foo');
    });

    test('Throws for an invalid JSON type', () {
      sut.expectParseJsonThrows(123);
    });
  });
}
