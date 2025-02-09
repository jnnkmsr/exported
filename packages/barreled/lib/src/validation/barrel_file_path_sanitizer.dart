import 'package:barreled/src/options/barrel_file_option.dart';
import 'package:barreled/src/util/pubspec_reader.dart';
import 'package:barreled/src/validation/validation_util.dart';
import 'package:meta/meta.dart';
import 'package:path/path.dart' as p;

// TODO: Unit test [BarrelFilePathSanitizer].

/// Bundles sanitized [BarrelFileOption.file] and [BarrelFileOption.dir] values.
typedef BarrelFilePath = ({String file, String dir});

/// Sanitizes barrel file and directory inputs based on the following rules:
/// - Inputs are trimmed.
/// - If the `file` input is empty or blank, the package name is used.
/// - If the `dir` input is empty or blank, the default directory `lib` is used.
/// - All file names and directories must be snake-case (only lowercase letters,
///   numbers, and underscores).
/// - All directory inputs must be a relative.
/// - If missing, a `'.dart'` extension is appended to the `file` input.
/// - If the `file` input contains a directory prefix, these parts are appended
///   to the `dir` input (or replace it if no `dir` was provided).
class BarrelFilePathSanitizer {
  BarrelFilePathSanitizer({
    required String fileInputName,
    required String dirInputName,
  })  : _fileNameSanitizer = _FileNameSanitizer(inputName: fileInputName),
        _dirSanitizer = _DirSanitizer(
          inputName: dirInputName,
          defaultDir: defaultDir,
        ),
        super();

  final _FileNameSanitizer _fileNameSanitizer;
  final _DirSanitizer _dirSanitizer;

  /// Reads the default package name from the `pubspec.yaml`. Mutable to allow
  /// injection of test doubles.
  @visibleForTesting
  static PubspecReader pubspecReader = PubspecReader.instance();

  /// The default `lib` directory if no directory is specified.
  static const defaultDir = 'lib';

  /// The default `<package>.dart` file name, read from the `pubspec.yaml`.
  static final defaultFile = '${pubspecReader.packageName}.dart';

  /// Validates both the [fileInput] and the [dirInput] and returns the
  /// sanitized output, split into a directory and a file part.
  BarrelFilePath sanitize({
    String? fileInput,
    String? dirInput,
  }) {
    final (file: file, dir: fileDir) = _fileNameSanitizer.sanitize(fileInput ?? '');
    return (
      file: file,
      dir: _dirSanitizer.sanitize(dirInput ?? '', fileDir),
    );
  }
}

/// Helper sanitizer for the `file` input of a barrel file.
///
/// Splits the input into a file name and directory part, and sanitizes both.
class _FileNameSanitizer with InputValidator {
  _FileNameSanitizer({
    required this.inputName,
  });

  @override
  final String inputName;

  late final _dirSanitizer = _DirSanitizer(inputName: inputName);

  /// Validates the [input] and returns the sanitized output, split into a
  /// directory and a file part.
  BarrelFilePath sanitize(String input) {
    final file = input.trim();
    if (file.isEmpty) {
      return (file: BarrelFilePathSanitizer.defaultFile, dir: '');
    }
    if (file.endsWith('/')) {
      throwArgumentError(file);
    }

    final parts = p.posix.split(p.posix.normalize(file));
    if (parts.isEmpty) {
      throwArgumentError(file);
    }

    var fileName = parts.last;
    if (!isSnakeCase(p.posix.basenameWithoutExtension(fileName))) {
      throwArgumentError(file);
    }
    fileName = switch (p.posix.extension(file)) {
      '.dart' => fileName,
      '' => '$fileName.dart',
      _ => throwArgumentError(file),
    };

    final fileDir = _dirSanitizer.sanitize(
      parts.length > 1 ? p.posix.joinAll(parts.sublist(0, parts.length - 1)) : '',
    );

    return (file: fileName, dir: fileDir);
  }

  @override
  Never throwArgumentError(String? input, [String? message]) =>
      super.throwArgumentError(input, message ?? 'Invalid file name: $input');
}

/// Helper sanitizer for a directory input. Used both for sanitizing the `dir`
/// input and for normalizing the directory part of the `file` input.
class _DirSanitizer with InputValidator {
  const _DirSanitizer({
    required this.inputName,
    String defaultDir = '',
  }) : _defaultDir = defaultDir;

  @override
  final String inputName;
  final String _defaultDir;

  String sanitize(String input, [String subDir = '']) {
    var dir = input.trim();
    if (dir.isEmpty) {
      return subDir.isNotEmpty ? subDir : _defaultDir;
    }

    dir = p.posix.normalize(dir);
    if (!p.isRelative(dir)) {
      throwArgumentError(dir);
    }
    if (p.extension(dir).isNotEmpty) {
      throwArgumentError(dir);
    }

    final parts = p.posix.split(dir);
    for (final part in parts) {
      if (!isSnakeCase(p.posix.basenameWithoutExtension(part))) {
        throwArgumentError(dir);
      }
    }

    return p.posix.normalize(p.posix.join(dir, subDir));
  }

  @override
  Never throwArgumentError(String? input, [String? message]) =>
      super.throwArgumentError(input, message ?? 'Invalid directory: $input');
}
