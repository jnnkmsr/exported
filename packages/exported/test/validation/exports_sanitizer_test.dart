import 'package:exported/src/model/export.dart';
import 'package:exported/src/validation/exports_sanitizer.dart';
import 'package:test/test.dart';

void main() {
  group('$ExportsSanitizer', () {
    late ExportsSanitizer sut;

    setUp(() {
      sut = const ExportsSanitizer(inputName: 'exports');
    });

    group('Valid inputs', () {
      void expectSanitized(List<Export>? input, List<Export> expected) =>
          expect(sut.sanitize(input), expected);

      test('Leaves a list without duplicates as is', () {
        expectSanitized(
          const [Export(uri: 'foo'), Export(uri: 'bar')],
          const [Export(uri: 'foo'), Export(uri: 'bar')],
        );
      });

      test('Accepts an empty list', () {
        expectSanitized(
          const [],
          const [],
        );
      });

      test('Treats null as an empty list', () {
        expectSanitized(
          null,
          const [],
        );
      });

      test('Removes duplicates by URI', () {
        expectSanitized(
          const [Export(uri: 'foo'), Export(uri: 'foo')],
          const [Export(uri: 'foo')],
        );
      });
    });

    group('Invalid inputs', () {
      void expectArgumentError(List<Export> input) {
        expect(() => sut.sanitize(input), throwsArgumentError);
      }

      test('Throws an ArgumentError if there are duplicates with conflicting configurations', () {
        expectArgumentError(const [
          Export(uri: 'foo', show: {'bar'}),
          Export(uri: 'foo', hide: {'baz'}),
        ]);
      });
    });
  });
}
