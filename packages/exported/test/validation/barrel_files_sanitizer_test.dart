import 'package:exported/src/builder/exported_option_keys.dart' as keys;
import 'package:exported/src/model/barrel_file.dart';
import 'package:exported/src/validation/barrel_files_sanitizer.dart';
import 'package:exported/src/validation/file_path_sanitizer.dart';
import 'package:mocktail/mocktail.dart';
import 'package:test/test.dart';

void main() {
  group('$BarrelFilesSanitizer', () {
    late BarrelFilesSanitizer sut;

    setUp(() {
      BarrelFile.pathSanitizer = FakeBarrelFilePathSanitizer();
      sut = const BarrelFilesSanitizer(keys.barrelFiles);
    });

    group('Valid inputs', () {
      void expectSanitized(List<BarrelFile>? input, List<BarrelFile> expected) =>
          expect(sut.sanitize(input), expected);

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
        expect(() => sut.sanitize(input), throwsArgumentError);
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

class FakeBarrelFilePathSanitizer with Fake implements FilePathSanitizer {
  @override
  String sanitize(String? input) => input ?? 'foo.dart';
}
