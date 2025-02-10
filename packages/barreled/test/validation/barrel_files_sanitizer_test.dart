import 'package:barreled/src/options/barrel_file_option.dart';
import 'package:barreled/src/validation/barrel_files_sanitizer.dart';
import 'package:barreled/src/validation/file_path_sanitizer.dart';
import 'package:mocktail/mocktail.dart';
import 'package:test/test.dart';

void main() {
  group('$BarrelFilesSanitizer', () {
    late BarrelFilesSanitizer sut;

    setUp(() {
      BarrelFileOption.pathSanitizer = FakeBarrelFilePathSanitizer();
      sut = const BarrelFilesSanitizer(inputName: 'files');
    });

    group('Valid inputs', () {
      void expectSanitized(List<BarrelFileOption>? input, List<BarrelFileOption> expected) =>
          expect(sut.sanitize(input), expected);

      test('Leaves a list without duplicates as is', () {
        expectSanitized(
          [BarrelFileOption(path: 'foo'), BarrelFileOption(path: 'bar')],
          [BarrelFileOption(path: 'foo'), BarrelFileOption(path: 'bar')],
        );
      });

      test('Replaces an empty list with the default barrel file', () {
        expectSanitized(
          [],
          [BarrelFileOption()],
        );
      });

      test('Replaces null input with the default barrel file', () {
        expectSanitized(
          null,
          [BarrelFileOption()],
        );
      });

      test('Removes duplicates by path', () {
        expectSanitized(
          [
            BarrelFileOption(path: 'foo'),
            BarrelFileOption(path: 'foo'),
          ],
          [BarrelFileOption(path: 'foo')],
        );
      });
    });

    group('Invalid inputs', () {
      void expectArgumentError(List<BarrelFileOption> input) {
        expect(() => sut.sanitize(input), throwsArgumentError);
      }

      test('Throws an ArgumentError if there are duplicates with conflicting configurations', () {
        expectArgumentError([
          BarrelFileOption(path: 'foo', tags: const {'bar'}),
          BarrelFileOption(path: 'foo', tags: const {'baz'}),
        ]);
      });
    });
  });
}

class FakeBarrelFilePathSanitizer with Fake implements FilePathSanitizer {
  @override
  String sanitize(String? input) => input ?? 'foo.dart';
}
