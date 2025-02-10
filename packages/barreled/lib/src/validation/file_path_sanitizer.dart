import 'package:barreled/src/util/pubspec_reader.dart';
import 'package:barreled/src/validation/validation_util.dart';
import 'package:path/path.dart' as p;

/// Sanitizes a barrel-file path input based on the following rules:
/// - Inputs are trimmed.
/// - `null`, empty or blank inputs are replaced with the default file name
///   `<package>.dart`, reading the package name from the `pubspec.yaml`.
/// - Paths are normalized.
/// - All path components must be snake-case (only lowercase letters, numbers,
///   and underscores).
/// - Paths must be relative and are assumed to be relative to the `lib`
///   directory. A leading `lib/` directory is removed.
/// - For directory-paths ending with a `/`, the default file name is appended.
/// - For file-path inputs, a missing `.dart` extension is appended. If an
///   extension is present, it must be `.dart`.
///
/// Any invalid input throws an [ArgumentError].
class FilePathSanitizer with InputValidator {
  FilePathSanitizer({
    required this.inputName,
  });

  @override
  final String inputName;

  /// Reads the default package name from the `pubspec.yaml`.
  ///
  /// In tests, set [PubspecReader.$instance] to inject doubles.
  static final _pubspecReader = PubspecReader.instance();

  /// The default `lib` directory, removed from the input if specified.
  static const _defaultDir = 'lib';

  /// The default `<package>.dart` file name, reading the package name from the
  /// `pubspec.yaml`.
  static final _defaultFile = '${_pubspecReader.name}.dart';

  /// Validates the [input] returns the sanitized relative path within the
  /// target package's `lib` directory.
  String sanitize(String? input) {
    final path = input?.trim();
    if (path == null || path.isEmpty) return _defaultFile;

    // Check for a valid relative path.
    final normalizedPath = p.posix.normalize(path);
    if (!p.posix.isRelative(normalizedPath)) {
      throwArgumentError(path, 'Absolute paths are not allowed');
    }

    // Split file and directory parts.
    final parts = p.posix.split(normalizedPath);
    assert(parts.isNotEmpty, 'Unexpected empty path: $path');

    late String file;
    late List<String> dirs;
    if (path.endsWith('/')) {
      file = _defaultFile;
      dirs = parts;
    } else {
      file = parts.last;
      dirs = parts.sublist(0, parts.length - 1);
    }

    // Validate and sanitize the file name.
    if (!isSnakeCase(p.posix.basenameWithoutExtension(file))) {
      throwArgumentError(path, 'Invalid file name: $file');
    }
    final extension = p.posix.extension(file);
    file = switch (extension) {
      '.dart' => file,
      '' => '$file.dart',
      _ => throwArgumentError(path, 'Invalid file extension: $extension'),
    };

    // Validate and sanitize the directory parts, removing a leading `lib` if
    // present and checking for invalid characters.
    if (dirs.firstOrNull == _defaultDir) {
      dirs = dirs.sublist(1);
    }
    if (dirs.isEmpty) return file;

    for (final dir in dirs) {
      if (!isSnakeCase(dir)) {
        throwArgumentError(path, 'Invalid directory name: $dir');
      }
    }
    return p.posix.joinAll([...dirs, file]);
  }
}
