import 'package:barreled/src/util/pubspec_reader.dart';
import 'package:file/file.dart';
import 'package:file/memory.dart';
import 'package:pub_semver/pub_semver.dart';
import 'package:test/test.dart';

const packageName = 'test_library';

// TODO: Rewrite test scenarios for `PubspecReader`.

void main() {
  group('$PubspecReader', () {
    late PubspecReader sut;
    late FileSystem fileSystem;

    setUp(() {
      fileSystem = MemoryFileSystem.test();
      sut = PubspecReader(fileSystem: fileSystem);
    });

    group('Given a pubspec.yaml file exists', () {
      late File pubspecFile;

      setUp(() => pubspecFile = fileSystem.file('pubspec.yaml'));

      group('And contains a name and environment:sdk fields', () {
        const packageName = 'test_library';
        const dartVersion = '^3.6.1';

        setUp(() {
          pubspecFile.writeAsStringSync(
            'name: $packageName\n'
            'environment:\n'
            '  sdk: $dartVersion\n',
          );
        });

        group('When packageName is read', () {
          test('Then returns the package name', () {
            expect(sut.packageName, equals(packageName));
          });
        });

        group('When dartVersion is read', () {
          test('Then returns the Dart SDK version', () {
            expect(sut.dartVersion, equals(VersionConstraint.parse(dartVersion)));
          });
        });
      });

      group('And is empty', () {
        setUp(() => pubspecFile.writeAsStringSync(''));

        group('When packageName is read', () {
          test('Then throws a FormatException', () {
            expect(() => sut.packageName, throwsA(isA<FormatException>()));
          });
        });

        group('When dartVersion is read', () {
          test('Then throws a FormatException', () {
            expect(() => sut.dartVersion, throwsA(isA<FormatException>()));
          });
        });
      });

      group('And contains no name and environment:sdk fields', () {
        setUp(() => pubspecFile.writeAsStringSync('version: 1.0'));

        group('When packageName is read', () {
          test('Then throws a FormatException', () {
            expect(() => sut.packageName, throwsA(isA<FormatException>()));
          });
        });

        group('When dartVersion is read', () {
          test('Then throws a FormatException', () {
            expect(() => sut.dartVersion, throwsA(isA<FormatException>()));
          });
        });
      });

      group('And contains invalid yaml', () {
        setUp(() => pubspecFile.writeAsStringSync('Non-YAML content'));

        group('When packageName is read', () {
          test('Then throws a FormatException', () {
            expect(() => sut.packageName, throwsA(isA<FormatException>()));
          });
        });
        
        group('When dartVersion is read', () {
          test('Then throws a FormatException', () {
            expect(() => sut.dartVersion, throwsA(isA<FormatException>()));
          });
        });
      });
    });

    group('Given a pubspec.yaml file does not exist', () {
      group('When packageName is read', () {
        test('Then throws a FileSystemException', () {
          expect(() => sut.packageName, throwsA(isA<FileSystemException>()));
        });
      });
      
      group('When dartVersion is read', () {
        test('Then throws a FileSystemException', () {
          expect(() => sut.dartVersion, throwsA(isA<FileSystemException>()));
        });
      });
    });
  });
}
