// Copyright (c) 2025 Jannik Möser
// Use of this source code is governed by the BSD 3-Clause License.
// See the LICENSE file for full license information.

import 'package:file/file.dart';
import 'package:file/local.dart';
import 'package:file/memory.dart';
import 'package:yaml/yaml.dart';

/// Helper class to read the package name from the `pubspec.yaml`.
class PubspecReader {
  /// Creates a [PubspecReader] instance.
  ///
  /// The [fileSystem] defaults to [LocalFileSystem], but should be replaced
  /// with a [MemoryFileSystem] in tests.
  PubspecReader([
    FileSystem? fileSystem,
  ]) : _fileSystem = fileSystem ?? const LocalFileSystem();

  final FileSystem _fileSystem;

  /// Reads the `name` from the `pubspec.yaml`, or returns a previously read
  /// value.
  late final String name = _read((yaml) => yaml[_nameKey] as String, _nameKey);

  /// Reads a value from the `pubspec.yaml` using the provided [accessor], or
  /// returns a previously read value.
  ///
  /// Throws a [FormatException] if the value cannot be read, using the field
  /// [fieldName] to provide context.
  T _read<T>(T Function(YamlMap) accessor, String fieldName) {
    try {
      return accessor(_yaml);
    } on FileSystemException catch (_) {
      rethrow;
    } catch (e) {
      throw FormatException('Failed to read `$fieldName` from pubspec.yaml', e);
    }
  }

  /// Reads the `pubspec.yaml` and converts it to a [YamlMap], or returns a
  /// previously read value.
  late final YamlMap _yaml = loadYaml(_fileSystem.file(_pubspecFile).readAsStringSync()) as YamlMap;
}

const _pubspecFile = 'pubspec.yaml';
const _nameKey = 'name';
