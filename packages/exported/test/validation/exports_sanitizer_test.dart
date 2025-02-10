import 'package:exported/src/options/export_option.dart';
import 'package:exported/src/validation/exports_sanitizer.dart';
import 'package:test/test.dart';

void main() {
  group('$ExportsSanitizer', () {
    late ExportsSanitizer sut;

    setUp(() {
      sut = const ExportsSanitizer(inputName: 'exports');
    });

    group('Valid inputs', () {
      void expectSanitized(List<ExportOption>? input, List<ExportOption> expected) =>
          expect(sut.sanitize(input), expected);

      test('Leaves a list without duplicates as is', () {
        expectSanitized(
          [ExportOption(uri: 'foo'), ExportOption(uri: 'bar')],
          [ExportOption(uri: 'foo'), ExportOption(uri: 'bar')],
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

      test('Removes duplicates by URI', () {
        expectSanitized(
          [
            ExportOption(uri: 'foo'),
            ExportOption(uri: 'foo'),
          ],
          [ExportOption(uri: 'foo')],
        );
      });
    });

    group('Invalid inputs', () {
      void expectArgumentError(List<ExportOption> input) {
        expect(() => sut.sanitize(input), throwsArgumentError);
      }

      test('Throws an ArgumentError if there are duplicates with conflicting configurations', () {
        expectArgumentError([
          ExportOption(uri: 'foo', show: const {'bar'}),
          ExportOption(uri: 'foo', hide: const {'baz'}),
        ]);
      });
    });
  });
}
