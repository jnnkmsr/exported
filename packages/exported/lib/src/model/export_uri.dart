import 'package:exported/src/builder/exported_option_keys.dart' as keys;
import 'package:exported/src/util/pubspec_reader.dart';
import 'package:path/path.dart' as p;

/// Represents the URI of a Dart `export` directive.
extension type const ExportUri(String _) implements String {

  /// Creates an [ExportUri] from builder options string or map [input],
  /// validating and sanitizing input.
  ///
  /// Throws an [ArgumentError] if the input is null or empty, not a string, if
  /// map input does not contain a `uri` key with a non-empty string value, or
  /// the URI cannot be sanitized to a valid `package:` or `dart:` URI.
  ///
  /// **Input validation/sanitization:**
  ///
  /// - Trims leading/trailing whitespace.
  /// - Ensures the URI path is not a directory and not absolute.
  /// - Normalizes the URI path, ensuring snake-case.
  /// - Adds missing `.dart` extensions and `package:` prefixes.
  /// - Converts a single package or library name to a URI of the form
  ///   `'package:$package/$package.dart'`.
  /// - Converts a `lib/` path to a package path using the package name from
  ///   [pubspecReader].
  factory ExportUri.fromInput(
    dynamic input, [
    PubspecReader? pubspecReader,
  ]) {
    try {
      final (scheme, path, extension) = _validateInput(input);
      _validatePath(path, extension);

      final uri = switch (scheme) {
        'dart' => _parseDartUri(path, extension),
        'package' || null => _parsePackageUri(path, pubspecReader),
        final scheme => throw ArgumentError('Invalid scheme "$scheme"'),
      };
      return ExportUri(uri);
    } on ArgumentError catch (e) {
      throw ArgumentError.value(input, keys.uri, e.message);
    }
  }

  /// Restores an [ExportUri] from an internal [json] representation without
  /// any input validation.
  factory ExportUri.fromJson(Map json) => ExportUri(json[keys.uri] as String);

  /// Converts this [ExportUri] to JSON stored in the build cache.
  Map toJson() => {keys.uri: this as String};

  /// Validates [input] is either a non-empty [String] or a [Map] containing a
  /// `uri` key with a non-empty [String] value. Then splits the URI input into
  /// its scheme, normalized path, and extension components.
  static (String? scheme, String path, String extension) _validateInput(dynamic input) {
    final stringInput = input is Map ? input[keys.uri] : input;
    if (stringInput is! String?) {
      throw ArgumentError('Must be a string');
    }
    final uri = stringInput?.trim();
    if (uri == null || uri.isEmpty) {
      throw ArgumentError('A non-empty URI must be provided');
    }
    if (uri.endsWith('/')) {
      throw ArgumentError('Path cannot be a directory');
    }

    final match = _schemePattern.firstMatch(uri);
    final scheme = match?.group(1);
    final path = p.posix.normalize(match?.group(2) ?? uri);
    return (scheme, p.posix.withoutExtension(path), p.posix.extension(path));
  }

  /// Converts the [path] to a `dart:` URI, ensuring [path] is a single library
  /// name.
  static String _parseDartUri(String path, String extension) {
    if (path.contains('/') || extension.isNotEmpty) {
      throw ArgumentError('"dart:" URI should be a single library name');
    }
    return 'dart:$path';
  }

  /// Converts the [path] to a `package:` URI. Adds missing `.dart` extensions,
  /// converts package names to a `$package/$package.dart` path and transforms
  /// `lib/` paths to package paths using the package name from [pubspecReader],
  static String _parsePackageUri(String path, PubspecReader? pubspecReader) {
    final segments = p.posix.split(path);
    if (segments.length == 1) {
      return 'package:$path/$path.dart';
    } else if (segments.first == 'lib') {
      final package = (pubspecReader ?? PubspecReader.instance).name;
      return 'package:${p.posix.joinAll([package, ...segments.skip(1)])}.dart';
    }
    return 'package:$path.dart';
  }

  /// Validates [path] is a valid snake-case path and the [extension] is either
  /// empty or `.dart`.
  static void _validatePath(String path, String extension) {
    if (p.posix.isAbsolute(path)) {
      throw ArgumentError('Path is absolute');
    }
    if (extension.isNotEmpty && extension != '.dart') {
      throw ArgumentError('Invalid file extension "$extension"');
    }

    final segments = p.posix.split(path);
    for (final segment in segments) {
      if (!_validSegmentPattern.hasMatch(segment)) {
        throw ArgumentError('Path is not snake-case: "$segment"');
      }
    }
  }

  static final _schemePattern = RegExp(r'^(?:(\w+):)?(.*)$');
  static final _validSegmentPattern = RegExp(r'^(?!\d)[a-z0-9_]+$');
}
