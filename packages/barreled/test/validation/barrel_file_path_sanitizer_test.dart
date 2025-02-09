import 'package:barreled/src/util/pubspec_reader.dart';
import 'package:barreled/src/validation/barrel_file_path_sanitizer.dart';
import 'package:mocktail/mocktail.dart';
import 'package:test/test.dart';

void main() {
  group('$BarrelFilePathSanitizer', () {
    late BarrelFilePathSanitizer sut;

    setUp(() {
      PubspecReader.$instance = FakePubspecReader();
      sut = BarrelFilePathSanitizer(
        fileInputName: 'file',
        dirInputName: 'dir',
      );
    });

    group('Valid input', () {
      void expectSanitized({
        String? fileInput,
        String? dirInput,
        String? expectedFile,
        String? expectedDir,
      }) {
        final result = sut.sanitize(fileInput: fileInput, dirInput: dirInput);
        if (expectedFile != null) expect(result.file, expectedFile);
        if (expectedDir != null) expect(result.dir, expectedDir);
      }

      test('Accepts a file name', () {
        expectSanitized(
          fileInput: 'foo_bar.dart',
          expectedFile: 'foo_bar.dart',
        );
      });

      test('Adds a .dart extension if not specified', () {
        expectSanitized(
          fileInput: 'foo_bar',
          expectedFile: 'foo_bar.dart',
        );
      });

      test('Accepts a relative directory', () {
        expectSanitized(
          dirInput: 'lib/foo',
          expectedDir: 'lib/foo',
        );
      });

      test('Trims leading and trailing whitespace', () {
        expectSanitized(
          fileInput: '   foo_bar.dart   ',
          dirInput: '   lib/foo   ',
          expectedFile: 'foo_bar.dart',
          expectedDir: 'lib/foo',
        );
      });

      test('Returns default values if no input is provided', () {
        expectSanitized(
          expectedFile: '$packageName.dart',
          expectedDir: 'lib',
        );
      });

      test('Returns default values if inputs are empty', () {
        expectSanitized(
          fileInput: '',
          dirInput: '',
          expectedFile: '$packageName.dart',
          expectedDir: 'lib',
        );
      });

      test('Returns default values if inputs contain only whitespace', () {
        expectSanitized(
          fileInput: '   ',
          dirInput: '   ',
          expectedFile: '$packageName.dart',
          expectedDir: 'lib',
        );
      });

      test('Merges directories from file and dir inputs', () {
        expectSanitized(
          fileInput: 'bar/baz/foo_bar.dart',
          dirInput: 'lib/foo',
          expectedFile: 'foo_bar.dart',
          expectedDir: 'lib/foo/bar/baz',
        );
      });

      test('Takes a directory from the file input if no dir is provided', () {
        expectSanitized(
          fileInput: 'lib/foo/bar/foo_bar.dart',
          expectedFile: 'foo_bar.dart',
          expectedDir: 'lib/foo/bar',
        );
      });

      test('Normalizes directory paths', () {
        expectSanitized(
          fileInput: './bar//baz/../foo_bar.dart',
          dirInput: './lib/foo/',
          expectedFile: 'foo_bar.dart',
          expectedDir: 'lib/foo/bar',
        );
      });
    });

    group('Invalid input', () {
      void expectArgumentError({String? fileInput, String? dirInput}) {
        expect(
          () => sut.sanitize(fileInput: fileInput, dirInput: dirInput),
          throwsArgumentError,
        );
      }

      test("Throws if file has an extension other than '.dart'", () {
        expectArgumentError(fileInput: 'foo_bar.txt');
      });

      test('Throws if file is only an extension', () {
        expectArgumentError(fileInput: '.dart');
      });

      test("Throws if file is a directory with a trailing '/'", () {
        expectArgumentError(fileInput: 'lib/foo_bar/');
      });

      test('Throws if dir is a file', () {
        expectArgumentError(dirInput: 'lib/foo_bar.dart');
      });

      test('Throws if any input is an absolute path', () {
        expectArgumentError(fileInput: '/foo_bar.dart');
        expectArgumentError(dirInput: '/lib');
      });

      test('Throws for any non-snake-case file name or directory', () {
        expectArgumentError(fileInput: 'Foo.dart');
        expectArgumentError(fileInput: 'foo-bar.dart');
        expectArgumentError(fileInput: 'foo bar.dart');
        expectArgumentError(fileInput: 'f!oo.dart');
        expectArgumentError(fileInput: 'lib/Foo/bar.dart');
        expectArgumentError(fileInput: 'lib/foo-bar/baz.dart');
        expectArgumentError(fileInput: 'lib/foo bar/baz.dart');
        expectArgumentError(fileInput: 'lib/f!oo/baz.dart');
        expectArgumentError(fileInput: 'package:lib/foo/baz.dart');
        expectArgumentError(dirInput: 'lib/Foo');
        expectArgumentError(dirInput: 'lib/foo-bar');
        expectArgumentError(dirInput: 'lib/foo bar');
        expectArgumentError(dirInput: 'lib/f!oo');
        expectArgumentError(dirInput: 'package:lib/foo');
      });
    });
  });
}

class FakePubspecReader with Fake implements PubspecReader {
  @override
  String get name => packageName;
}

const packageName = 'foo';
