import 'package:meta/meta.dart';

/// A base class for input sanitizers.
@immutable
abstract class InputSanitizer<InputT, OutputT> {
  const InputSanitizer({
    required String inputName,
  }) : _inputName = inputName;

  /// The name of the input that is sanitized. Used in error messages.
  final String _inputName;

  /// Validates the input and returns the sanitized output.
  OutputT sanitize(InputT input);

  /// Helper method to throw an [ArgumentError] with a message that includes the
  /// input name and value
  @protected
  @mustCallSuper
  Never throwArgumentError(String? input, [String? message]) =>
      throw ArgumentError.value(input, _inputName, message);
}
