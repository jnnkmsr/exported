import 'package:exported/src/validation/file_path_sanitizer.dart';
import 'package:exported/src/validation/input_sanitizer.dart';
import 'package:exported/src/validation/show_hide_sanitizer.dart';
import 'package:exported/src/validation/tags_sanitizer.dart';
import 'package:exported/src/validation/uri_sanitizer.dart';
import 'package:mocktail/mocktail.dart';

class MockFilePathSanitizer extends MockInputSanitizer<String?, String>
    implements FilePathSanitizer {
  MockFilePathSanitizer() : super(defaultFallback: '');
}

class MockShowHideSanitizer extends MockInputSanitizer<Set<String>?, Set<String>>
    implements ShowHideSanitizer {
  MockShowHideSanitizer() : super(defaultFallback: const {});
}

class MockTagsSanitizer extends MockInputSanitizer<Set<String>?, Set<String>>
    implements TagsSanitizer {
  MockTagsSanitizer() : super(defaultFallback: const {});
}

class MockUriSanitizer extends MockInputSanitizer<String?, String> implements UriSanitizer {
  MockUriSanitizer() : super(defaultFallback: '');
}

typedef SanitizeAnswer<InputType, OutputType> = OutputType Function(InputType input);

abstract class MockInputSanitizer<InputType, OutputType> extends Mock
    implements InputSanitizer<InputType, OutputType> {
  MockInputSanitizer({required OutputType defaultFallback}) {
    when(() => sanitize(any())).thenAnswer(
      (i) => i.positionalArguments.first as OutputType? ?? defaultFallback,
    );
  }

  void whenSanitizeReturn(InputType input, OutputType output) =>
      when(() => sanitize(input)).thenReturn(output);

  void whenSanitizeAnswer(InputType input, SanitizeAnswer<InputType, OutputType> answer) =>
      when(() => sanitize(input)).thenAnswer((i) => answer(input));

  void verifySanitized(InputType input) => verify(() => sanitize(input)).called(1);
}
