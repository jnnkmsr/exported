import 'package:exported/src/model/barrel_file.dart';
import 'package:exported/src/model/export.dart';
import 'package:exported/src/options/barrel_file_option.dart';
import 'package:exported/src/options/exported_options.dart';
import 'package:test/test.dart';

void main() {
  group('$BarrelFile', () {
    late BarrelFile sut;

    group('.fromOptions()', () {
      test('Creates a $BarrelFile for each $BarrelFileOption', () {
        final options = ExportedOptions(
          files: [
            BarrelFileOption(path: 'foo.dart', tags: const {'Foo'}),
            BarrelFileOption(path: 'bar.dart', tags: const {'Bar'}),
          ],
        );

        final files = BarrelFile.fromOptions(options).toList();

        expect(files, hasLength(2));
        for (var i = 0; i < files.length; i++) {
          expect(files[i].path, options.files[i].path);
          expect(files[i].tags, options.files[i].tags);
        }
      });
    });

    group('.exports', () {
      test('Returns all exports sorted by URI', () {
        sut = BarrelFile(path: 'foo.dart');

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
        sut = BarrelFile(path: 'foo_bar.dart', tags: {'Foo', 'Bar'});

        const a = Export(uri: 'package:a/a.dart', tags: {'Foo'});
        const b = Export(uri: 'package:b/b.dart', tags: {'Foo', 'Bar'});
        const c = Export(uri: 'package:c/c.dart', tags: {'Bar', 'Baz'});
        const d = Export(uri: 'package:d/d.dart', tags: {'Baz'});
        sut.addExports({a, b, c, d});

        expect(sut.exports, {a, b, c});
      });

      test("Always adds an export if the file doesn't have tags", () {
        sut = BarrelFile(path: 'foo.dart');

        const a = Export(uri: 'package:a/a.dart', tags: {'Foo'});
        sut.addExports({a});

        expect(sut.exports, {a});
      });

      test('Merges exports with matching URI', () {
        sut = BarrelFile(path: 'foo.dart');

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
