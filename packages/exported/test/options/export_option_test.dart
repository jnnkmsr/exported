import 'package:exported/src/builder/exported_option_keys.dart' as keys;
import 'package:exported/src/model/export.dart';
import 'package:exported/src/validation/show_hide_sanitizer.dart';
import 'package:exported/src/validation/tags_sanitizer.dart';
import 'package:exported/src/validation/uri_sanitizer.dart';
import 'package:mocktail/mocktail.dart';
import 'package:test/test.dart';

void main() {
  group('$Export', () {
    late Export sut;

    late MockExportUriSanitizer mockUriSanitizer;
    late MockShowHideSanitizer mockShowSanitizer;
    late MockShowHideSanitizer mockHideSanitizer;
    late MockTagsSanitizer mockTagsSanitizer;

    setUp(() {
      mockUriSanitizer = MockExportUriSanitizer();
      mockShowSanitizer = MockShowHideSanitizer();
      mockHideSanitizer = MockShowHideSanitizer();
      mockTagsSanitizer = MockTagsSanitizer();
      Export.uriSanitizer = mockUriSanitizer;
      Export.showSanitizer = mockShowSanitizer;
      Export.hideSanitizer = mockHideSanitizer;
      Export.tagsSanitizer = mockTagsSanitizer;
    });

    group('.()', () {
      setUp(() {
        sut = const Export(
          uri: 'foo_bar',
          show: {'Baz', 'Qux'},
          hide: {'Quux', 'Corge'},
          tags: {'grault', 'garply'},
        );
      });

      test('Sanitizes inputs', () {
        verify(() => mockUriSanitizer.sanitize('foo_bar')).called(1);
        verify(() => mockShowSanitizer.sanitize({'Baz', 'Qux'})).called(1);
        verify(() => mockHideSanitizer.sanitize({'Quux', 'Corge'})).called(1);
        verify(() => mockTagsSanitizer.sanitize({'grault', 'garply'})).called(1);
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

class MockExportUriSanitizer with Mock implements UriSanitizer {
  MockExportUriSanitizer() {
    when(() => sanitize(any())).thenAnswer((i) => i.positionalArguments.first as String);
  }
}

class MockTagsSanitizer with Mock implements TagsSanitizer {
  MockTagsSanitizer() {
    when(() => sanitize(any())).thenAnswer(
      (i) => i.positionalArguments.first as Set<String>? ?? {},
    );
  }
}

class MockShowHideSanitizer with Mock implements ShowHideSanitizer {
  MockShowHideSanitizer() {
    when(() => sanitize(any())).thenAnswer(
      (i) => i.positionalArguments.first as Set<String>? ?? {},
    );
  }
}
