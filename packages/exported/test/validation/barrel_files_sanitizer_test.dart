import 'package:exported/src/builder/exported_option_keys.dart' as keys;
import 'package:exported/src/model/barrel_file.dart';
import 'package:exported/src/validation/barrel_files_parser.dart';
import 'package:exported/src/validation/file_path_parser.dart';
import 'package:mocktail/mocktail.dart';
import 'package:test/test.dart';

void main() {
  group('$BarrelFilesParser', () {
    late BarrelFilesParser sut;

    setUp(() {
      BarrelFile.pathParser = FakeBarrelFilePathParser();
      sut = const BarrelFilesParser(keys.barrelFiles);
    });

    group('Valid inputs', () {
      void expectSanitized(List<BarrelFile>? input, List<BarrelFile> expected) =>
          expect(sut.parse(input), expected);

      test('Leaves a list without duplicates as is', () {
        expectSanitized(
          const [BarrelFile(path: 'foo'), BarrelFile(path: 'bar')],
          const [BarrelFile(path: 'foo'), BarrelFile(path: 'bar')],
        );
      });

      test('Replaces an empty list with the default barrel file', () {
        expectSanitized(
          [],
          [BarrelFile.packageNamed()],
        );
      });

      test('Replaces null input with the default barrel file', () {
        expectSanitized(
          null,
          [BarrelFile.packageNamed()],
        );
      });

      test('Removes duplicates by path', () {
        expectSanitized(
          const [
            BarrelFile(path: 'foo'),
            BarrelFile(path: 'foo'),
          ],
          const [BarrelFile(path: 'foo')],
        );
      });
    });

    group('Invalid inputs', () {
      void expectArgumentError(List<BarrelFile> input) {
        expect(() => sut.parse(input), throwsArgumentError);
      }

      test('Throws an ArgumentError if there are duplicates with conflicting configurations', () {
        expectArgumentError(const [
          BarrelFile(path: 'foo', tags: {'bar'}),
          BarrelFile(path: 'foo', tags: {'baz'}),
        ]);
      });
    });
  });
}

class FakeBarrelFilePathParser with Fake implements FilePathParser {
  @override
  String parse([String? input]) => input ?? 'foo.dart';
}
