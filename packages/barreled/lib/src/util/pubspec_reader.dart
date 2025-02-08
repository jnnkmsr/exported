import 'package:file/file.dart';
import 'package:file/local.dart';
import 'package:pub_semver/pub_semver.dart';
import 'package:yaml/yaml.dart';

class PubspecReader {
  PubspecReader({
    FileSystem? fileSystem,
  }) : _fileSystem = fileSystem ?? const LocalFileSystem();

  final FileSystem _fileSystem;

  late final String packageName = _read(
    (yaml) => yaml.name,
    'package name',
  );

  late final VersionConstraint dartVersion = _read(
    (yaml) => VersionConstraint.parse(yaml.environment.sdk),
    'Dart SDK version',
  );

  late final YamlMap _pubspecYaml = _readPubspecYaml();

  YamlMap _readPubspecYaml() {
    final pubspecFile = _fileSystem.directory(_packageDir).childFile(_pubspecFileName);
    return loadYaml(pubspecFile.readAsStringSync()) as YamlMap;
  }

  T _read<T>(T Function(YamlMap) accessor, String description) {
    try {
      return accessor(_pubspecYaml);
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
