import 'dart:async';
import 'dart:convert';

import 'package:barreled/src/model/barrel_export.dart';
import 'package:barreled/src/model/barrel_file.dart';
import 'package:barreled/src/options/barreled_options.dart';
import 'package:barreled/src/util/dart_writer.dart';
import 'package:barreled/src/util/pubspec_reader.dart';
import 'package:barreled/src/util/version_helpers.dart';
import 'package:build/build.dart';
import 'package:collection/collection.dart';
import 'package:glob/glob.dart';
import 'package:pub_semver/pub_semver.dart';

class BarreledBuilder extends Builder {
  BarreledBuilder({
    BarreledOptions? options,
    PubspecReader? pubspecReader,
  }) {
    options ??= BarreledOptions();
    pubspecReader ??= PubspecReader();

    _files = BarrelFile.fromOptions(
      options,
      defaultName: () => '${pubspecReader!.packageName}.dart',
    );
    _dartVersion = pubspecReader.dartVersion.target;
  }

  late final Set<BarrelFile> _files;
  late final Version? _dartVersion;

  static const jsonAssetExtension = '.barreled.json';
  static final _jsonAssetGlob = Glob('**$jsonAssetExtension');

  @override
  late final buildExtensions = {r'$lib$': _files.names};

  Future<void> _readExportsFromAssets(BuildStep buildStep) async {
    final json = await buildStep
        .findAssets(_jsonAssetGlob)
        .asyncMap(buildStep.readAsString)
        .map((content) => (jsonDecode(content) as List).cast<Map<String, dynamic>>())
        .toList();
    _files.addExports(
      json.flattened.map(BarrelExport.fromJson).toList(),
    );
  }

  String _generateOutput(BarrelFile file) {
    final writer = DartWriter(languageVersion: _dartVersion);
    for (final export in file.exports) {
      writer.addExport(export);
    }
    return writer.write();
  }

  Future<void> _write(BuildStep buildStep, BarrelFile file) {
    return buildStep.writeAsString(
      AssetId(buildStep.inputId.package, file.path),
      _generateOutput(file),
    );
  }

  @override
  Future<void> build(BuildStep buildStep) async {
    await _readExportsFromAssets(buildStep);
    await Future.wait(_files.map((file) => _write(buildStep, file)));
  }
}

extension on DartWriter {
  void addExport(BarrelExport export) {
    addLine("export '${export.uri}'");
    if (export.show.isNotEmpty) {
      addLine('show ${export.show.sorted().join(',')}');
    }
    if (export.hide.isNotEmpty) {
      addLine('hide ${export.hide.sorted().join(',')}');
    }
    addLine(';');
  }
}
