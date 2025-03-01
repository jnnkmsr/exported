import 'package:exported/src/model/exported_option_keys.dart' as keys;
import 'package:exported/src/model_legacy/barrel_file.dart';
import 'package:exported/src/model_legacy/export.dart';
import 'package:test/test.dart';

import '../helpers/option_parser_doubles.dart';

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
      mockPathParser.mockParse(null, 'package:foo/foo.dart');

      sut = BarrelFile.packageNamed();

      mockPathParser.verifyParse(null);

      expect(sut.path, 'package:foo/foo.dart');
      expect(sut.tags, isEmpty);
    });
  });

  group('BarrelFile.fromJson()', () {
    test('Creates an instance from sanitized JSON inputs', () {
      mockPathParser.mockParseJson('foo.dart', 'package:foo/foo.dart');
      mockTagsParser.mockParseJson(['foo', 'Foo'], {'foo'});

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
      mockPathParser.mockParse('foo.dart', 'package:foo/foo.dart');

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

  group('buildExports()', () {
    test('Returns an empty list if there are no exports', () {
      sut = const BarrelFile(path: 'foo.dart');
      expect(sut.buildExports([]), isEmpty);
    });

    test('Includes only untagged exports or exports with matching tags', () {
      sut = const BarrelFile(path: 'foo.dart', tags: {'foo', 'bar'});

      const a = Export(uri: 'package:a/a.dart');
      const b = Export(uri: 'package:b/b.dart', tags: {'foo', 'baz'});
      const c = Export(uri: 'package:c/c.dart', tags: {'bar', 'qux'});
      const d = Export(uri: 'package:d/d.dart', tags: {'baz', 'qux'});

      expect(sut.buildExports([a, b, c, d]), [a, b, c]);
    });

    test('Includes all exports if the file has no tags', () {
      sut = const BarrelFile(path: 'foo.dart');

      const a = Export(uri: 'package:a/a.dart');
      const b = Export(uri: 'package:b/b.dart', tags: {'foo', 'baz'});
      const c = Export(uri: 'package:c/c.dart', tags: {'bar', 'qux'});
      const d = Export(uri: 'package:d/d.dart', tags: {'baz', 'qux'});

      expect(sut.buildExports([a, b, c, d]), [a, b, c, d]);
    });

    test('Merges exports with the same URI', () {
      sut = const BarrelFile(path: 'foo.dart');

      const a1 = Export(uri: 'package:a/a.dart', show: {'foo'});
      const a2 = Export(uri: 'package:a/a.dart', show: {'bar'});
      const a3 = Export(uri: 'package:a/a.dart', show: {'baz'});
      final a = a1.merge(a2).merge(a3);
      const b = Export(uri: 'package:b/b.dart', hide: {'qux'});

      expect(sut.buildExports([a1, a2, a3, b]), [a, b]);
    });

    test('Returns exports sorted by URI', () {
      sut = const BarrelFile(path: 'foo.dart');

      const a = Export(uri: 'package:a/a.dart');
      const b = Export(uri: 'package:b/b.dart');
      const c = Export(uri: 'package:c/c.dart');
      const d = Export(uri: 'package:d/d.dart');

      expect(sut.buildExports([d, a, c, b]), [a, b, c, d]);
    });
  });

  group('==()', () {
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
