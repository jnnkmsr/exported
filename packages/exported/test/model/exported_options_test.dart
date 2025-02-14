import 'package:build/build.dart';
import 'package:exported/src/model/barrel_file.dart';
import 'package:exported/src/model/export.dart';
import 'package:exported/src/model/exported_option_keys.dart' as keys;
import 'package:exported/src/model/exported_options.dart';
import 'package:test/test.dart';

import '../helpers/mock_input_parser.dart';

void main() {
  late ExportedOptions sut;

  late MockBarrelFilesParser mockBarrelFilesParser;
  late MockExportsParser mockExportsParser;

  setUp(() {
    mockBarrelFilesParser = MockBarrelFilesParser();
    mockExportsParser = MockExportsParser();
    ExportedOptions.filesParser = mockBarrelFilesParser;
    ExportedOptions.exportsParser = mockExportsParser;
  });

  group('ExportedOptions.defaults()', () {
    test('Creates ExportedOptions with the default file and no exports', () {
      const defaultBarrelFile = BarrelFile(path: 'foo.dart');

      mockBarrelFilesParser.whenParse(null, [defaultBarrelFile]);
      mockExportsParser.whenParse(null, []);

      sut = ExportedOptions.defaults();

      expect(sut.barrelFiles, [defaultBarrelFile]);
      expect(sut.exports, isEmpty);
    });
  });

  group('ExportedOptions.fromOptions()', () {
    test('Creates default ExportedOptions from empty builder options', () {
      const defaultBarrelFile = BarrelFile(path: 'foo.dart');

      mockBarrelFilesParser.whenParseJson(null, [defaultBarrelFile]);
      mockExportsParser.whenParseJson(null, []);

      sut = ExportedOptions.fromOptions(BuilderOptions.empty);

      expect(sut.barrelFiles, [defaultBarrelFile]);
      expect(sut.exports, isEmpty);
    });

    test('Creates ExportedOptions from sanitized builder options', () {
      const barrelFilesJson = [
        {keys.path: 'foo.dart'},
        {keys.path: 'bar.dart'},
        {keys.path: 'baz.dart'},
      ];
      const exportsJson = [
        {keys.uri: 'foo'},
        {keys.uri: 'bar'},
        {keys.uri: 'baz'},
      ];
      final barrelFiles = [for (final json in barrelFilesJson) BarrelFile.fromJson(json)];
      final exports = [for (final json in exportsJson) Export.fromJson(json)];

      mockBarrelFilesParser.whenParseJson(barrelFilesJson, barrelFiles);
      mockExportsParser.whenParseJson(exportsJson, exports);

      sut = ExportedOptions.fromOptions(
        const BuilderOptions({
          keys.barrelFiles: barrelFilesJson,
          keys.exports: exportsJson,
        }),
      );

      mockBarrelFilesParser.verifyParseJson(barrelFilesJson);
      mockExportsParser.verifyParseJson(exportsJson);

      expect(sut.barrelFiles, barrelFiles);
      expect(sut.exports, exports);
    });

    test('Throws an ArgumentError for invalid builder options', () {
      expect(
        () => ExportedOptions.fromOptions(const BuilderOptions({'invalid': 'option'})),
        throwsArgumentError,
      );
    });
  });
}
