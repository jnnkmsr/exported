import 'package:exported/src/builder/exported_option_keys.dart' as keys;
import 'package:exported/src/model/barrel_file.dart';
import 'package:exported/src/model/export.dart';
import 'package:test/test.dart';

import '../helpers/mock_input_sanitizer.dart';

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
        mockPathSanitizer.whenSanitizeReturn(null, 'package:foo/foo.dart');
        mockTagsSanitizer.whenSanitizeReturn(null, {});

        sut = BarrelFile.packageNamed();

        mockPathSanitizer.verifySanitized(null);
        mockTagsSanitizer.verifySanitized(null);

        expect(sut.path, 'package:foo/foo.dart');
        expect(sut.tags, isEmpty);
      });
    });

    group('.fromJson()', () {
      test('Creates a BarrelFile from sanitized JSON inputs', () {
        mockPathSanitizer.whenSanitizeReturn('foo.dart', 'package:foo/foo.dart');
        mockTagsSanitizer.whenSanitizeReturn({'foo', 'Foo'}, {'foo'});

        sut = BarrelFile.fromJson(const {
          keys.path: 'foo.dart',
          keys.tags: ['foo', 'Foo'],
        });

        mockPathSanitizer.verifySanitized('foo.dart');
        mockTagsSanitizer.verifySanitized({'foo', 'Foo'});

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
