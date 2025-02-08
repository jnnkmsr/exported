import 'package:barreled/src/options/barrel_file_option.dart';
import 'package:test/test.dart';

void main() {
  group('$BarrelFileOption', () {
    late BarrelFileOption sut;

    group('.name', () {
      group('Valid input', () {
        test('Accepts null', () {
          sut = BarrelFileOption.fromJson(const {});
          expect(sut.file, isNull);
        });

        test('Interprets an empty string as null', () {
          sut = BarrelFileOption.fromJson(const {
            BarrelFileOption.fileKey: '',
          });
          expect(sut.file, isNull);
        });

        test('Interprets whitespace only as null', () {
          sut = BarrelFileOption.fromJson(const {
            BarrelFileOption.fileKey: '   ',
          });
          expect(sut.file, isNull);
        });

        test('Takes a dart file name as specified', () {
          sut = BarrelFileOption.fromJson(const {
            BarrelFileOption.fileKey: 'barrel_file.dart',
          });
          expect(sut.file, 'barrel_file.dart');
        });

        test('Adds a .dart extension if not specified', () {
          sut = BarrelFileOption.fromJson(const {
            BarrelFileOption.fileKey: 'barrel_file',
          });
          expect(sut.file, 'barrel_file.dart');
        });

        test('Trims leading and trailing whitespace', () {
          sut = BarrelFileOption.fromJson(const {
            BarrelFileOption.fileKey: '  barrel_file  ',
          });
          expect(sut.file, 'barrel_file.dart');
        });

        test('Accepts a leading relative path', () {
          sut = BarrelFileOption.fromJson(const {
            BarrelFileOption.fileKey: 'lib/barrel_file',
          });
          expect(sut.file, 'barrel_file.dart');
        });
      });

      group('Invalid input', () {
        test('Throws an ArgumentError if the extension is not .dart', () {
          expect(
            () => BarrelFileOption.fromJson(const {
              BarrelFileOption.fileKey: 'barrel_file.txt',
            }),
            throwsArgumentError,
          );
        });

        test('Throws an ArgumentError if the input is only an extension', () {
          expect(
            () => BarrelFileOption.fromJson(
              const {BarrelFileOption.fileKey: '.dart'},
            ),
            throwsArgumentError,
          );
        });

        test('Throws an ArgumentError if the input is a directory', () {
          expect(
            () => BarrelFileOption.fromJson(
              const {BarrelFileOption.fileKey: 'lib/barrel_file/'},
            ),
            throwsArgumentError,
          );
        });

        test('Throws an ArgumentError if the input is an absolute path', () {
          expect(
            () => BarrelFileOption.fromJson(
              const {BarrelFileOption.fileKey: '/lib/barrel_file'},
            ),
            throwsArgumentError,
          );
        });
      });
    });

    group('.dir', () {
      group('Valid input', () {
        test('Treats null as the default path', () {
          sut = BarrelFileOption.fromJson(const {});
          expect(sut.dir, 'lib');
        });

        test('Treats an empty string as the default path', () {
          sut = BarrelFileOption.fromJson(const {
            BarrelFileOption.dirKey: '',
          });
          expect(sut.dir, 'lib');
        });

        test('Interprets whitespace only as the default path', () {
          sut = BarrelFileOption.fromJson(const {
            BarrelFileOption.dirKey: '   ',
          });
          expect(sut.dir, 'lib');
        });

        test('Takes a relative directory path as specified', () {
          sut = BarrelFileOption.fromJson(const {
            BarrelFileOption.dirKey: 'lib/folder',
          });
          expect(sut.dir, 'lib/folder');
        });

        test('Trims leading and trailing whitespace', () {
          sut = BarrelFileOption.fromJson(const {
            BarrelFileOption.dirKey: '  lib/folder  ',
          });
          expect(sut.dir, 'lib/folder');
        });

        test('Normalizes the directory path', () {
          sut = BarrelFileOption.fromJson(const {
            BarrelFileOption.dirKey: 'lib/../lib/folder/',
          });
          expect(sut.dir, 'lib/folder');
        });

        test('Takes any path from the name input if dir is not specified', () {
          sut = BarrelFileOption.fromJson(const {
            BarrelFileOption.fileKey: 'lib/folder/barrel_file',
          });
          expect(sut.dir, 'lib/folder');
        });

        test('Appends any path from the name input and normalizes the result', () {
          sut = BarrelFileOption.fromJson(const {
            BarrelFileOption.fileKey: 'subfolder//barrel_file',
            BarrelFileOption.dirKey: 'lib/folder',
          });
          expect(sut.dir, 'lib/folder/subfolder');
        });
      });

      group('Invalid input', () {
        test('Throws an ArgumentError if the input is an absolute path', () {
          expect(
            () => BarrelFileOption.fromJson(const {
              BarrelFileOption.dirKey: '/lib/folder',
            }),
            throwsArgumentError,
          );
        });

        test('Throws an ArgumentError if the input is a file name', () {
          expect(
            () => BarrelFileOption.fromJson(const {
              BarrelFileOption.dirKey: 'lib/barrel_file.dart',
            }),
            throwsArgumentError,
          );
        });
      });
    });

    group('.tags', () {
      test('Accepts null', () {
        sut = BarrelFileOption.fromJson(const {});
        expect(sut.tags, isNull);
      });

      test('Interprets an empty list as null', () {
        sut = BarrelFileOption.fromJson(const {BarrelFileOption.tagsKey: <String>[]});
        expect(sut.tags, isNull);
      });

      test('Interprets a list of tags as a set', () {
        sut = BarrelFileOption.fromJson(const {
          BarrelFileOption.tagsKey: ['tag1', 'tag2'],
        });
        expect(sut.tags, {'tag1', 'tag2'});
      });

      test('Trims leading and trailing whitespace', () {
        sut = BarrelFileOption.fromJson(const {
          BarrelFileOption.tagsKey: ['  tag1  ', '  tag2  '],
        });
        expect(sut.tags, {'tag1', 'tag2'});
      });

      test('Deduplicates trimmed tags', () {
        sut = BarrelFileOption.fromJson(const {
          BarrelFileOption.tagsKey: ['tag1', '  tag1  '],
        });
        expect(sut.tags, {'tag1'});
      });

      test('Removes empty or blank tags', () {
        sut = BarrelFileOption.fromJson(const {
          BarrelFileOption.tagsKey: ['tag1', '', '  '],
        });
        expect(sut.tags, {'tag1'});
      });
    });
  });
}
