import 'package:exported/src/_legacy/option_parser.dart';
import 'package:exported/src/_legacy/validation_util.dart';
import 'package:exported/src/util/pubspec_reader.dart';
import 'package:path/path.dart' as p;

/// Validates and sanitizes a `barrel_files:path` input.
///
/// - Trims leading/trailing whitespace.
/// - Normalizes the path, ensures it is relative and snake-case, and removes
///   any leading `lib/`.
/// - Ensures the file extension is `.dart` or adds it if missing. If an
///   extension is present, it must be `.dart`.
/// - If the input is `null` or empty/blank, or ends with `/`, the default
///   barrel-file path `$package.dart` is used, reading `package` from
///   `pubspec.yaml`.
///
/// Any invalid input throws an [ArgumentError].
class FilePathParser extends StringOptionParser {
  const FilePathParser(super.inputName);

  /// Reads the default package name from the `pubspec.yaml`.
  ///
  /// In tests, set [PubspecReader.instance] to inject doubles.
  static final _packageNameReader = PubspecReader.instance;

  /// The default `lib` directory, removed from the input if specified.
  static const _defaultDir = 'lib';

  /// The default `$package.dart` path, reading `package` from `pubspec.yaml`.
  static final _defaultFile = '${_packageNameReader.name}.dart';

  @override
  String parse([String? input]) {
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
    final fileName = p.posix.basenameWithoutExtension(file);
    if (!isSnakeCase(fileName)) {
      throwArgumentError(path, 'File name "$fileName" contains invalid characters');
    }
    final extension = p.posix.extension(file);
    file = switch (extension) {
      '.dart' => file,
      '' => '$file.dart',
      _ => throwArgumentError(path, 'Extension must be ".dart"'),
    };

    // Validate and sanitize the directory parts, removing a leading `lib` if
    // present and checking for invalid characters.
    if (dirs.firstOrNull == _defaultDir) {
      dirs = dirs.sublist(1);
    }
    if (dirs.isEmpty) return file;

    for (final dir in dirs) {
      if (!isSnakeCase(dir)) {
        throwArgumentError(path, 'Directory name "$dir" contains invalid characters');
      }
    }
    return p.posix.joinAll([...dirs, file]);
  }
}
