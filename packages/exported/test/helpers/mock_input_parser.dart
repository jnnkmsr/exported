import 'package:exported/src/validation/file_path_parser.dart';
import 'package:exported/src/validation/input_parser.dart';
import 'package:exported/src/validation/show_hide_parser.dart';
import 'package:exported/src/validation/tags_parser.dart';
import 'package:exported/src/validation/uri_parser.dart';
import 'package:meta/meta.dart';
import 'package:mocktail/mocktail.dart';

class MockFilePathParser extends MockStringParser implements FilePathParser {}

class MockShowHideParser extends MockStringSetParser implements ShowHideParser {}

class MockTagsParser extends MockStringSetParser implements TagsParser {}

class MockUriParser extends MockStringParser implements UriParser {}

abstract class MockStringParser extends MockInputParser<String, String> {
  @override
  String get fallback => '';
}

abstract class MockStringSetParser extends MockInputParser<Set<String>, List<String>>
    implements StringSetParser {
  MockStringSetParser() {
    when(() => parseJson(any<List<String>>())).thenAnswer(_parsedJsonInputOrDefault);
  }

  @override
  Set<String> get fallback => const {};

  Set<String> _parsedJsonInputOrDefault(Invocation invocation) =>
      (invocation.positionalArguments.first as List<String>?)?.toSet() ?? fallback;
}

abstract class MockInputParser<InputType, JsonType> extends Mock implements InputParser<InputType> {
  MockInputParser() {
    when(() => parse(any())).thenAnswer(_inputOrDefault);
    when(() => parseJson(any<JsonType?>())).thenAnswer(_inputOrDefault);
    when(() => throwArgumentError(any<InputType>(), any())).thenThrow(ArgumentError(''));
  }

  @protected
  InputType get fallback => throw UnimplementedError();

  void whenParse(InputType? input, InputType output) => when(() => parse(input)).thenReturn(output);

  void verifyParse(InputType? input) => verify(() => parse(input)).called(1);

  void whenParseJson(dynamic input, InputType output) =>
      when(() => parseJson(input)).thenReturn(output);

  void verifyParseJson(dynamic input) => verify(() => parseJson(input)).called(1);

  InputType _inputOrDefault(Invocation invocation) =>
      invocation.positionalArguments.first as InputType? ?? fallback;
}
