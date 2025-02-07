import 'package:barreled/src/model/barrel_file_option.dart';
import 'package:barreled/src/model/barreled_builder_options.dart';
import 'package:test/test.dart';

void main() {
  group('$BarreledBuilderOptions', () {
    late BarreledBuilderOptions sut;

    group('.files', () {
      group('Valid input', () {
        test('Accepts null', () {
          sut = BarreledBuilderOptions.fromJson({});
          expect(sut.files, isNull);
        });

        test('Treats an empty list as null', () {
          sut = BarreledBuilderOptions.fromJson({'barrel_files': <Map>[]});
          expect(sut.files, isNull);
        });

        test('Parses a set of files', () {
          sut = BarreledBuilderOptions.fromJson({
            'barrel_files': [
              {'name': 'barrel_file1.dart'},
              {'name': 'barrel_file2.dart'},
            ],
          });
          expect(sut.files, [
            BarrelFileOption(name: 'barrel_file1.dart', dir: 'lib'),
            BarrelFileOption(name: 'barrel_file2.dart', dir: 'lib'),
          ]);
        });

        test('Accepts equal file names with different paths', () {
          sut = BarreledBuilderOptions.fromJson({
            'barrel_files': [
              {'name': 'barrel_file.dart'},
              {'name': 'barrel_file.dart', 'dir': 'lib/folder'},
            ],
          });
          expect(sut.files, [
            BarrelFileOption(name: 'barrel_file.dart', dir: 'lib'),
            BarrelFileOption(name: 'barrel_file.dart', dir: 'lib/folder'),
          ]);
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
      });
    });
  });
}
