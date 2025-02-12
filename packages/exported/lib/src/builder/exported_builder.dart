import 'dart:async';
import 'dart:convert';

import 'package:build/build.dart';
import 'package:collection/collection.dart';
import 'package:exported/src/builder/barrel_file_generator.dart';
import 'package:exported/src/model/export.dart';
import 'package:exported/src/model/exported_options.dart';
import 'package:exported/src/util/pubspec_reader.dart';
import 'package:glob/glob.dart';
import 'package:meta/meta.dart';
import 'package:path/path.dart' as p;
import 'package:pub_semver/pub_semver.dart';

class ExportedBuilder extends Builder {
  ExportedBuilder({ExportedOptions? options})
      : _generators = BarrelFileGenerator.fromOptions(options ?? ExportedOptions());

  late final Set<BarrelFileGenerator> _generators;
  late final Version? _dartVersion = pubspecReader.sdkVersion.target;

  @override
  late final buildExtensions = {r'$lib$': _filePaths};
  List<String> get _filePaths => [for (final generator in _generators) generator.file.path];

  @visibleForTesting
  static PubspecReader pubspecReader = PubspecReader.instance();

  static const jsonAssetExtension = '.exported.json';

  Future<void> _parseJsonAssets(BuildStep buildStep) async {
    final json = await buildStep
        .findAssets(Glob('**$jsonAssetExtension'))
        .asyncMap(buildStep.readAsString)
        .map((content) => (jsonDecode(content) as List).cast<Map<String, dynamic>>())
        .toList();
    final exports = json.flattened.map(Export.fromJson);
    for (final generator in _generators) {
      generator.addExports(exports);
    }
  }

  Future<void> _write(BuildStep buildStep, BarrelFileGenerator generator) {
    return buildStep.writeAsString(
      AssetId(buildStep.inputId.package, p.join('lib', generator.file.path)),
      generator.generate(_dartVersion),
    );
  }

  @override
  Future<void> build(BuildStep buildStep) async {
    await _parseJsonAssets(buildStep);
    await Future.wait(_generators.map((file) => _write(buildStep, file)));
  }
}

extension on VersionConstraint {
  Version? get target => switch (this) {
        final Version version => version,
        final VersionRange range => range.min ?? range.max,
        _ => null,
      };
}
