import 'package:exported/src/util/pubspec_reader.dart';
import 'package:exported/src/validation/file_path_sanitizer.dart';
import 'package:mocktail/mocktail.dart';
import 'package:test/test.dart';

void main() {
  group('$FilePathSanitizer', () {
    late FilePathSanitizer sut;

    setUp(() {
      PubspecReader.$instance = FakePubspecReader();
      sut = FilePathSanitizer(inputName: 'file');
    });

    group('Valid input', () {
      void expectSanitized(String? input, String expected) {
        expect(sut.sanitize(input), expected);
      }

      test('Accepts a file name', () {
        expectSanitized(
          'foo.dart',
          'foo.dart',
        );
      });

      test('Adds a .dart extension if not specified', () {
        expectSanitized(
          'foo',
          'foo.dart',
        );
      });

      test('Accepts a relative directory prefix', () {
        expectSanitized(
          'foo/bar/baz/qux',
          'foo/bar/baz/qux.dart',
        );
      });

      test('Returns the default file name for none or blank input', () {
        expectSanitized(null, '$packageName.dart');
        expectSanitized('', '$packageName.dart');
        expectSanitized('   ', '$packageName.dart');
      });

      test('Appends the default file name if the input is a directory', () {
        expectSanitized(
          'foo/bar/baz/',
          'foo/bar/baz/$packageName.dart',
        );
      });

      test('Removes a leading `lib/` if present', () {
        expectSanitized(
          'lib/foo/bar/baz/qux.dart',
          'foo/bar/baz/qux.dart',
        );
      });

      test('Normalizes directory paths', () {
        expectSanitized(
          './lib/foo/./bar//baz/../qux.dart',
          'foo/bar/qux.dart',
        );
      });

      test('Trims leading and trailing whitespace', () {
        expectSanitized('   foo.dart   ', 'foo.dart');
        expectSanitized('   foo/bar/baz.dart   ', 'foo/bar/baz.dart');
        expectSanitized('   lib/foo/bar/baz.dart   ', 'foo/bar/baz.dart');
      });

      test('Allows snake-case for file and directory names', () {
        expectSanitized(
          'foo_bar/baz1/_qux.dart',
          'foo_bar/baz1/_qux.dart',
        );
      });
    });

    group('Invalid input', () {
      void expectArgumentError(String? input) {
        expect(() => sut.sanitize(input), throwsArgumentError);
      }

      test("Throws for an extension other than '.dart'", () {
        expectArgumentError('foo.txt');
      });

      test('Throws if the input is only an extension', () {
        expectArgumentError('.dart');
      });

      test('Throws for an absolute path', () {
        expectArgumentError('/foo.dart');
        expectArgumentError('/foo/bar/baz.dart');
      });

      test('Throws for any non-snake-case file name or directory', () {
        expectArgumentError('Foo.dart');
        expectArgumentError('foo-bar.dart');
        expectArgumentError('foo bar.dart');
        expectArgumentError('f!oo.dart');
        expectArgumentError('Foo/bar/baz.dart');
        expectArgumentError('foo-bar/baz/qux.dart');
        expectArgumentError('foo bar/baz/qux.dart');
        expectArgumentError('foo/ bar/qux.dart');
        expectArgumentError('f!oo/bar/baz.dart');
        expectArgumentError('package:foo/bar/baz.dart');
      });
    });
  });
}

class FakePubspecReader with Fake implements PubspecReader {
  @override
  String get name => packageName;
}

const packageName = 'foo';
