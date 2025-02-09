import 'package:barreled/src/options/export_option.dart';
import 'package:barreled/src/validation/export_uri_sanitizer.dart';
import 'package:barreled/src/validation/show_hide_sanitizer.dart';
import 'package:barreled/src/validation/tags_sanitizer.dart';
import 'package:mocktail/mocktail.dart';
import 'package:test/test.dart';

void main() {
  group('$ExportOption', () {
    late ExportOption sut;

    late MockExportUriSanitizer mockUriSanitizer;
    late MockShowHideSanitizer mockShowSanitizer;
    late MockShowHideSanitizer mockHideSanitizer;
    late MockTagsSanitizer mockTagsSanitizer;

    setUp(() {
      mockUriSanitizer = MockExportUriSanitizer();
      mockShowSanitizer = MockShowHideSanitizer();
      mockHideSanitizer = MockShowHideSanitizer();
      mockTagsSanitizer = MockTagsSanitizer();
      ExportOption.uriSanitizer = mockUriSanitizer;
      ExportOption.showSanitizer = mockShowSanitizer;
      ExportOption.hideSanitizer = mockHideSanitizer;
      ExportOption.tagsSanitizer = mockTagsSanitizer;
    });

    group('.()', () {
      setUp(() {
        sut = ExportOption(
          uri: 'foo_bar',
          show: const {'Baz', 'Qux'},
          hide: const {'Quux', 'Corge'},
          tags: const {'grault', 'garply'},
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
        sut = ExportOption.fromJson(const {
          ExportOption.uriKey: 'foo_bar',
          ExportOption.showKey: ['Baz', 'Qux'],
          ExportOption.hideKey: ['Quux', 'Corge'],
          ExportOption.tagsKey: ['grault', 'garply'],
        });
      });

      test('Creates a $ExportOption from JSON', () {
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
      test('Compares two $ExportOption instances by URI', () {
        final a = ExportOption(uri: 'foo');
        final b = ExportOption(uri: 'foo');
        final c = ExportOption(uri: 'bar');

        expect(a, equals(b));
        expect(a, isNot(equals(c)));

        expect(a.hashCode, b.hashCode);
        expect(a.hashCode, isNot(c.hashCode));
      });

      test('Compares two $ExportOption instances by show, ignoring order', () {
        final a = ExportOption(uri: 'foo', show: const {'bar', 'baz'});
        final b = ExportOption(uri: 'foo', show: const {'baz', 'bar'});
        final c = ExportOption(uri: 'foo', show: const {'bar', 'baz', 'qux'});

        expect(a, equals(b));
        expect(a, isNot(equals(c)));

        expect(a.hashCode, b.hashCode);
        expect(a.hashCode, isNot(c.hashCode));
      });

      test('Compares two $ExportOption instances by hide, ignoring order', () {
        final a = ExportOption(uri: 'foo', hide: const {'bar', 'baz'});
        final b = ExportOption(uri: 'foo', hide: const {'baz', 'bar'});
        final c = ExportOption(uri: 'foo', hide: const {'bar', 'baz', 'qux'});

        expect(a, equals(b));
        expect(a, isNot(equals(c)));

        expect(a.hashCode, b.hashCode);
        expect(a.hashCode, isNot(c.hashCode));
      });

      test('Compares two $ExportOption instances by tags, ignoring order', () {
        final a = ExportOption(uri: 'foo', tags: const {'bar', 'baz'});
        final b = ExportOption(uri: 'foo', tags: const {'baz', 'bar'});
        final c = ExportOption(uri: 'foo', tags: const {'bar', 'baz', 'qux'});

        expect(a, equals(b));
        expect(a, isNot(equals(c)));

        expect(a.hashCode, b.hashCode);
        expect(a.hashCode, isNot(c.hashCode));
      });
    });
  });
}

class MockExportUriSanitizer with Mock implements ExportUriSanitizer {
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
