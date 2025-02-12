import 'package:exported/src/builder/barrel_file_generator.dart';
import 'package:exported/src/model/barrel_file.dart';
import 'package:exported/src/model/export.dart';
import 'package:exported/src/model/exported_options.dart';
import 'package:test/test.dart';

void main() {
  group('$BarrelFileGenerator', () {
    late BarrelFileGenerator sut;

    group('.fromOptions()', () {
      test('Creates a BarrelFileGenerator instance for each configured BarrelFile', () {
        const files = [
          BarrelFile(path: 'foo.dart'),
          BarrelFile(path: 'bar.dart'),
        ];

        final result =
            BarrelFileGenerator.fromOptions(const ExportedOptions(files: files)).toList();

        expect(result, hasLength(2));
        for (var i = 0; i < files.length; i++) {
          expect(result[i].file, files[i]);
        }
      });

      test('Adds all configured Exports', () {
        fail('Missing test');
      });
    });

    group('.exports', () {
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

    group('.addExports()', () {
      test("Adds only export if it matches the file's tags", () {
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

      test("Always adds an export if the file doesn't have tags", () {
        sut = BarrelFileGenerator(
          file: const BarrelFile(path: 'foo.dart'),
        );

        const a = Export(uri: 'package:a/a.dart', tags: {'Foo'});
        sut.addExports({a});

        expect(sut.exports, {a});
      });

      test('Merges exports with matching URI', () {
        sut = BarrelFileGenerator(
          file: const BarrelFile(path: 'foo.dart'),
        );

        const a = Export(uri: 'package:bar/bar.dart', show: {'Baz'});
        const b = Export(uri: 'package:bar/bar.dart', show: {'Qux'});
        sut.addExports({a, b});

        final merged = a.merge(b);
        expect(sut.exports, hasLength(1));
        expect(sut.exports.first.uri, merged.uri);
        expect(sut.exports.first.show, merged.show);
        expect(sut.exports.first.hide, merged.hide);
      });
    });
  });
}
