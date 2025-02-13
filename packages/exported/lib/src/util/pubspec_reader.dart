import 'package:file/file.dart';
import 'package:file/local.dart';
import 'package:file/memory.dart';
import 'package:meta/meta.dart';
import 'package:pub_semver/pub_semver.dart';
import 'package:yaml/yaml.dart';

/// Helper class to read the package name and Dart SDK version from the target
/// package's `pubspec.yaml`.
class PubspecReader {
  /// Creates a [PubspecReader] instance.
  ///
  /// The [fileSystem] defaults to [LocalFileSystem], but should be replaced
  /// with a [MemoryFileSystem] in tests.
  @visibleForTesting
  PubspecReader([
    FileSystem fileSystem = const LocalFileSystem(),
  ]) : _fileSystem = fileSystem;

  /// Singleton instance of [PubspecReader] using the default [LocalFileSystem].
  factory PubspecReader.instance() => $instance;

  /// The singleton instance returned by [PubspecReader.instance]. Replace this
  /// in tests to inject a test double.
  @visibleForTesting
  static PubspecReader $instance = PubspecReader();

  final FileSystem _fileSystem;

  /// Reads the `name` from the `pubspec.yaml`, or returns a previously read
  /// value.
  late final String name = _read((yaml) => yaml.name, _name);

  /// Reads the `environment:sdk` from the `pubspec.yaml`, or returns a
  /// previously read value.
  late final VersionConstraint sdkVersion = _read(
    (yaml) => VersionConstraint.parse(yaml.environment.sdk),
    '$_environment:$_sdk',
  );

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
    final pubspecFile = _fileSystem.directory(_packageDir).childFile(_pubspecFileName);
    return loadYaml(pubspecFile.readAsStringSync()) as YamlMap;
  }
}

extension on YamlMap {
  String get name => this[_name] as String;
  YamlMap get environment => this[_environment] as YamlMap;
  String get sdk => this[_sdk] as String;
}

const _name = 'name';
const _environment = 'environment';
const _sdk = 'sdk';
const _packageDir = './';
const _pubspecFileName = 'pubspec.yaml';
