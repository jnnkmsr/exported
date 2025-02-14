import 'package:exported/src/validation/option_parser.dart';
import 'package:exported/src/validation/validation_util.dart';
import 'package:path/path.dart' as p;

// TODO[UriParser]: Simplify by using [Uri].

/// Validates and sanitizes a Dart export URI string input.
///
/// - Trims leading/trailing whitespace.
/// - If the input is `null` or empty/blank, an [ArgumentError] is thrown.
/// - Normalizes the URI, ensuring a valid Dart `package:` URI:
///   - Normalizes the path, ensures snake-case, and adds a leading `package:`
///     prefix if missing.
///   - Ensures the file extension is `.dart` or adds it if missing.
///   - Converts a single package or library name to a URI of the form
///     `'package:$package/$package.dart'`.
///
/// Any invalid input throws an [ArgumentError].
class UriParser extends StringOptionParser {
  const UriParser(super.inputName);

  /// The scheme prefix for a Dart package URI.
  static const _scheme = 'package:';

  @override
  String parse([String? input]) {
    final uri = input?.trim();
    if (uri == null || uri.isEmpty) {
      throwArgumentError(input, 'A valid package name or URI must be provided');
    }

    // Remove the prefix and split using POSIX style (always '/' as separator).
    final path = uri.startsWith(_scheme) ? uri.substring(_scheme.length) : uri;
    if (path.endsWith('/')) {
      throwArgumentError(uri, 'Cannot be a directory path');
    }
    final parts = p.posix.split(p.posix.normalize(path));

    // Validate the package name.
    var package = parts.first;
    if (parts.length == 1) {
      // This must only be a file name if there are no trailing parts.
      package = p.posix.basenameWithoutExtension(package);
    }
    if (!isSnakeCase(package)) {
      throwArgumentError(uri, 'Package name "$package" contains invalid characters');
    }
    if (parts.length == 1) {
      return "$_scheme${p.posix.join(package, '$package.dart')}";
    }

    // Validate intermediate directory parts.
    final dirs = parts.sublist(1, parts.length - 1);
    for (final dir in dirs) {
      if (!isSnakeCase(dir)) {
        throwArgumentError(uri, 'Directory name "$dir" contains invalid characters');
      }
    }

    // Validate the library-file name.
    var file = parts.last;
    final fileName = p.posix.basenameWithoutExtension(file);
    if (!isSnakeCase(fileName)) {
      throwArgumentError(uri, 'File name "$fileName" contains invalid characters');
    }
    file = switch (p.posix.extension(file)) {
      '.dart' => file,
      '' => '$file.dart',
      _ => throwArgumentError(uri),
    };

    return '$_scheme${p.posix.joinAll([package, ...dirs, file])}';
  }
}
