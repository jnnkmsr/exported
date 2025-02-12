import 'package:exported/src/builder/exported_option_keys.dart' as keys;
import 'package:exported/src/model/barrel_file.dart';
import 'package:exported/src/model/export.dart';
import 'package:exported/src/model/exported_options.dart';
import 'package:exported/src/validation/barrel_files_sanitizer.dart';
import 'package:exported/src/validation/exports_sanitizer.dart';
import 'package:mocktail/mocktail.dart';
import 'package:test/test.dart';

void main() {
  group('$ExportedOptions', () {
    late ExportedOptions sut;

    late MockBarrelFilesSanitizer mockFilesSanitizer;
    late MockExportsSanitizer mockExportsSanitizer;

    setUpAll(() {
      registerFallbackValue(const BarrelFile(path: 'foo'));
      registerFallbackValue(const Export(uri: 'foo'));
    });

    setUp(() {
      mockFilesSanitizer = MockBarrelFilesSanitizer();
      mockExportsSanitizer = MockExportsSanitizer();
      ExportedOptions.filesSanitizer = mockFilesSanitizer;
      ExportedOptions.exportsSanitizer = mockExportsSanitizer;
    });

    group('.()', () {
      final files = [const BarrelFile(path: 'foo_bar.dart')];
      final exports = [const Export(uri: 'foo')];

      setUp(() {
        sut = ExportedOptions(files: files, exports: exports);
      });

      test('Sanitizes inputs', () {
        verify(() => mockFilesSanitizer.sanitize(files)).called(1);
        verify(() => mockExportsSanitizer.sanitize(exports)).called(1);
      });
    });

    group('.fromJson()', () {
      final fileJson1 = {keys.path: 'foo_bar.dart'};
      final fileJson2 = {keys.path: 'baz_qux.dart'};
      final exportJson1 = {keys.uri: 'foo'};
      final exportJson2 = {keys.uri: 'bar'};

      final files = [
        BarrelFile.fromJson(fileJson1),
        BarrelFile.fromJson(fileJson2),
      ];
      final exports = [
        Export.fromJson(exportJson1),
        Export.fromJson(exportJson2),
      ];

      setUp(() {
        sut = ExportedOptions.fromJson({
          keys.barrelFiles: [fileJson1, fileJson2],
          keys.exports: [exportJson1, exportJson2],
        });
      });

      test('Creates a $ExportedOptions from JSON', () {
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
      (i) => i.positionalArguments.first as List<BarrelFile>,
    );
  }
}

class MockExportsSanitizer with Mock implements ExportsSanitizer {
  MockExportsSanitizer() {
    when(() => sanitize(any())).thenAnswer(
      (i) => i.positionalArguments.first as List<Export>,
    );
  }
}
