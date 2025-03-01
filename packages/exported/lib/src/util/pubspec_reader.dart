import 'package:file/file.dart';
import 'package:file/local.dart';
import 'package:file/memory.dart';
import 'package:meta/meta.dart';
import 'package:yaml/yaml.dart';

/// Helper class to read the package name from the `pubspec.yaml`.
class PubspecReader {
  /// Creates a [PubspecReader] instance.
  ///
  /// The [fileSystem] defaults to [LocalFileSystem], but should be replaced
  /// with a [MemoryFileSystem] in tests.
  @visibleForTesting
  PubspecReader([
    FileSystem fileSystem = const LocalFileSystem(),
  ]) : _fileSystem = fileSystem;

  /// Singleton instance of [PubspecReader] using the [LocalFileSystem].
  static final PubspecReader instance = PubspecReader();

  final FileSystem _fileSystem;

  /// Reads the `name` from the `pubspec.yaml`, or returns a previously read
  /// value.
  late final String name = _read((yaml) => yaml.name, _nameKey);

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
  late final YamlMap _yaml = _readYaml();
  YamlMap _readYaml() {
    final pubspecFile = _fileSystem.directory(_packageDir).childFile(_pubspecFile);
    return loadYaml(pubspecFile.readAsStringSync()) as YamlMap;
  }
}

extension on YamlMap {
  String get name => this[_nameKey] as String;
}

const _nameKey = 'name';
const _packageDir = './';
const _pubspecFile = 'pubspec.yaml';
