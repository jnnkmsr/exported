// Copyright (c) 2025 Jannik Möser
// Use of this source code is governed by the BSD 3-Clause License.
// See the LICENSE file for full license information.

import 'package:exported/src/model/exported_option_keys.dart' as keys;
import 'package:path/path.dart' as p;

/// Represents the relative path of a barrel file within the target package's
/// `lib/` directory.
extension type const BarrelFilePath._(String _) implements String {
  /// Creates the default [BarrelFilePath] for the target package, that is
  /// `'$package.dart'`, using the given [package] name.
  factory BarrelFilePath.packageNamed({required String package}) =>
      BarrelFilePath._('$package.dart');

  /// Creates a [BarrelFilePath] from a builder options input, which may be
  /// either a [String] or a [Map] containing a `path` key.
  ///
  /// Input validation/sanitization:
  /// - Trims leading/trailing whitespace.
  /// - Normalizes the path and ensures snake-case.
  /// - Ensures the file extension is `.dart` or adds it if missing.
  /// - Removes any leading `lib/` directory.
  /// - If the input is null, blank, or a directory, the default barrel file
  ///   (`'$package.dart'`) is used, using the given [package] name.
  ///
  /// Throws an [ArgumentError] if the [input] or [Map] value is not a [String]
  /// that can be sanitized to a valid relative barrel-file path.
  factory BarrelFilePath.fromInput(dynamic input, {required String package}) {
    try {
      final path = _validateInput(input);
      if (path == null) return BarrelFilePath._('$package.dart');

      final (file, dir) = _validatePath(path);
      return BarrelFilePath._(
        p.posix.joinAll([
          if (dir != null) dir,
          if (file != null) file else '$package.dart',
        ]),
      );
    } on ArgumentError catch (e) {
      throw ArgumentError.value(input, keys.path, e.message);
    }
  }

  /// Restores a [BarrelFilePath] from internal [json] without any validation.
  factory BarrelFilePath.fromJson(Map json) => BarrelFilePath._(json[keys.path] as String);

  /// Converts this [BarrelFilePath] to JSON for storage in the build cache.
  Map<String, dynamic> toJson() => {keys.path: this as String};

  /// Validates [input] is either a non-empty [String] or a [Map] containing a
  /// `path` key with a non-empty [String] value.
  static String? _validateInput(dynamic input) {
    final stringInput = input is Map ? input[keys.path] : input;
    if (stringInput is! String?) {
      throw ArgumentError('Must be a string');
    }
    final path = stringInput?.trim();
    return (path != null && path.isNotEmpty) ? path : null;
  }

  /// Normalizes [path], validates that it is a valid snake-case path, and
  /// splits it into file and directory components.
  /// - Removes any leading `lib/` directory from the directory component.
  /// - Validates that any file extension is `.dart`.
  ///
  /// Throws an [ArgumentError] if the [path] cannot be sanitized to a valid
  /// relative barrel-file path.
  static (String? file, String? dir) _validatePath(String path) {
    final normalizedPath = p.posix.normalize(path);
    if (p.posix.isAbsolute(normalizedPath)) {
      throw ArgumentError('Absolute paths are not allowed');
    }
    final extension = p.posix.extension(normalizedPath);
    if (extension.isNotEmpty && extension != '.dart') {
      throw ArgumentError('Invalid file extension "$extension"');
    }

    // Split file and dir parts, removing the extension for segment checking.
    final isDirectory = path.endsWith('/');
    final pathSegments = p.posix.split(p.posix.withoutExtension(normalizedPath));

    final fileName = isDirectory ? null : pathSegments.last;
    if (fileName != null && !_validPathSegmentPattern.hasMatch(fileName)) {
      throw ArgumentError('File name "$fileName" contains invalid characters');
    }
    final file = fileName != null ? '$fileName.dart' : null;

    final dirSegments =
        isDirectory ? pathSegments : pathSegments.sublist(0, pathSegments.length - 1);

    // Remove a leading 'lib' or `.` if present.
    final firstDir = dirSegments.firstOrNull;
    if (firstDir == 'lib' || firstDir == '.') {
      dirSegments.removeAt(0);
    }
    if (dirSegments.isEmpty) return (file, null);

    for (final segment in dirSegments) {
      if (!_validPathSegmentPattern.hasMatch(segment)) {
        throw ArgumentError('Path segment "$segment" contains invalid characters');
      }
    }
    return (file, p.posix.joinAll(dirSegments));
  }

  static final _validPathSegmentPattern = RegExp(r'^(?!\d)[a-z0-9_]+$');
}

extension BarrelFilePathStringExtension on String {
  BarrelFilePath get asBarrelFilePath => BarrelFilePath._(this);
}
