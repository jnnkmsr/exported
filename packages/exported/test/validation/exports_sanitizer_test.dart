import 'package:exported/src/builder/exported_option_keys.dart' as keys;
import 'package:exported/src/model/export.dart';
import 'package:exported/src/validation/exports_parser.dart';
import 'package:test/test.dart';

void main() {
  group('$ExportsParser', () {
    late ExportsParser sut;

    setUp(() {
      sut = const ExportsParser(keys.exports);
    });

    group('Valid inputs', () {
      void expectSanitized(List<Export>? input, List<Export> expected) =>
          expect(sut.parse(input), expected);

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
        expect(() => sut.parse(input), throwsArgumentError);
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
