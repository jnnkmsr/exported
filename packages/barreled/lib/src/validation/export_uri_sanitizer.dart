import 'package:barreled/src/validation/input_sanitizer.dart';
import 'package:path/path.dart' as p;

/// A sanitizer/validator for Dart export URIs.
///
/// Sanitizes a URI string input based on the following rules:
/// - The input is trimmed and must not be null, empty, or blank.
/// - If missing, a leading `'package:'` prefix is added.
/// - If the input is just a package name, it is converted to a URI of the form
///   `'package:<packageName>/<packageName>.dart'`.
/// - If missing, a `'.dart'` extension is appended to the library file name.
/// - All URI components (package name, intermediate directories, and library
///   file name without extension must be snake-case (i.e. only lowercase
///   letters, numbers, and underscores).
/// - The path is normalized, but must not end with a trailing `'/'`.
class ExportUriSanitizer extends InputSanitizer<String?, String> {
  const ExportUriSanitizer({required super.inputName});

  @override
  String sanitize(String? input) {
    final uri = input?.trim();
    if (uri == null || uri.isEmpty) {
      throwArgumentError(input, 'A valid package name or URI must be provided');
    }

    // Remove the prefix and split using POSIX style (always '/' as separator).
    final path = uri.startsWith(_prefix) ? uri.substring(_prefix.length) : uri;
    if (path.endsWith('/')) {
      throwArgumentError(uri, 'Invalid package name or URI: $uri');
    }
    final parts = p.posix.split(p.posix.normalize(path));
    if (parts.isEmpty) {
      throwArgumentError(uri, 'Invalid package name or URI: $uri');
    }

    // Validate the package name.
    final package = parts.first;
    if (!_isSnakeCase(package)) {
      throwArgumentError(uri, 'Invalid package name or URI: $uri');
    }
    if (parts.length == 1) {
      return "$_prefix${p.posix.join(package, '$package.dart')}";
    }

    // Validate intermediate directory parts.
    final directories = parts.sublist(1, parts.length - 1);
    for (final directory in directories) {
      if (!_isSnakeCase(directory)) {
        throwArgumentError(uri, 'Invalid package name or URI: $uri');
      }
    }

    // Validate the library-file name.
    var file = parts.last;
    if (file.isEmpty) {
      throwArgumentError(uri); // URI ends with '/'.
    }
    if (!_isSnakeCase(p.posix.basenameWithoutExtension(file))) {
      throwArgumentError(uri);
    }
    file = switch (p.posix.extension(file)) {
      '.dart' => file,
      '' => '$file.dart',
      _ => throw throwArgumentError(uri),
    };

    return '$_prefix${p.posix.joinAll([package, ...directories, file])}';
  }

  /// The prefix for a Dart package URI.
  static const _prefix = 'package:';

  /// Helper method to check if a string is snake-case using a regex.
  bool _isSnakeCase(String input) => _snakeCasePattern.hasMatch(input);
  static final _snakeCasePattern = RegExp(r'^[a-z0-9_]+$');

  @override
  Never throwArgumentError(String? input, [String? message]) =>
      super.throwArgumentError(input, message ?? 'Invalid package name or URI: $input');
}
