import 'package:barreled/src/options/export_option.dart';
import 'package:barreled/src/validation/export_uri_sanitizer.dart';
import 'package:mocktail/mocktail.dart';
import 'package:test/test.dart';

void main() {
  group('$ExportOption', () {
    late ExportOption sut;
    late MockExportUriSanitizer mockUriSanitizer;

    setUp(() {
      mockUriSanitizer = MockExportUriSanitizer();
      when(() => mockUriSanitizer.sanitize(any()))
          .thenAnswer((i) => i.positionalArguments.first as String);

      ExportOption.uriSanitizer = mockUriSanitizer;
    });

    group('$ExportOption()', () {
      test('Sanitizes the uri', () {
        sut = ExportOption(uri: 'foo_bar');
        verify(() => mockUriSanitizer.sanitize('foo_bar')).called(1);
      });
    });

    group('$ExportOption.fromJson()', () {
      test('Creates a $ExportOption from JSON', () {
        sut = ExportOption.fromJson(const {
          ExportOption.uriKey: 'foo_bar',
          ExportOption.showKey: ['foo', 'bar'],
          ExportOption.hideKey: ['baz', 'qux'],
          ExportOption.tagsKey: ['tag1', 'tag2'],
        });
        expect(sut.uri, 'foo_bar');
        expect(sut.show, {'foo', 'bar'});
        expect(sut.hide, {'baz', 'qux'});
        expect(sut.tags, {'tag1', 'tag2'});
      });

      test('Sanitizes the uri', () {
        sut = ExportOption.fromJson(const {
          ExportOption.uriKey: 'foo_bar',
        });
        verify(() => mockUriSanitizer.sanitize('foo_bar')).called(1);
      });
    });
  });
}

class MockExportUriSanitizer with Mock implements ExportUriSanitizer {}
