import 'package:exported/src/validation/input_parser.dart';
import 'package:test/test.dart';

extension InputParserTestHelpers<InputType> on InputParser<InputType> {
  void expectParses(InputType? input, InputType expected) {
    expect(parse(input), expected);
  }

  void expectParsesJson(dynamic input, InputType expected) {
    expect(parseJson(input), expected);
  }

  void expectThrows(InputType? input) {
    expect(() => parse(input), throwsArgumentError);
  }

  void expectThrowsJson(dynamic input) {
    expect(() => parseJson(input), throwsArgumentError);
  }
}
