import 'package:exported/src/model/export.dart';
import 'package:exported/src/model/export_filter.dart';
import 'package:exported/src/model/export_uri.dart';
import 'package:exported/src/model/exported_option_keys.dart' as keys;
import 'package:exported/src/model/option_collections.dart';
import 'package:exported/src/model/tag.dart';
import 'package:test/test.dart' hide Tags;

void main() {
  group('Export', () {
    group('.element()', () {
      test('Returns an Export for an annotated element', () {
        final export = Export.element(
          uri: 'package:foo/src/foo.dart',
          name: 'Foo',
        );
        expect(export, isA<Export>());
        expect(export.uri, 'package:foo/src/foo.dart');
        expect(export.filter, ExportFilter.showSingle('Foo'));
        expect(export.tags, Tags.none);
      });

      test('Accepts and sanitizes optional tags', () {
        final export = Export.element(
          uri: 'package:foo/src/foo.dart',
          name: 'Foo',
          tags: const {'Foo', ' bar '},
        );
        expect(export.tags, Tags.fromInput(const {'Foo', ' bar '}));
      });
    });

    group('.library()', () {
      test('Returns an Export for an annotated library', () {
        final export = Export.library(uri: 'package:foo/src/foo.dart');
        expect(export, isA<Export>());
        expect(export.uri, 'package:foo/src/foo.dart');
        expect(export.filter, ExportFilter.none);
        expect(export.tags, Tags.none);
      });

      test('Accepts and sanitizes optional show sets', () {
        final export = Export.library(
          uri: 'package:foo/src/foo.dart',
          show: const {'  Foo  ', 'Bar'},
        );
        expect(export.filter, ExportFilter.fromInput(show: const {'Foo', 'Bar'}));
      });

      test('Accepts and sanitizes optional hide sets', () {
        final export = Export.library(
          uri: 'package:foo/src/foo.dart',
          hide: const {'  Foo  ', 'Bar'},
        );
        expect(export.filter, ExportFilter.fromInput(hide: const {'Foo', 'Bar'}));
      });

      test('Accepts and sanitizes optional tags', () {
        final export = Export.library(
          uri: 'package:foo/src/foo.dart',
          tags: const {'Foo', ' bar '},
        );
        expect(export.tags, Tags.fromInput(const {'Foo', ' bar '}));
      });
    });

    group('.fromInput()', () {
      void expectOutput(dynamic input, List<Export> expected) =>
          expect(Export.fromInput(input), expected.asOptionList);

      void expectThrows(dynamic input) =>
          expect(() => Export.fromInput(input), throwsArgumentError);

      test('Parses a list of Export maps', () {
        expectOutput([
          {
            keys.uri: 'package:foo/src/foo.dart',
            keys.show: ['Foo', 'Bar'],
            keys.tags: ['foo', 'bar'],
          },
          {
            keys.uri: 'package:foo/src/bar.dart',
            keys.hide: ['Foo', 'Bar'],
          },
        ], [
          Export(
            'package:foo/src/foo.dart'.asExportUri,
            {'Foo', 'Bar'}.asShow,
            {'foo', 'bar'}.asTags,
          ),
          Export(
            'package:foo/src/bar.dart'.asExportUri,
            {'Foo', 'Bar'}.asHide,
          ),
        ]);
      });

      test('Parses a list of Export URI strings', () {
        expectOutput([
          'package:foo/src/foo.dart',
          'package:foo/src/bar.dart',
        ], [
          Export('package:foo/src/foo.dart'.asExportUri),
          Export('package:foo/src/bar.dart'.asExportUri),
        ]);
      });

      test('Parses a mixed list of strings and maps', () {
        expectOutput([
          {
            keys.uri: 'package:foo/src/foo.dart',
            keys.show: ['Foo', 'Bar'],
            keys.tags: ['foo', 'bar'],
          },
          'package:foo/src/bar.dart',
        ], [
          Export(
            'package:foo/src/foo.dart'.asExportUri,
            {'Foo', 'Bar'}.asShow,
            {'foo', 'bar'}.asTags,
          ),
          Export('package:foo/src/bar.dart'.asExportUri),
        ]);
      });

      test('Parses a single Export map', () {
        expectOutput({
          keys.uri: 'package:foo/src/foo.dart',
          keys.show: ['Foo', 'Bar'],
          keys.tags: ['foo', 'bar'],
        }, [
          Export(
            'package:foo/src/foo.dart'.asExportUri,
            {'Foo', 'Bar'}.asShow,
            {'foo', 'bar'}.asTags,
          ),
        ]);
      });

      test('Parses a single Export URI string', () {
        expectOutput('package:foo/src/foo.dart', [
          Export('package:foo/src/foo.dart'.asExportUri),
        ]);
      });

      test('Parses null/empty as an empty list', () {
        expectOutput(null, []);
        expectOutput(const <dynamic>[], []);
      });

      test('Removes duplicates, but leaves Exports with matching URIs that are not equal', () {
        expectOutput([
          'package:foo/src/foo.dart',
          'package:foo/src/foo.dart',
          {
            keys.uri: 'package:foo/src/foo.dart',
            keys.show: ['Foo', 'Bar'],
            keys.tags: ['foo', 'bar'],
          },
        ], [
          Export('package:foo/src/foo.dart'.asExportUri),
          Export(
            'package:foo/src/foo.dart'.asExportUri,
            {'Foo', 'Bar'}.asShow,
            {'foo', 'bar'}.asTags,
          ),
        ]);
      });

      test('Throws for invalid input types', () {
        expectThrows(42);
        expectThrows([42]);
      });

      test('Throws for invalid input keys', () {
        expectThrows({keys.path: 'foo'});
        expectThrows([
          {keys.path: 'foo'},
        ]);
      });
    });

    group('.fromJson()', () {
      test('Parses a JSON object with no filter or tags', () {
        expect(
          Export.fromJson(const {keys.uri: 'package:foo/src/foo.dart'}),
          Export('package:foo/src/foo.dart'.asExportUri),
        );
      });

      test('Parses a JSON object with show filter', () {
        expect(
          Export.fromJson(const {
            keys.uri: 'package:foo/src/foo.dart',
            keys.show: ['Foo', 'Bar'],
          }),
          Export(
            'package:foo/src/foo.dart'.asExportUri,
            {'Foo', 'Bar'}.asShow,
          ),
        );
      });

      test('Parses a JSON object with hide filter', () {
        expect(
          Export.fromJson(const {
            keys.uri: 'package:foo/src/foo.dart',
            keys.hide: ['Foo', 'Bar'],
          }),
          Export(
            'package:foo/src/foo.dart'.asExportUri,
            {'Foo', 'Bar'}.asHide,
          ),
        );
      });
    });

    group('.toJson()', () {
      test('Converts an Export with no filter or tags to JSON', () {
        expect(
          Export('package:foo/src/foo.dart'.asExportUri).toJson(),
          {keys.uri: 'package:foo/src/foo.dart'},
        );
      });

      test('Does not store tags in JSON', () {
        expect(
          Export(
            'package:foo/src/foo.dart'.asExportUri,
            ExportFilter.none,
            {'foo', 'bar'}.asTags,
          ).toJson(),
          {keys.uri: 'package:foo/src/foo.dart'},
        );
      });

      test('Converts an Export with show filter to JSON', () {
        expect(
          Export(
            'package:foo/src/foo.dart'.asExportUri,
            {'Foo', 'Bar'}.asShow,
          ).toJson(),
          {
            keys.uri: 'package:foo/src/foo.dart',
            keys.show: ['Foo', 'Bar'],
          },
        );
      });

      test('Converts an Export with hide filter to JSON', () {
        expect(
          Export(
            'package:foo/src/foo.dart'.asExportUri,
            {'Foo', 'Bar'}.asHide,
          ).toJson(),
          {
            keys.uri: 'package:foo/src/foo.dart',
            keys.hide: ['Foo', 'Bar'],
          },
        );
      });
    });

    group('.merge()', () {
      test('Returns this instance if URIs do not match', () {
        final export = Export(
          'package:foo/src/foo.dart'.asExportUri,
          {'Foo', 'Bar'}.asShow,
        );
        final other = Export(
          'package:foo/src/bar.dart'.asExportUri,
          {'Bar', 'Baz'}.asHide,
        );
        expect(export.merge(other), export);
      });

      test('Merges filters if URIs match', () {
        final export = Export(
          'package:foo/src/foo.dart'.asExportUri,
          {'Foo', 'Bar'}.asShow,
        );
        final other = Export(
          'package:foo/src/foo.dart'.asExportUri,
          {'Bar', 'Baz'}.asHide,
        );
        final mergedFilter = export.filter.merge(other.filter);
        expect(
          export.merge(other),
          Export(
            'package:foo/src/foo.dart'.asExportUri,
            mergedFilter,
          ),
        );
      });
    });

    group('.toDart()', () {
      test('Converts an Export to a Dart export directive string', () {
        expect(
          Export('package:foo/src/foo.dart'.asExportUri).toDart(),
          "export 'package:foo/src/foo.dart';",
        );
      });

      test('Converts an Export with show filter to a Dart export directive string', () {
        expect(
          Export(
            'package:foo/src/foo.dart'.asExportUri,
            {'Foo', 'Bar'}.asShow,
          ).toDart(),
          "export 'package:foo/src/foo.dart' show Bar, Foo;",
        );
      });

      test('Converts an Export with hide filter to a Dart export directive string', () {
        expect(
          Export(
            'package:foo/src/foo.dart'.asExportUri,
            {'Foo', 'Bar'}.asHide,
          ).toDart(),
          "export 'package:foo/src/foo.dart' hide Bar, Foo;",
        );
      });
    });

    group('.compareTo()', () {
      test('Compares Exports by URI', () {
        final foo = Export('package:foo/src/foo.dart'.asExportUri);
        final bar = Export('package:foo/src/bar.dart'.asExportUri);
        expect(foo.compareTo(bar), 1);
        expect(bar.compareTo(foo), -1);
        expect(foo.compareTo(foo), 0);
      });
    });
  });
}
