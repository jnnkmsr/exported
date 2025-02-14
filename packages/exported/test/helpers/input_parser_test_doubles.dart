import 'package:exported/src/model/barrel_file.dart';
import 'package:exported/src/model/export.dart';
import 'package:exported/src/validation/barrel_files_parser.dart';
import 'package:exported/src/validation/exports_parser.dart';
import 'package:exported/src/validation/file_path_parser.dart';
import 'package:exported/src/validation/input_parser.dart';
import 'package:exported/src/validation/show_hide_parser.dart';
import 'package:exported/src/validation/tags_parser.dart';
import 'package:exported/src/validation/uri_parser.dart';
import 'package:mocktail/mocktail.dart';

class MockBarrelFilesParser extends MockInputParser<List<BarrelFile>>
    implements BarrelFilesParser {}

class MockExportsParser extends MockInputParser<List<Export>> implements ExportsParser {}

class MockFilePathParser extends MockInputParser<String> implements FilePathParser {}

class MockShowHideParser extends MockInputParser<Set<String>> implements ShowHideParser {}

class MockTagsParser extends MockInputParser<Set<String>> implements TagsParser {}

class MockUriParser extends MockInputParser<String> implements UriParser {}

abstract class MockInputParser<InputType> extends Mock implements InputParser<InputType> {
  void mockParse(InputType? input, [InputType? output]) {
    when(() => parse(input)).thenReturn(output ?? input!);
  }

  void mockParseJson(dynamic input, [InputType? output]) {
    when(() => parseJson(input)).thenReturn(output ?? input as InputType);
  }

  void verifyParse(InputType? input) {
    verify(() => parse(input)).called(1);
  }

  void verifyParseJson(dynamic input) {
    verify(() => parseJson(input)).called(1);
  }
}
