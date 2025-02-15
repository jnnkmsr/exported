import 'package:exported/src/model/barrel_file.dart';
import 'package:exported/src/model/exported_option_keys.dart' as keys;
import 'package:exported/src/validation/barrel_files_parser.dart';
import 'package:test/test.dart';

import '../helpers/option_parser_test_helpers.dart';

void main() {
  late BarrelFilesParser sut;

  setUp(() {
    sut = const BarrelFilesParser(keys.barrelFiles);
  });

  group('parse()', () {
    test('Leaves a list without duplicates as is', () {
      sut.expectParse(
        const [BarrelFile(path: 'foo'), BarrelFile(path: 'bar')],
        const [BarrelFile(path: 'foo'), BarrelFile(path: 'bar')],
      );
    });

    test('Replaces an empty list with the default barrel file', () {
      sut.expectParse(
        [],
        [BarrelFile.packageNamed()],
      );
    });

    test('Replaces null input with the default barrel file', () {
      sut.expectParse(
        null,
        [BarrelFile.packageNamed()],
      );
    });

    test('Removes duplicates with matching configurations', () {
      sut.expectParse(
        const [
          BarrelFile(path: 'foo'),
          BarrelFile(path: 'foo'),
        ],
        const [BarrelFile(path: 'foo')],
      );
    });

    test('Merges tags of duplicate paths', () {
      sut.expectParse(
        const [
          BarrelFile(path: 'foo', tags: {'foo', 'bar'}),
          BarrelFile(path: 'foo', tags: {'bar', 'baz'}),
        ],
        const [
          BarrelFile(path: 'foo', tags: {'foo', 'bar', 'baz'}),
        ],
      );
    });
  });

  group('parseJson()', () {
    test('Parses and sanitizes a JSON list', () {
      const barrelFilesJson = [
        'foo.dart',
        {keys.path: 'bar.dart', keys.tags: ['foo', 'bar']},
        {keys.path: 'baz.dart', keys.tags: ['bar', 'baz']},
      ];
      final barrelFiles = [for (final json in barrelFilesJson) BarrelFile.fromJson(json)];

      sut.expectParseJson(barrelFilesJson, barrelFiles);
    });

    test('Throws for an invalid JSON type', () {
      sut.expectParseJsonThrows('foo');
    });
  });
}
