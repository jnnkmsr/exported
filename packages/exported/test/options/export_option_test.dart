import 'package:build/build.dart';
import 'package:exported/src/builder/exported_option_keys.dart' as keys;
import 'package:exported/src/model/export.dart';
import 'package:mocktail/mocktail.dart';
import 'package:source_gen/source_gen.dart';
import 'package:test/test.dart';

import '../helpers/fake_element.dart';
import '../helpers/fake_exported_reader.dart';
import '../helpers/mock_input_sanitizer.dart';

void main() {
  group('Export', () {
    late Export sut;

    late MockUriSanitizer mockUriSanitizer;
    late MockShowHideSanitizer mockShowSanitizer;
    late MockShowHideSanitizer mockHideSanitizer;
    late MockTagsSanitizer mockTagsSanitizer;

    setUp(() {
      mockUriSanitizer = MockUriSanitizer();
      mockShowSanitizer = MockShowHideSanitizer();
      mockHideSanitizer = MockShowHideSanitizer();
      mockTagsSanitizer = MockTagsSanitizer();
      Export.uriSanitizer = mockUriSanitizer;
      Export.showSanitizer = mockShowSanitizer;
      Export.hideSanitizer = mockHideSanitizer;
      Export.tagsSanitizer = mockTagsSanitizer;
    });

    group('.fromAnnotatedElement()', () {
      test('Creates an Export an annotated Element', () {
        final library = AssetId('foo', 'lib/src/foo.dart');
        final element = FakeElement(name: 'Foo');
        final annotation = FakeExportedReader(tags: {'foo', 'bar'});

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

        mockTagsSanitizer.whenSanitizeReturn({'Foo', '   bar '}, {'foo', 'bar'});

        sut = Export.fromAnnotatedElement(library, element, annotation);

        mockTagsSanitizer.verifySanitized({'Foo', '   bar '});
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

    group('.fromJson()', () {
      setUp(() {
        sut = Export.fromJson(const {
          keys.uri: 'foo_bar',
          keys.show: ['Baz', 'Qux'],
          keys.hide: ['Quux', 'Corge'],
          keys.tags: ['grault', 'garply'],
        });
      });

      test('Creates an $Export instance from JSON', () {
        expect(sut.uri, 'foo_bar');
        expect(sut.show, {'Baz', 'Qux'});
        expect(sut.hide, {'Quux', 'Corge'});
        expect(sut.tags, {'grault', 'garply'});
      });

      test('Sanitizes inputs', () {
        verify(() => mockUriSanitizer.sanitize('foo_bar')).called(1);
        verify(() => mockShowSanitizer.sanitize({'Baz', 'Qux'})).called(1);
        verify(() => mockHideSanitizer.sanitize({'Quux', 'Corge'})).called(1);
        verify(() => mockTagsSanitizer.sanitize({'grault', 'garply'})).called(1);
      });
    });

    group('.==()', () {
      test('Compares two $Export instances by URI', () {
        const a = Export(uri: 'foo');
        const b = Export(uri: 'foo');
        const c = Export(uri: 'bar');

        expect(a, equals(b));
        expect(a, isNot(equals(c)));

        expect(a.hashCode, b.hashCode);
        expect(a.hashCode, isNot(c.hashCode));
      });

      test('Compares two $Export instances by show, ignoring order', () {
        const a = Export(uri: 'foo', show: {'bar', 'baz'});
        const b = Export(uri: 'foo', show: {'baz', 'bar'});
        const c = Export(uri: 'foo', show: {'bar', 'baz', 'qux'});

        expect(a, equals(b));
        expect(a, isNot(equals(c)));

        expect(a.hashCode, b.hashCode);
        expect(a.hashCode, isNot(c.hashCode));
      });

      test('Compares two $Export instances by hide, ignoring order', () {
        const a = Export(uri: 'foo', hide: {'bar', 'baz'});
        const b = Export(uri: 'foo', hide: {'baz', 'bar'});
        const c = Export(uri: 'foo', hide: {'bar', 'baz', 'qux'});

        expect(a, equals(b));
        expect(a, isNot(equals(c)));

        expect(a.hashCode, b.hashCode);
        expect(a.hashCode, isNot(c.hashCode));
      });

      test('Compares two $Export instances by tags, ignoring order', () {
        const a = Export(uri: 'foo', tags: {'bar', 'baz'});
        const b = Export(uri: 'foo', tags: {'baz', 'bar'});
        const c = Export(uri: 'foo', tags: {'bar', 'baz', 'qux'});

        expect(a, equals(b));
        expect(a, isNot(equals(c)));

        expect(a.hashCode, b.hashCode);
        expect(a.hashCode, isNot(c.hashCode));
      });
    });
  });
}
