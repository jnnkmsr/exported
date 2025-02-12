import 'package:exported/src/builder/exported_option_keys.dart' as keys;
import 'package:exported/src/model/barrel_file.dart';
import 'package:exported/src/model/export.dart';
import 'package:test/test.dart';

import '../helpers/mock_input_parser.dart';

void main() {
  group('BarrelFile', () {
    late BarrelFile sut;

    late MockFilePathParser mockPathParser;
    late MockTagsParser mockTagsParser;

    setUp(() {
      mockPathParser = MockFilePathParser();
      mockTagsParser = MockTagsParser();
      BarrelFile.pathParser = mockPathParser;
      BarrelFile.tagsParser = mockTagsParser;
    });

    group('.packageNamed()', () {
      test('Creates a default package-named BarrelFile without tags', () {
        mockPathParser.whenParse(null, 'package:foo/foo.dart');

        sut = BarrelFile.packageNamed();

        mockPathParser.verifyParse(null);

        expect(sut.path, 'package:foo/foo.dart');
        expect(sut.tags, isEmpty);
      });
    });

    group('.fromJson()', () {
      test('Creates a BarrelFile from sanitized JSON inputs', () {
        mockPathParser.whenParseJson('foo.dart', 'package:foo/foo.dart');
        mockTagsParser.whenParseJson(['foo', 'Foo'], {'foo'});

        sut = BarrelFile.fromJson(const {
          keys.path: 'foo.dart',
          keys.tags: ['foo', 'Foo'],
        });

        mockPathParser.verifyParseJson('foo.dart');
        mockTagsParser.verifyParseJson(['foo', 'Foo']);

        expect(sut.path, 'package:foo/foo.dart');
        expect(sut.tags, {'foo'});
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
