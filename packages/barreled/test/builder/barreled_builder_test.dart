import 'package:barreled/src/builder/barreled_builder.dart';
import 'package:barreled/src/util/pubspec_reader.dart';
import 'package:build_test/build_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:pub_semver/pub_semver.dart';
import 'package:test/test.dart';

const packageName = 'test_library';
final dartVersion = Version(3, 6, 1);

void main() {
  group('$BarreledBuilder', () {
    late BarreledBuilder sut;

    late MockPubspecReader mockPubspecReader;

    setUp(() {
      mockPubspecReader = MockPubspecReader();
      when(() => mockPubspecReader.packageName).thenReturn(packageName);
      when(() => mockPubspecReader.dartVersion).thenReturn(dartVersion);

      sut = BarreledBuilder(
        pubspecReader: mockPubspecReader,
      );
    });

    group('Given no barrel_file options', () {
      const defaultAssetPath = '$packageName|lib/$packageName.dart';

      group('And no annotations/package exports', () {
        test('Then generates an empty file named after the package', () async {
          await testBuilder(
            sut,
            {
              '$packageName|pubspec.yaml': '',
            },
            reader: await PackageAssetReader.currentIsolate(),
            outputs: {
              defaultAssetPath: '// GENERATED CODE - DO NOT MODIFY BY HAND\n',
            },
          );
        });

        test('overwrites existing file', () {
          fail('Not implemented');
        });
      });

      group('only package exports', () {
        test('includes all package exports, sorted by name', () {
          fail('Not implemented');
        });

        test('ignores tags and includes all package exports', () {
          fail('Not implemented');
        });

        test('includes show filters, sorted by name', () {
          fail('Not implemented');
        });

        test('includes hide filters, sorted by name', () {
          fail('Not implemented');
        });

        test('includes only show filter when both show and hide are specified', () {
          fail('Not implemented');
        });

        // TODO: Split into multiple tests testing show/hide combinations.
        test('merges duplicate exports', () {
          fail('Not implemented');
        });
      });

      group('single library with annotations', () {
        test('generates empty barrel file when there are no annotations', () {
          fail('Not implemented');
        });

        test('includes all annotated elements, sorted by name', () {
          fail('Not implemented');
        });
      });

      group('multiple libraries with annotations', () {
        test('includes all annotated elements, sorted by name', () {
          fail('Not implemented');
        });
      });

      group('annotations and package exports', () {
        test('includes first package exports and then annotated elements', () {
          fail('Not implemented');
        });
      });
    });
  });
}

class MockPubspecReader with Mock implements PubspecReader {}
