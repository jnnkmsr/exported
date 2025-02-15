import 'package:exported/src/builder/barrel_file_generator.dart';
import 'package:exported/src/model/barrel_file.dart';
import 'package:exported/src/model/export.dart';
import 'package:exported/src/model/exported_options.dart';
import 'package:test/test.dart';

void main() {
  late BarrelFileGenerator sut;

  group('BarrelFileGenerator.fromOptions()', () {
    const files = [
      BarrelFile(path: 'foo.dart'),
      BarrelFile(path: 'bar.dart'),
    ];

    test('Creates a BarrelFileGenerator for each configured file', () {
      final suts = BarrelFileGenerator.fromOptions(
        const ExportedOptions(barrelFiles: files),
      ).toList();

      expect(suts.map((e) => e.file).toList(), files);
    });

    test('Adds all configured Exports', () {
      const exports = [
        Export(uri: 'package:a/a.dart'),
        Export(uri: 'package:b/b.dart'),
      ];

      final suts = BarrelFileGenerator.fromOptions(
        const ExportedOptions(barrelFiles: files, exports: exports),
      ).toList();

      for (final sut in suts) {
        expect(sut.exports, exports);
      }
    });
  });

  group('exports', () {
    test('Returns all exports sorted by URI', () {
      sut = BarrelFileGenerator(
        file: const BarrelFile(path: 'foo.dart'),
      );

      const a = Export(uri: 'package:a/a.dart');
      const b = Export(uri: 'package:b/b.dart');
      const c = Export(uri: 'package:c/c.dart');
      const d = Export(uri: 'package:d/d.dart');
      sut.addExports({d, a, c, b});

      expect(sut.exports, [a, b, c, d]);
    });
  });

  group('addExports()', () {
    test("Adds only exports that match the file's tags", () {
      sut = BarrelFileGenerator(
        file: const BarrelFile(
          path: 'foo.dart',
          tags: {'Foo', 'Bar'},
        ),
      );

      const a = Export(uri: 'package:a/a.dart', tags: {'Foo'});
      const b = Export(uri: 'package:b/b.dart', tags: {'Foo', 'Bar'});
      const c = Export(uri: 'package:c/c.dart', tags: {'Bar', 'Baz'});
      const d = Export(uri: 'package:d/d.dart', tags: {'Baz'});
      sut.addExports({a, b, c, d});

      expect(sut.exports, {a, b, c});
    });

    test('Always adds an export if the file does not have tags', () {
      sut = BarrelFileGenerator(
        file: const BarrelFile(path: 'foo.dart'),
      );

      const a = Export(uri: 'package:foo/foo.dart', tags: {'Foo'});
      sut.addExports({a});

      expect(sut.exports, {a});
    });

    test('Merges exports with matching URI', () {
      sut = BarrelFileGenerator(
        file: const BarrelFile(path: 'foo.dart'),
      );

      const a = Export(uri: 'package:foo/foo.dart', show: {'Foo'});
      const b = Export(uri: 'package:foo/foo.dart', show: {'Bar'});
      sut.addExports({a, b});

      final merged = a.merge(b);
      expect(sut.exports, hasLength(1));
      expect(sut.exports.first.uri, merged.uri);
      expect(sut.exports.first.show, merged.show);
      expect(sut.exports.first.hide, merged.hide);
    });
  });
}
