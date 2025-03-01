/// Whether the [input] is a snake-case string (only lowercase letters, numbers,
/// and underscores).
bool isSnakeCase(String input) => _snakeCasePattern.hasMatch(input);

/// Whether the [input] is a valid Dart public name (only letters, numbers, and
/// underscores, starting with a letter).
bool isPublicDartIdentifier(String input) => _publicDartNamePattern.hasMatch(input);

final _snakeCasePattern = RegExp(r'^[a-z0-9_]+$');
final _publicDartNamePattern = RegExp(r'^[a-zA-Z][a-zA-Z0-9_]*$');
