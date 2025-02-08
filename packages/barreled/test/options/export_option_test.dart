import 'package:barreled/src/options/package_export_option.dart';
import 'package:barreled/src/validation/export_uri_sanitizer.dart';
import 'package:mocktail/mocktail.dart';
import 'package:test/test.dart';

void main() {
  group('$PackageExportOption', () {
    late PackageExportOption sut;
    late MockExportUriSanitizer mockUriSanitizer;

    setUp(() {
      mockUriSanitizer = MockExportUriSanitizer();
      when(() => mockUriSanitizer.sanitize(any()))
          .thenAnswer((i) => i.positionalArguments.first as String);

      PackageExportOption.packageSanitizer = mockUriSanitizer;
    });

    group('PackageExportOption()', () {
      test('Sanitizes the uri', () {
        sut = PackageExportOption(package: 'foo_bar');
        verify(() => mockUriSanitizer.sanitize('foo_bar')).called(1);
      });
    });

    group('PackageExportOption.fromJson()', () {
      test('Creates a PackageExportOption from JSON', () {
        sut = PackageExportOption.fromJson(const {
          PackageExportOption.packageKey: 'foo_bar',
          PackageExportOption.showKey: ['foo', 'bar'],
          PackageExportOption.hideKey: ['baz', 'qux'],
          PackageExportOption.tagsKey: ['tag1', 'tag2'],
        });
        expect(sut.package, 'foo_bar');
        expect(sut.show, {'foo', 'bar'});
        expect(sut.hide, {'baz', 'qux'});
        expect(sut.tags, {'tag1', 'tag2'});
      });

      test('Sanitizes the uri', () {
        sut = PackageExportOption.fromJson(const {
          PackageExportOption.packageKey: 'foo_bar',
        });
        verify(() => mockUriSanitizer.sanitize('foo_bar')).called(1);
      });
    });
  });
}

class MockExportUriSanitizer with Mock implements ExportUriSanitizer {}
