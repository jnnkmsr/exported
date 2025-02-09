import 'package:barreled/src/options/barrel_file_option.dart';
import 'package:barreled/src/validation/barrel_files_sanitizer.dart';
import 'package:test/test.dart';

void main() {
  group('$BarrelFilesSanitizer', () {
    late BarrelFilesSanitizer sut;

    setUp(() {
      sut = const BarrelFilesSanitizer(inputName: 'files');
    });

    group('Valid inputs', () {
      void expectSanitized(List<BarrelFileOption>? input, List<BarrelFileOption> expected) =>
          expect(sut.sanitize(input), expected);

      test('Leaves a list without duplicates as is', () {
        expectSanitized(
          [BarrelFileOption(file: 'foo'), BarrelFileOption(file: 'bar')],
          [BarrelFileOption(file: 'foo'), BarrelFileOption(file: 'bar')],
        );
      });

      test('Accepts an empty list', () {
        expectSanitized(
          [],
          [],
        );
      });

      test('Treats null as an empty list', () {
        expectSanitized(
          null,
          [],
        );
      });

      test('Removes duplicates by path', () {
        expectSanitized(
          [
            BarrelFileOption(file: 'foo', dir: 'lib'),
            BarrelFileOption(file: 'foo', dir: 'lib'),
          ],
          [BarrelFileOption(file: 'foo', dir: 'lib')],
        );
      });

      test("Doesn't remove duplicate file names with different paths", () {
        expectSanitized(
          [
            BarrelFileOption(file: 'foo', dir: 'lib'),
            BarrelFileOption(file: 'foo', dir: 'lib/bar'),
          ],
          [
            BarrelFileOption(file: 'foo', dir: 'lib'),
            BarrelFileOption(file: 'foo', dir: 'lib/bar'),
          ],
        );
      });
    });

    group('Invalid inputs', () {
      void expectArgumentError(List<BarrelFileOption> input) {
        expect(() => sut.sanitize(input), throwsArgumentError);
      }

      test('Throws an ArgumentError if there are duplicates with conflicting configurations', () {
        expectArgumentError([
          BarrelFileOption(file: 'foo', tags: const {'bar'}),
          BarrelFileOption(file: 'foo', tags: const {'baz'}),
        ]);
      });
    });
  });
}
