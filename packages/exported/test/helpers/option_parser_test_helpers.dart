import 'package:exported/src/validation/option_parser.dart';
import 'package:test/test.dart';

extension OptionParserTestHelpers<InputType> on OptionParser<InputType> {
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
