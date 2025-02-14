import 'package:exported/src/validation/input_parser.dart';
import 'package:test/test.dart';

extension InputParserTestHelpers<InputType> on InputParser<InputType> {
  void expectParse(InputType? input, InputType expected) {
    expect(parse(input), expected);
  }

  void expectParseJson(dynamic input, InputType expected) {
    expect(parseJson(input), expected);
  }

  void expectParseThrows(InputType? input) {
    expect(() => parse(input), throwsArgumentError);
  }

  void expectParseJsonThrows(dynamic input) {
    expect(() => parseJson(input), throwsArgumentError);
  }
}
