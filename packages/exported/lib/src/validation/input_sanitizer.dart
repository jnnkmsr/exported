import 'package:meta/meta.dart';

/// Base class for sanitizers providing a common [sanitize] interface and a
/// method to throw an [ArgumentError] with a message that includes the input
/// name and value.
abstract class InputSanitizer<InputType, OutputType> {
  /// Creates a new [InputSanitizer] for the given [inputName].
  const InputSanitizer(this.inputName);

  /// The name of the input that is sanitized. Used in error messages.
  final String inputName;

  /// Sanitizes the given [input] and returns the sanitized value.
  OutputType sanitize(InputType input);

  /// Helper method to throw an [ArgumentError] with a message that includes the
  /// input name and value
  @protected
  @mustCallSuper
  Never throwArgumentError(String? input, [String? message]) =>
      throw ArgumentError.value(input, inputName, message);
}
