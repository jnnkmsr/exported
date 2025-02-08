import 'package:barreled/src/model/barrel_export.dart';
import 'package:barreled/src/model/barrel_file.dart';
import 'package:barreled/src/options/barrel_file_option.dart';
import 'package:barreled/src/options/barreled_options.dart';
import 'package:test/test.dart';

void main() {
  group('$BarrelFile', () {
    late BarrelFile sut;

    group('.fromOptions()', () {
      test('Creates a BarrelFile for each BarrelFileOption', () {
        final options = BarreledOptions(
          files: [
            BarrelFileOption(
              file: 'barrel_file1.dart',
              dir: 'dir1',
              tags: const {'tag1'},
            ),
            BarrelFileOption(
              file: 'barrel_file2.dart',
              dir: 'dir2',
              tags: const {'tag2'},
            ),
          ],
        );

        final files = BarrelFile.fromOptions(
          options,
          defaultName: () => 'default_name',
        ).toList();

        expect(files, hasLength(2));
        expect(files[0].name, 'barrel_file1.dart');
        expect(files[0].dir, 'dir1');
        expect(files[0].tags, {'tag1'});
        expect(files[1].name, 'barrel_file2.dart');
        expect(files[1].dir, 'dir2');
        expect(files[1].tags, {'tag2'});
      });
    });

    group('.addExport()', () {
      test("Adds an export if it matches the file's tags", () {
        sut = BarrelFile(
          name: 'barrel_file.dart',
          dir: 'lib',
          tags: {'tag1'},
        );
        const export = BarrelExport(
          uri: 'library',
          tags: {'tag1', 'tag2'},
        );

        sut.addExport(export);

        expect(sut.exports, {export});
      });

      test("Doesn't add an export if it doesn't match the file's tags", () {
        sut = BarrelFile(
          name: 'barrel_file.dart',
          dir: 'lib',
          tags: {'tag1'},
        );
        const export = BarrelExport(
          uri: 'library',
          tags: {'tag2'},
        );

        sut.addExport(export);

        expect(sut.exports, isEmpty);
      });

      test("Always adds an export if the file doesn't have tags", () {
        sut = BarrelFile(
          name: 'barrel_file.dart',
          dir: 'lib',
        );
        const export = BarrelExport(
          uri: 'library',
          tags: {'tag1'},
        );

        sut.addExport(export);

        expect(sut.exports, {export});
      });

      test('Merges exports with the same library', () {
        sut = BarrelFile(
          name: 'barrel_file.dart',
          dir: 'lib',
        );
        const export1 = BarrelExport(
          uri: 'library',
          show: {'show1'},
          hide: {'hide1'},
        );
        const export2 = BarrelExport(
          uri: 'library',
          show: {'show2'},
          hide: {'hide2'},
        );
        final mergedExport = export1.merge(export2);

        sut
          ..addExport(export1)
          ..addExport(export2);

        expect(sut.exports, hasLength(1));
        expect(sut.exports.first.uri, mergedExport.uri);
        expect(sut.exports.first.show, mergedExport.show);
        expect(sut.exports.first.hide, mergedExport.hide);
      });
    });

    group('.path', () {
      test('Returns the full relative path to this barrel file', () {
        sut = BarrelFile(name: 'barrel_file.dart', dir: 'lib');
        expect(sut.path, 'lib/barrel_file.dart');
      });
    });
  });
}
