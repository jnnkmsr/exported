import 'package:barreled/src/options/barrel_file_option.dart';
import 'package:barreled/src/options/barreled_options.dart';
import 'package:barreled/src/options/export_option.dart';
import 'package:barreled/src/validation/barrel_files_sanitizer.dart';
import 'package:barreled/src/validation/exports_sanitizer.dart';
import 'package:mocktail/mocktail.dart';
import 'package:test/test.dart';

void main() {
  group('$BarreledOptions', () {
    late BarreledOptions sut;

    late MockBarrelFilesSanitizer mockFilesSanitizer;
    late MockExportsSanitizer mockExportsSanitizer;

    setUpAll(() {
      registerFallbackValue(BarrelFileOption());
      registerFallbackValue(ExportOption(uri: 'foo'));
    });

    setUp(() {
      mockFilesSanitizer = MockBarrelFilesSanitizer();
      mockExportsSanitizer = MockExportsSanitizer();
      BarreledOptions.filesSanitizer = mockFilesSanitizer;
      BarreledOptions.exportsSanitizer = mockExportsSanitizer;
    });

    group('.()', () {
      final files = [BarrelFileOption(file: 'foo_bar.dart')];
      final exports = [ExportOption(uri: 'foo')];

      setUp(() {
        sut = BarreledOptions(files: files, exports: exports);
      });

      test('Sanitizes inputs', () {
        verify(() => mockFilesSanitizer.sanitize(files)).called(1);
        verify(() => mockExportsSanitizer.sanitize(exports)).called(1);
      });
    });

    group('.fromJson()', () {
      final fileJson1 = {BarrelFileOption.fileKey: 'foo_bar.dart'};
      final fileJson2 = {BarrelFileOption.fileKey: 'baz_qux.dart'};
      final exportJson1 = {ExportOption.uriKey: 'foo'};
      final exportJson2 = {ExportOption.uriKey: 'bar'};

      final files = [
        BarrelFileOption.fromJson(fileJson1),
        BarrelFileOption.fromJson(fileJson2),
      ];
      final exports = [
        ExportOption.fromJson(exportJson1),
        ExportOption.fromJson(exportJson2),
      ];

      setUp(() {
        sut = BarreledOptions.fromJson({
          BarreledOptions.filesKey: [fileJson1, fileJson2],
          BarreledOptions.exportsKey: [exportJson1, exportJson2],
        });
      });

      test('Creates a $BarreledOptions from JSON', () {
        expect(sut.files, files);
        expect(sut.exports, exports);
      });

      test('Sanitizes inputs', () {
        verify(() => mockFilesSanitizer.sanitize(files)).called(1);
        verify(() => mockExportsSanitizer.sanitize(exports)).called(1);
      });
    });
  });
}

class MockBarrelFilesSanitizer with Mock implements BarrelFilesSanitizer {
  MockBarrelFilesSanitizer() {
    when(() => sanitize(any())).thenAnswer(
      (i) => i.positionalArguments.first as List<BarrelFileOption>,
    );
  }
}

class MockExportsSanitizer with Mock implements ExportsSanitizer {
  MockExportsSanitizer() {
    when(() => sanitize(any())).thenAnswer(
      (i) => i.positionalArguments.first as List<ExportOption>,
    );
  }
}
