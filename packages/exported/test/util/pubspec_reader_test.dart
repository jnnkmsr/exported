import 'package:exported/src/util/pubspec_reader.dart';
import 'package:file/file.dart';
import 'package:file/memory.dart';
import 'package:test/test.dart';

void main() {
  group('PubspecReader', () {
    late PubspecReader sut;

    late File pubspecFile;
    late FileSystem fileSystem;

    setUp(() {
      fileSystem = MemoryFileSystem.test();
      sut = PubspecReader(fileSystem);
    });

    group('Valid pubspec.yaml', () {
      setUp(() => pubspecFile = fileSystem.file('pubspec.yaml'));

      group('name', () {
        test('Reads the package name from the `name` field', () {
          pubspecFile.writeAsStringSync('name: foo\n');
          expect(sut.name, equals('foo'));
        });
      });
    });

    group('Invalid pubspec.yaml', () {
      setUp(() => pubspecFile = fileSystem.file('pubspec.yaml'));

      test('Throws a FormatException if the pubspec.yaml has missing fields', () {
        pubspecFile.writeAsStringSync('version: 1.0.0\n');
        expect(() => sut.name, throwsA(isA<FormatException>()));
      });

      test('Throws a FormatException if the pubspec.yaml contains invalid YAML', () {
        pubspecFile.writeAsStringSync('Non-YAML content');
        expect(() => sut.name, throwsA(isA<FormatException>()));
      });
    });

    group('No pubspec.yaml', () {
      test('Throws a FileSystemException when attempting to read values', () {
        expect(() => sut.name, throwsA(isA<FileSystemException>()));
      });
    });
  });
}
