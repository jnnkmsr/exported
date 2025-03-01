import 'package:exported/src/model/barrel_file.dart';
import 'package:exported/src/model/exported_option_keys.dart' as keys;
import 'package:exported/src/model/option_collections.dart';
import 'package:test/test.dart';

import '../helpers/fake_pubspec_reader.dart';

void main() {
  group('BarrelFile', () {
    const package = 'foo';
    final fakePubspecReader = FakePubspecReader(name: 'foo');

    group('.packageNamed()', () {
      test('Returns the default untagged file read from pubspec.yaml', () {
        expect(
          BarrelFile.packageNamed(fakePubspecReader),
          BarrelFile(path: '$package.dart'),
        );
      });
    });

    group('.fromInput()', () {
      void expectOutput(dynamic input, List<BarrelFile> expected) =>
          expect(BarrelFile.fromInput(input, fakePubspecReader), expected.optionList);

      void expectThrows(dynamic input) {
        expect(() => BarrelFile.fromInput(input, fakePubspecReader), throwsArgumentError);
      }

      test('Parses a list of barrel-file maps', () {
        expectOutput([
          {
            keys.path: 'foo.dart',
            keys.tags: ['foo', 'bar'],
          },
          {keys.path: 'bar.dart'},
        ], [
          BarrelFile(path: 'foo.dart', tags: const {'foo', 'bar'}),
          BarrelFile(path: 'bar.dart'),
        ]);
      });

      test('Parses a list of barrel-file path strings', () {
        expectOutput([
          'foo.dart',
          'bar.dart',
        ], [
          BarrelFile(path: 'foo.dart'),
          BarrelFile(path: 'bar.dart'),
        ]);
      });

      test('Parses a mixed list of strings and maps', () {
        expectOutput([
          {
            keys.path: 'foo.dart',
            keys.tags: ['foo', 'bar'],
          },
          'bar.dart',
        ], [
          BarrelFile(path: 'foo.dart', tags: const {'foo', 'bar'}),
          BarrelFile(path: 'bar.dart'),
        ]);
      });

      test('Parses a single barrel-file map', () {
        expectOutput({
          keys.path: 'foo.dart',
          keys.tags: ['foo', 'bar'],
        }, [
          BarrelFile(path: 'foo.dart', tags: const {'foo', 'bar'}),
        ]);
      });

      test('Parses a single barrel-file path string', () {
        expectOutput('foo.dart', [BarrelFile(path: 'foo.dart')]);
      });

      test('Parses null/empty input as a single default barrel file', () {
        expectOutput(null, [BarrelFile(path: '$package.dart')]);
        expectOutput(const <dynamic>[], [BarrelFile(path: '$package.dart')]);
      });

      test('Replaces missing/empty paths with the default barrel-file path', () {
        expectOutput([
          {
            keys.tags: ['foo', 'bar'],
          },
        ], [
          BarrelFile(path: '$package.dart', tags: const {'foo', 'bar'}),
        ]);
        expectOutput([
          {
            keys.path: '',
            keys.tags: ['foo', 'bar'],
          },
        ], [
          BarrelFile(path: '$package.dart', tags: const {'foo', 'bar'}),
        ]);
        expectOutput('', [BarrelFile(path: '$package.dart')]);
        expectOutput([''], [BarrelFile(path: '$package.dart')]);
        expectOutput(const <String, dynamic>{}, [BarrelFile(path: '$package.dart')]);
        expectOutput([const <String, dynamic>{}], [BarrelFile(path: '$package.dart')]);
      });

      test('Removes duplicate paths with matching tags', () {
        expectOutput([
          {
            keys.path: 'foo.dart',
            keys.tags: ['foo', 'bar'],
          },
          {
            keys.path: 'foo.dart',
            keys.tags: ['foo', 'bar'],
          },
        ], [
          BarrelFile(path: 'foo.dart', tags: const {'foo', 'bar'}),
        ]);
      });

      test('Throws for duplicate paths with different tags', () {
        expectThrows([
          {
            keys.path: 'foo.dart',
            keys.tags: ['foo', 'bar'],
          },
          {
            keys.path: 'foo.dart',
            keys.tags: ['bar', 'baz'],
          },
        ]);
      });

      test('Throws for invalid input types', () {
        expectThrows(42);
        expectThrows([42]);
      });

      test('Throws for invalid input keys', () {
        expectThrows({keys.uri: 'bar'});
        expectThrows([
          {keys.uri: 'bar'},
        ]);
      });
    });
  });
}
