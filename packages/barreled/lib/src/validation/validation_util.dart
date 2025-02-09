import 'package:meta/meta.dart';

/// Whether the [input] is a snake-case string (only lowercase letters, numbers,
/// and underscores).
bool isSnakeCase(String input) => _snakeCasePattern.hasMatch(input);

/// Whether the [input] is a valid Dart public name (only letters, numbers, and
/// underscores, starting with a letter).
bool isPublicDartIdentifier(String input) => _publicDartNamePattern.hasMatch(input);

final _snakeCasePattern = RegExp(r'^[a-z0-9_]+$');
final _publicDartNamePattern = RegExp(r'^[a-zA-Z][a-zA-Z0-9_]*$');

/// A mixin for sanitizers providing a common method to throw an [ArgumentError]
/// with a message that includes the input name and value.
mixin InputValidator {
  /// The name of the input that is sanitized. Used in error messages.
  @visibleForOverriding
  String? get inputName;

  /// Helper method to throw an [ArgumentError] with a message that includes the
  /// input name and value
  @protected
  @mustCallSuper
  Never throwArgumentError(String? input, [String? message]) =>
      throw ArgumentError.value(input, inputName, message);
}
