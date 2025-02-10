import 'package:file/file.dart';
import 'package:file/local.dart';
import 'package:meta/meta.dart';
import 'package:pub_semver/pub_semver.dart';
import 'package:yaml/yaml.dart';

class PubspecReader {
  PubspecReader({
    FileSystem? fileSystem,
  }) : _fileSystem = fileSystem ?? const LocalFileSystem();

  /// Singleton instance of [PubspecReader] using the default [LocalFileSystem].
  ///
  /// Returns [$instance], which can be replaced with a double in tests.
  factory PubspecReader.instance() => $instance;
  @visibleForTesting
  static PubspecReader $instance = PubspecReader();

  final FileSystem _fileSystem;

  late final String name = _read((yaml) => yaml.name, 'package name');

  late final VersionConstraint sdkVersion = _read(
    (yaml) => VersionConstraint.parse(yaml.environment.sdk),
    'Dart SDK version',
  );

  late final YamlMap _yaml = _readYaml();

  YamlMap _readYaml() {
    final pubspecFile = _fileSystem.directory(_packageDir).childFile(_pubspecFileName);
    return loadYaml(pubspecFile.readAsStringSync()) as YamlMap;
  }

  T _read<T>(T Function(YamlMap) accessor, String description) {
    try {
      return accessor(_yaml);
    } on FileSystemException catch (_) {
      rethrow;
    } catch (e) {
      throw FormatException('Failed to read $description from pubspec.yaml', e);
    }
  }
}

extension on YamlMap {
  String get name => this['name'] as String;
  YamlMap get environment => this['environment'] as YamlMap;
  String get sdk => this['sdk'] as String;
}

const _packageDir = './';
const _pubspecFileName = 'pubspec.yaml';
