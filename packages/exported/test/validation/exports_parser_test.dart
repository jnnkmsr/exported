import 'package:exported/src/model/export.dart';
import 'package:exported/src/model/exported_option_keys.dart' as keys;
import 'package:exported/src/validation/exports_parser.dart';
import 'package:test/test.dart';

import '../helpers/option_parser_test_helpers.dart';

void main() {
  late ExportsParser sut;

  setUp(() {
    sut = const ExportsParser(keys.exports);
  });

  group('parse()', () {
    test('Leaves a list without duplicates as is', () {
      sut.expectParse(
        const [Export(uri: 'package:foo/foo.dart'), Export(uri: 'package:bar/bar.dart')],
        const [Export(uri: 'package:foo/foo.dart'), Export(uri: 'package:bar/bar.dart')],
      );
    });

    test('Accepts an empty list', () {
      sut.expectParse(
        const [],
        const [],
      );
    });

    test('Treats null as an empty list', () {
      sut.expectParse(
        null,
        const [],
      );
    });

    test('Removes duplicates', () {
      sut.expectParse(
        const [Export(uri: 'package:foo/foo.dart'), Export(uri: 'package:foo/foo.dart')],
        const [Export(uri: 'package:foo/foo.dart')],
      );
    });

    test('Merges exports with matching URI', () {
      const foo1 = Export(uri: 'package:foo/foo.dart', show: {'Foo', 'Bar'});
      const foo2 = Export(uri: 'package:foo/foo.dart', show: {'Bar', 'Baz'});
      const bar = Export(uri: 'package:bar/bar.dart');
      final foo = foo1.merge(foo2);

      sut.expectParse(
        const [foo1, foo2, bar],
        [foo, bar],
      );
    });
  });

  group('parseJson()', () {
    test('Parses and sanitizes a JSON list', () {
      const exportsJson = [
        'foo',
        {keys.uri: 'bar', keys.show: ['Foo', 'Bar']},
        {keys.uri: 'baz', keys.tags: ['foo', 'bar']},
      ];
      final barrelFiles = [for (final json in exportsJson) Export.fromJson(json)];

      sut.expectParseJson(exportsJson, barrelFiles);
    });

    test('Throws for an invalid JSON type', () {
      sut.expectParseJsonThrows('foo');
    });
  });
}
