// Copyright (c) 2025 Jannik Möser
// Use of this source code is governed by the BSD 3-Clause License.
// See the LICENSE file for full license information.

import 'package:exported/src/model/exported_option_keys.dart' as keys;
import 'package:path/path.dart' as p;

/// Represents the URI of a Dart `export` directive.
///
/// **Note:** The unnamed constructor will not validate the input and should
/// only be used for testing or when the input is known to be valid.
extension type const ExportUri._(String _) implements String {
  /// Creates an [ExportUri] from builder options string or map [input],
  /// validating and sanitizing input.
  ///
  /// Input validation/sanitization:
  /// - Trims leading/trailing whitespace.
  /// - Ensures the URI path is not a directory and not absolute.
  /// - Normalizes the URI path and ensures snake-case.
  /// - Ensures the file extension is `.dart` or adds it if missing.
  /// - Ensures the URI scheme is either `dart` or `package` and adds `package:`
  ///   if missing.
  /// - Ensures the path is a single library name for `dart:` URIs.
  /// - Converts a package or library to `'package:$package/$package.dart'`,
  ///   using the given [package] name.
  /// - Converts a `lib/` path to `'package:$package/$path'`.
  ///
  /// Throws an [ArgumentError] if the input is null or blank, not a string, if
  /// map input does not contain a `uri` key with a non-empty string value, or
  /// the URI cannot be sanitized to a valid `package:` or `dart:` URI.
  factory ExportUri.fromInput(dynamic input, {required String package}) {
    try {
      final (scheme, path, extension) = _validateInput(input);
      _validatePath(path, extension);

      final uri = switch (scheme) {
        'dart' => _parseDartUri(path, extension),
        'package' || null => _parsePackageUri(path, package),
        final scheme => throw ArgumentError('Invalid scheme "$scheme"'),
      };
      return ExportUri._(uri);
    } on ArgumentError catch (e) {
      throw ArgumentError.value(input, keys.uri, e.message);
    }
  }

  /// Restores an [ExportUri] from internal [json] without any validation.
  factory ExportUri.fromJson(Map json) => ExportUri._(json[keys.uri] as String);

  /// Converts this [ExportUri] to JSON for storage in the build cache.
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
  /// `lib/` paths to package paths using the given [package] name.
  static String _parsePackageUri(String path, String package) {
    final segments = p.posix.split(path);
    if (segments.length == 1) {
      return 'package:$path/$path.dart';
    } else if (segments.first == 'lib') {
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
      if (!_validPathSegmentPattern.hasMatch(segment)) {
        throw ArgumentError('Path segment "$segment" contains invalid characters');
      }
    }
  }

  static final _schemePattern = RegExp(r'^(?:(\w+):)?(.*)$');
  static final _validPathSegmentPattern = RegExp(r'^(?!\d)[a-z0-9_]+$');
}

extension ExportUriStringExtension on String {
  /// Converts this string to an [ExportUri] instance without any validation.
  ExportUri get asExportUri => ExportUri._(this);
}
