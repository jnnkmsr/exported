import 'package:build/build.dart';
import 'package:exported/src/model/export.dart';
import 'package:exported/src/model/exported_option_keys.dart' as keys;
import 'package:source_gen/source_gen.dart';
import 'package:test/test.dart';

import '../helpers/element_test_doubles.dart';
import '../helpers/exported_reader_test_doubles.dart';
import '../helpers/input_parser_test_doubles.dart';

void main() {
  late Export sut;

  late MockUriParser mockUriParser;
  late MockShowHideParser mockShowParser;
  late MockShowHideParser mockHideParser;
  late MockTagsParser mockTagsParser;

  setUp(() {
    mockUriParser = MockUriParser();
    mockShowParser = MockShowHideParser();
    mockHideParser = MockShowHideParser();
    mockTagsParser = MockTagsParser();

    Export.uriParser = mockUriParser;
    Export.showParser = mockShowParser;
    Export.hideParser = mockHideParser;
    Export.tagsParser = mockTagsParser;
  });

  group('Export.fromAnnotatedElement()', () {
    test('Creates an instance an annotated Element', () {
      final library = AssetId('foo', 'lib/src/foo.dart');
      final element = FakeElement(name: 'Foo');
      final annotation = FakeExportedReader(tags: {'foo', 'bar'});

      mockTagsParser.mockParse({'foo', 'bar'});

      sut = Export.fromAnnotatedElement(library, element, annotation);

      expect(sut.uri, 'package:foo/src/foo.dart');
      expect(sut.show, {'Foo'});
      expect(sut.hide, isEmpty);
      expect(sut.tags, {'foo', 'bar'});
    });

    test('Sanitizes tags', () {
      final library = AssetId('foo', 'lib/src/foo.dart');
      final element = FakeElement(name: 'Foo');
      final annotation = FakeExportedReader(tags: {'Foo', '   bar '});

      mockTagsParser.mockParse({'Foo', '   bar '}, {'foo', 'bar'});

      sut = Export.fromAnnotatedElement(library, element, annotation);

      mockTagsParser.verifyParse({'Foo', '   bar '});
      expect(sut.tags, {'foo', 'bar'});
    });

    test('Throws an InvalidGenerationSourceError for an unnamed element', () {
      final library = AssetId('foo', 'lib/src/foo.dart');
      final element = FakeElement(name: null);
      final annotation = FakeExportedReader(tags: {'foo', 'bar'});

      expect(
        () => Export.fromAnnotatedElement(library, element, annotation),
        throwsA(isA<InvalidGenerationSourceError>()),
      );
    });
  });

  group('Export.fromJson()', () {
    test('Creates an instance from sanitized JSON inputs', () {
      mockUriParser.mockParseJson('foo', 'package:foo/foo.dart');
      mockShowParser.mockParseJson(['  Foo  ', 'Bar'], {'Foo', 'Bar'});
      mockHideParser.mockParseJson([' '], {});
      mockTagsParser.mockParseJson(['foo', 'Foo'], {'foo'});

      sut = Export.fromJson(const {
        keys.uri: 'foo',
        keys.show: ['  Foo  ', 'Bar'],
        keys.hide: [' '],
        keys.tags: ['foo', 'Foo'],
      });

      mockUriParser.verifyParseJson('foo');
      mockShowParser.verifyParseJson({'  Foo  ', 'Bar'});
      mockHideParser.verifyParseJson({' '});
      mockTagsParser.verifyParseJson({'foo', 'Foo'});

      expect(sut.uri, 'package:foo/foo.dart');
      expect(sut.show, {'Foo', 'Bar'});
      expect(sut.hide, isEmpty);
      expect(sut.tags, {'foo'});
    });

    test('Creates an instance without filters/tags from a URI string input', () {
      mockUriParser.mockParse('foo', 'package:foo/foo.dart');

      sut = Export.fromJson('foo');

      mockUriParser.verifyParse('foo');

      expect(sut.uri, 'package:foo/foo.dart');
    });

    test('Only includes `hide` if `show`/`hide` are both specified', () {
      mockUriParser.mockParseJson('package:foo/foo.dart');
      mockShowParser.mockParseJson(['Foo'], {'Foo'});
      mockHideParser.mockParseJson(['Bar'], {'Bar'});
      mockTagsParser.mockParseJson(null, {});

      sut = Export.fromJson(const {
        keys.uri: 'package:foo/foo.dart',
        keys.show: ['Foo'],
        keys.hide: ['Bar'],
      });

      expect(sut.uri, 'package:foo/foo.dart');
      expect(sut.show, isEmpty);
      expect(sut.hide, {'Bar'});
    });

    test('Throws an ArgumentError for invalid options', () {
      expect(
        () => Export.fromJson(const {'invalid': 'option'}),
        throwsArgumentError,
      );
    });
  });

  group('merge()', () {
    const uri = 'package:foo/foo.dart';

    void expectMerge(Export a, Export b, Export expected, {bool commutative = false}) {
      expect(a.merge(b), expected);
      if (commutative) expect(b.merge(a), expected);
    }

    test('Allows merging Exports without filters', () {
      expectMerge(
        const Export(uri: uri),
        const Export(uri: uri),
        const Export(uri: uri),
      );
    });

    test('Merges show filters', () {
      expectMerge(
        const Export(uri: uri, show: {'Foo', 'Bar'}),
        const Export(uri: uri, show: {'Bar', 'Baz'}),
        const Export(uri: uri, show: {'Foo', 'Bar', 'Baz'}),
        commutative: true,
      );
    });

    test('Merging is case-sensitive', () {
      expectMerge(
        const Export(uri: uri, show: {'Foo', 'Bar'}),
        const Export(uri: uri, show: {'foo', 'Bar'}),
        const Export(uri: uri, show: {'foo', 'Foo', 'Bar'}),
        commutative: true,
      );
    });

    test('Removes filters if one export exports the entire library', () {
      expectMerge(
        const Export(uri: uri, show: {'Foo', 'Bar'}),
        const Export(uri: uri),
        const Export(uri: uri),
        commutative: true,
      );
      expectMerge(
        const Export(uri: uri, hide: {'Foo', 'Bar'}),
        const Export(uri: uri),
        const Export(uri: uri),
        commutative: true,
      );
    });

    test('Removes show filters if one export has non-conflicting hide filters', () {
      expectMerge(
        const Export(uri: uri, show: {'Foo', 'Bar'}),
        const Export(uri: uri, hide: {'Baz'}),
        const Export(uri: uri, hide: {'Baz'}),
        commutative: true,
      );
    });

    test('Removes show filters from conflicting hide filters', () {
      expectMerge(
        const Export(uri: uri, show: {'Foo', 'Bar'}),
        const Export(uri: uri, hide: {'Bar', 'Baz'}),
        const Export(uri: uri, hide: {'Baz'}),
        commutative: true,
      );
    });

    test('Keeps only hide filters that are hidden from both exports', () {
      expectMerge(
        const Export(uri: uri, hide: {'Foo', 'Bar'}),
        const Export(uri: uri, hide: {'Bar'}),
        const Export(uri: uri, hide: {'Bar'}),
        commutative: true,
      );
    });

    test('Does not merge Exports with different URIs', () {
      expectMerge(
        const Export(uri: 'package:foo/foo.dart'),
        const Export(uri: 'package:bar/bar.dart'),
        const Export(uri: 'package:foo/foo.dart'),
      );
    });

    test('Does not change tags', () {
      expectMerge(
        const Export(uri: uri, show: {'Foo'}, tags: {'foo'}),
        const Export(uri: uri, show: {'Bar'}, tags: {'bar'}),
        const Export(uri: uri, show: {'Foo', 'Bar'}, tags: {'foo'}),
      );
    });
  });

  group('toDart()', () {
    test('Converts to a Dart export directive', () {
      sut = const Export(uri: 'package:foo/foo.dart');

      expect(sut.toDart(), "export 'package:foo/foo.dart';");
    });

    test('Sorts show filters', () {
      sut = const Export(uri: 'package:foo/foo.dart', show: {'Foo', 'Bar'});

      expect(sut.toDart(), "export 'package:foo/foo.dart' show Bar, Foo;");
    });

    test('Sorts hide filters', () {
      sut = const Export(uri: 'package:foo/foo.dart', hide: {'Foo', 'Bar'});

      expect(sut.toDart(), "export 'package:foo/foo.dart' hide Bar, Foo;");
    });
  });

  group('toJson()', () {
    test('Converts to a JSON map', () {
      sut = const Export(
        uri: 'package:foo/foo.dart',
        show: {'Foo', 'Bar'},
        hide: {'Baz', 'Quux'},
        tags: {'foo', 'bar'},
      );

      expect(sut.toJson(), {
        keys.uri: 'package:foo/foo.dart',
        keys.show: ['Foo', 'Bar'],
        keys.hide: ['Baz', 'Quux'],
        keys.tags: ['foo', 'bar'],
      });
    });
  });

  group('compareTo()', () {
    test('Compares by URI', () {
      const a = Export(uri: 'package:foo/foo.dart');
      const b = Export(uri: 'package:foo/foo.dart');
      const c = Export(uri: 'package:bar/bar.dart');

      expect(a.compareTo(b), 0);
      expect(a.compareTo(c), 1);
      expect(c.compareTo(a), -1);
    });

    test('Ignores show, hide and tags', () {
      const a = Export(uri: 'package:foo/foo.dart', show: {'Foo'}, hide: {'Bar'}, tags: {'foo'});
      const b = Export(uri: 'package:foo/foo.dart', show: {'Bar'}, hide: {'Foo'}, tags: {'bar'});

      expect(a.compareTo(b), 0);
    });
  });

  group('==(), hashCode', () {
    test('Compares by URI', () {
      const a = Export(uri: 'package:foo/foo.dart');
      const b = Export(uri: 'package:foo/foo.dart');
      const c = Export(uri: 'package:bar/bar.dart');

      expect(a, equals(b));
      expect(a, isNot(equals(c)));

      expect(a.hashCode, b.hashCode);
      expect(a.hashCode, isNot(c.hashCode));
    });

    const uri = 'package:foo/foo.dart';

    test('Compares by show, ignoring order', () {
      const a = Export(uri: uri, show: {'Foo', 'Bar'});
      const b = Export(uri: uri, show: {'Bar', 'Foo'});
      const c = Export(uri: uri, show: {'Foo', 'Bar', 'Baz'});

      expect(a, equals(b));
      expect(a, isNot(equals(c)));

      expect(a.hashCode, b.hashCode);
      expect(a.hashCode, isNot(c.hashCode));
    });

    test('Compares by hide, ignoring order', () {
      const a = Export(uri: uri, hide: {'Foo', 'Bar'});
      const b = Export(uri: uri, hide: {'Bar', 'Foo'});
      const c = Export(uri: uri, hide: {'Foo', 'Bar', 'Baz'});

      expect(a, equals(b));
      expect(a, isNot(equals(c)));

      expect(a.hashCode, b.hashCode);
      expect(a.hashCode, isNot(c.hashCode));
    });

    test('Compares by tags, ignoring order', () {
      const a = Export(uri: uri, tags: {'Foo', 'Bar'});
      const b = Export(uri: uri, tags: {'Bar', 'Foo'});
      const c = Export(uri: uri, tags: {'Foo', 'Bar', 'Baz'});

      expect(a, equals(b));
      expect(a, isNot(equals(c)));

      expect(a.hashCode, b.hashCode);
      expect(a.hashCode, isNot(c.hashCode));
    });
  });
}
