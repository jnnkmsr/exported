import 'package:barreled/src/options/barrel_file_option.dart';
import 'package:barreled/src/options/barreled_builder_options.dart';
import 'package:test/test.dart';

void main() {
  group('$BarreledBuilderOptions', () {
    late BarreledBuilderOptions sut;

    group('.files', () {
      group('Valid input', () {
        final defaultFile = BarrelFileOption();

        test('Treats null as the default file', () {
          sut = BarreledBuilderOptions.fromJson({});
          expect(sut.files, hasLength(1));
          expect(sut.files.first.name, defaultFile.name);
          expect(sut.files.first.dir, defaultFile.dir);
          expect(sut.files.first.tags, defaultFile.tags);
        });

        test('Treats an empty list as the default file', () {
          sut = BarreledBuilderOptions.fromJson({'barrel_files': <Map>[]});
          expect(sut.files, hasLength(1));
          expect(sut.files.first.name, defaultFile.name);
          expect(sut.files.first.dir, defaultFile.dir);
          expect(sut.files.first.tags, defaultFile.tags);
        });

        test('Parses a list of files', () {
          sut = BarreledBuilderOptions.fromJson({
            'barrel_files': [
              {'name': 'barrel_file1.dart'},
              {'name': 'barrel_file2.dart'},
            ],
          });
          expect(sut.files, hasLength(2));
        });

        test('Accepts equal file names with different paths', () {
          sut = BarreledBuilderOptions.fromJson({
            'barrel_files': [
              {'name': 'barrel_file.dart'},
              {'name': 'barrel_file.dart', 'dir': 'lib/folder'},
            ],
          });
          expect(sut.files, hasLength(2));
        });
      });

      group('Invalid input', () {
        test('Throws an ArgumentError if there are duplicate file paths', () {
          expect(
            () => BarreledBuilderOptions.fromJson({
              'barrel_files': [
                {'name': 'barrel_file.dart'},
                {'name': 'barrel_file.dart'},
              ],
            }),
            throwsArgumentError,
          );
        });

        test('Throws an ArgumentError if there is invalid input', () {
          expect(
            () => BarreledBuilderOptions.fromJson({
              'barrel_files': [
                {'name': 'lib/'},
              ],
            }),
            throwsArgumentError,
          );
        });
      });
    });
  });
}
