import 'package:exported/src/model/barrel_file.dart';
import 'package:exported/src/model/export.dart';
import 'package:exported/src/model/exported_option_keys.dart' as keys;
import 'package:test/test.dart';

import '../helpers/mock_input_parser.dart';

// TODO[BarrelFile]: Set up mocks in every test.

void main() {
  late BarrelFile sut;

  late MockFilePathParser mockPathParser;
  late MockTagsParser mockTagsParser;

  setUp(() {
    mockPathParser = MockFilePathParser();
    mockTagsParser = MockTagsParser();
    BarrelFile.pathParser = mockPathParser;
    BarrelFile.tagsParser = mockTagsParser;
  });

  group('BarrelFile.packageNamed()', () {
    test('Creates a default package-named instance without tags', () {
      mockPathParser.whenParse(null, 'package:foo/foo.dart');

      sut = BarrelFile.packageNamed();

      mockPathParser.verifyParse(null);

      expect(sut.path, 'package:foo/foo.dart');
      expect(sut.tags, isEmpty);
    });
  });

  group('BarrelFile.fromJson()', () {
    test('Creates an instance from sanitized JSON inputs', () {
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

    test('Creates an instance without tags from a path string input', () {
      mockPathParser.whenParse('foo.dart', 'package:foo/foo.dart');

      sut = BarrelFile.fromJson('foo.dart');

      mockPathParser.verifyParse('foo.dart');

      expect(sut.path, 'package:foo/foo.dart');
      expect(sut.tags, isEmpty);
    });

    test('Throws an ArgumentError for invalid options', () {
      expect(
        () => BarrelFile.fromJson(const {'invalid': 'option'}),
        throwsArgumentError,
      );
    });
  });

  group('shouldInclude()', () {
    const path = 'foo.dart';
    const uri = 'package:foo/foo.dart';

    test('Returns true if neither the BarrelFile nor the Export are tagged', () {
      sut = const BarrelFile(path: path);
      const export = Export(uri: uri);
      expect(sut.shouldInclude(export), isTrue);
    });

    test('Returns true if the BarrelFile is not tagged', () {
      sut = const BarrelFile(path: path);
      const export = Export(uri: uri, tags: {'foo'});
      expect(sut.shouldInclude(export), isTrue);
    });

    test('Returns true if the Export is not tagged', () {
      sut = const BarrelFile(path: path, tags: {'foo'});
      const export = Export(uri: uri);
      expect(sut.shouldInclude(export), isTrue);
    });

    test('Returns true if there is a matching tag', () {
      sut = const BarrelFile(path: path, tags: {'foo', 'bar'});
      const export = Export(uri: uri, tags: {'bar', 'baz'});
      expect(sut.shouldInclude(export), isTrue);
    });

    test('Returns false if there are no matching tags', () {
      sut = const BarrelFile(path: path, tags: {'foo', 'bar'});
      const export = Export(uri: uri, tags: {'baz', 'qux'});
      expect(sut.shouldInclude(export), isFalse);
    });
  });

  group('==(), hashCode', () {
    test('Compares by path', () {
      const a = BarrelFile(path: 'foo.dart');
      const b = BarrelFile(path: 'foo.dart');
      const c = BarrelFile(path: 'bar.dart');

      expect(a, equals(b));
      expect(a, isNot(equals(c)));

      expect(a.hashCode, b.hashCode);
      expect(a.hashCode, isNot(c.hashCode));
    });

    test('Compares by tags, ignoring order', () {
      const path = 'foo.dart';
      const a = BarrelFile(path: path, tags: {'foo', 'bar'});
      const b = BarrelFile(path: path, tags: {'bar', 'foo'});
      const c = BarrelFile(path: path, tags: {'foo', 'bar', 'baz'});

      expect(a, equals(b));
      expect(a, isNot(equals(c)));

      expect(a.hashCode, b.hashCode);
      expect(a.hashCode, isNot(c.hashCode));
    });
  });
}
