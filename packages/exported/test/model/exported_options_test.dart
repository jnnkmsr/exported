import 'package:exported/src/builder/exported_option_keys.dart' as keys;
import 'package:exported/src/model/barrel_file.dart';
import 'package:exported/src/model/export.dart';
import 'package:exported/src/model/exported_options.dart';
import 'package:exported/src/validation/barrel_files_parser.dart';
import 'package:exported/src/validation/exports_parser.dart';
import 'package:mocktail/mocktail.dart';
import 'package:test/test.dart';

void main() {
  group('$ExportedOptions', () {
    late ExportedOptions sut;

    late MockBarrelFilesParser mockFilesParser;
    late MockExportsParser mockExportsParser;

    setUpAll(() {
      registerFallbackValue(const BarrelFile(path: 'foo'));
      registerFallbackValue(const Export(uri: 'foo'));
    });

    setUp(() {
      mockFilesParser = MockBarrelFilesParser();
      mockExportsParser = MockExportsParser();
      ExportedOptions.filesParser = mockFilesParser;
      ExportedOptions.exportsParser = mockExportsParser;
    });

    group('.()', () {
      final files = [const BarrelFile(path: 'foo_bar.dart')];
      final exports = [const Export(uri: 'foo')];

      setUp(() {
        sut = ExportedOptions(files: files, exports: exports);
      });

      test('Sanitizes inputs', () {
        verify(() => mockFilesParser.parse(files)).called(1);
        verify(() => mockExportsParser.parse(exports)).called(1);
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
        verify(() => mockFilesParser.parse(files)).called(1);
        verify(() => mockExportsParser.parse(exports)).called(1);
      });
    });
  });
}

class MockBarrelFilesParser with Mock implements BarrelFilesParser {
  MockBarrelFilesParser() {
    when(() => parse(any())).thenAnswer(
      (i) => i.positionalArguments.first as List<BarrelFile>,
    );
  }
}

class MockExportsParser with Mock implements ExportsParser {
  MockExportsParser() {
    when(() => parse(any())).thenAnswer(
      (i) => i.positionalArguments.first as List<Export>,
    );
  }
}
