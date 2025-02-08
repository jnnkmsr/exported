import 'package:barreled/src/options/barrel_file_option.dart';
import 'package:barreled/src/options/barreled_options.dart';
import 'package:test/test.dart';

void main() {
  group('$BarreledOptions', () {
    late BarreledOptions sut;

    group('.files', () {
      group('Valid input', () {
        final defaultFile = BarrelFileOption();

        test('Treats null as the default file', () {
          sut = BarreledOptions.fromJson(const {});
          expect(sut.files, hasLength(1));
          expect(sut.files.first.file, defaultFile.file);
          expect(sut.files.first.dir, defaultFile.dir);
          expect(sut.files.first.tags, defaultFile.tags);
        });

        test('Treats an empty list as the default file', () {
          sut = BarreledOptions.fromJson(const {BarreledOptions.filesKey: <Map>[]});
          expect(sut.files, hasLength(1));
          expect(sut.files.first.file, defaultFile.file);
          expect(sut.files.first.dir, defaultFile.dir);
          expect(sut.files.first.tags, defaultFile.tags);
        });

        test('Parses a list of files', () {
          sut = BarreledOptions.fromJson(const {
            BarreledOptions.filesKey: [
              {BarrelFileOption.fileKey: 'barrel_file1.dart'},
              {BarrelFileOption.fileKey: 'barrel_file2.dart'},
            ],
          });
          expect(sut.files, hasLength(2));
        });

        test('Accepts equal file names with different paths', () {
          sut = BarreledOptions.fromJson(const {
            BarreledOptions.filesKey: [
              {BarrelFileOption.fileKey: 'barrel_file.dart'},
              {BarrelFileOption.fileKey: 'barrel_file.dart', 'dir': 'lib/folder'},
            ],
          });
          expect(sut.files, hasLength(2));
        });
      });

      group('Invalid input', () {
        test('Throws an ArgumentError if there are duplicate file paths', () {
          expect(
            () => BarreledOptions.fromJson(const {
              BarreledOptions.filesKey: [
                {BarrelFileOption.fileKey: 'barrel_file.dart'},
                {BarrelFileOption.fileKey: 'barrel_file.dart'},
              ],
            }),
            throwsArgumentError,
          );
        });

        test('Throws an ArgumentError if there is invalid input', () {
          expect(
            () => BarreledOptions.fromJson(const {
              BarreledOptions.filesKey: [
                {BarrelFileOption.fileKey: 'lib/'},
              ],
            }),
            throwsArgumentError,
          );
        });
      });
    });
  });
}
