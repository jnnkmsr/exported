import 'package:exported/src/builder/exported_option_keys.dart' as keys;
import 'package:exported/src/model/barrel_file.dart';
import 'package:exported/src/model/export.dart';
import 'package:exported/src/validation/file_path_sanitizer.dart';
import 'package:exported/src/validation/tags_sanitizer.dart';
import 'package:mocktail/mocktail.dart';
import 'package:test/test.dart';

void main() {
  group('BarrelFile', () {
    late BarrelFile sut;

    late MockFilePathSanitizer mockPathSanitizer;
    late MockTagsSanitizer mockTagsSanitizer;

    setUp(() {
      mockPathSanitizer = MockFilePathSanitizer();
      mockTagsSanitizer = MockTagsSanitizer();
      BarrelFile.pathSanitizer = mockPathSanitizer;
      BarrelFile.tagsSanitizer = mockTagsSanitizer;
    });

    group('.packageNamed()', () {
      test('Creates a default package-named BarrelFile without tags', () {
        when(() => mockPathSanitizer.sanitize(null)).thenReturn('package:foo/foo.dart');
        when(() => mockTagsSanitizer.sanitize(null)).thenReturn({});

        sut = BarrelFile.packageNamed();

        verify(() => mockPathSanitizer.sanitize(null)).called(1);
        verify(() => mockTagsSanitizer.sanitize(null)).called(1);

        expect(sut.path, 'package:foo/foo.dart');
        expect(sut.tags, isEmpty);
      });
    });

    group('.fromJson()', () {
      test('Creates a BarrelFile from sanitized JSON inputs', () {
        when(() => mockPathSanitizer.sanitize('foo.dart')).thenReturn('package:foo/foo.dart');
        when(() => mockTagsSanitizer.sanitize({'foo', 'Foo'})).thenReturn({'foo'});

        sut = BarrelFile.fromJson(const {
          keys.path: 'foo.dart',
          keys.tags: ['foo', 'Foo'],
        });

        verify(() => mockPathSanitizer.sanitize('foo.dart')).called(1);
        verify(() => mockTagsSanitizer.sanitize({'foo', 'Foo'})).called(1);

        expect(sut.path, 'package:foo/foo.dart');
        expect(sut.tags, {'foo'});
      });

      test('Throws ArgumentError for invalid types', () {
        expect(() => BarrelFile.fromJson(const {keys.path: 123}), throwsA(isA<ArgumentError>()));
        expect(() => BarrelFile.fromJson(const {keys.tags: 123}), throwsA(isA<ArgumentError>()));
      });
    });

    group('.shouldInclude()', () {
      test('Returns true if neither the barrel file nor the export are tagged', () {
        sut = const BarrelFile(path: 'foo');
        const export = Export(uri: 'foo');
        expect(sut.shouldInclude(export), isTrue);
      });

      test('Returns true if the barrel file is not tagged', () {
        sut = const BarrelFile(path: 'foo');
        const export = Export(uri: 'foo', tags: {'foo'});
        expect(sut.shouldInclude(export), isTrue);
      });

      test('Returns true if the export is not tagged', () {
        sut = const BarrelFile(path: 'foo', tags: {'foo'});
        const export = Export(uri: 'foo');
        expect(sut.shouldInclude(export), isTrue);
      });

      test('Returns true if there is a matching tag', () {
        sut = const BarrelFile(path: 'foo', tags: {'foo', 'bar'});
        const export = Export(uri: 'foo', tags: {'bar', 'baz'});
        expect(sut.shouldInclude(export), isTrue);
      });

      test('Returns false if there are no matching tags', () {
        sut = const BarrelFile(path: 'foo', tags: {'foo', 'bar'});
        const export = Export(uri: 'foo', tags: {'baz', 'qux'});
        expect(sut.shouldInclude(export), isFalse);
      });
    });

    group('.==() and .hashCode', () {
      test('Compares two BarrelFile instances by path', () {
        const a = BarrelFile(path: 'foo');
        const b = BarrelFile(path: 'foo');
        const c = BarrelFile(path: 'bar');

        expect(a, equals(b));
        expect(a, isNot(equals(c)));

        expect(a.hashCode, b.hashCode);
        expect(a.hashCode, isNot(c.hashCode));
      });

      test('Compares two BarrelFile instances by tags, ignoring order', () {
        const a = BarrelFile(path: 'foo', tags: {'foo', 'bar'});
        const b = BarrelFile(path: 'foo', tags: {'bar', 'foo'});
        const c = BarrelFile(path: 'foo', tags: {'foo', 'bar', 'baz'});

        expect(a, equals(b));
        expect(a, isNot(equals(c)));

        expect(a.hashCode, b.hashCode);
        expect(a.hashCode, isNot(c.hashCode));
      });
    });
  });
}

class MockFilePathSanitizer extends Mock implements FilePathSanitizer {
  MockFilePathSanitizer() {
    when(() => sanitize(any())).thenReturn('');
  }
}

class MockTagsSanitizer extends Mock implements TagsSanitizer {
  MockTagsSanitizer() {
    when(() => sanitize(any())).thenReturn(const {});
  }
}
