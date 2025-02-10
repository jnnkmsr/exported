import 'dart:async';
import 'dart:convert';

import 'package:build/build.dart';
import 'package:collection/collection.dart';
import 'package:exported/src/builder/dart_writer.dart';
import 'package:exported/src/model/barrel_file.dart';
import 'package:exported/src/model/export.dart';
import 'package:exported/src/options/exported_options.dart';
import 'package:exported/src/util/pubspec_reader.dart';
import 'package:glob/glob.dart';
import 'package:meta/meta.dart';
import 'package:path/path.dart' as p;
import 'package:pub_semver/pub_semver.dart';

class ExportedBuilder extends Builder {
  ExportedBuilder({
    ExportedOptions? options,
  }) {
    _files = BarrelFile.fromOptions(options ?? ExportedOptions());
    _dartVersion = pubspecReader.sdkVersion.target;
  }

  @override
  late final buildExtensions = {r'$lib$': _files.paths};
  late final Set<BarrelFile> _files;
  late final Version? _dartVersion;

  @visibleForTesting
  static PubspecReader pubspecReader = PubspecReader.instance();

  static const jsonAssetExtension = '.exported.json';

  Future<void> _readExportsFromAssets(BuildStep buildStep) async {
    final json = await buildStep
        .findAssets(Glob('**$jsonAssetExtension'))
        .asyncMap(buildStep.readAsString)
        .map((content) => (jsonDecode(content) as List).cast<Map<String, dynamic>>())
        .toList();
    _files.addExports(
      json.flattened.map(Export.fromJson).toList(),
    );
  }

  String _generateOutput(BarrelFile file) {
    final writer = DartWriter(languageVersion: _dartVersion);
    for (final export in file.exports) {
      writer.addLine("export '${export.uri}'");
      if (export.show.isNotEmpty) {
        writer.addLine('show ${export.show.sorted().join(',')}');
      }
      if (export.hide.isNotEmpty) {
        writer.addLine('hide ${export.hide.sorted().join(',')}');
      }
      writer.addLine(';');
    }
    return writer.write();
  }

  Future<void> _write(BuildStep buildStep, BarrelFile file) {
    return buildStep.writeAsString(
      AssetId(buildStep.inputId.package, p.join('lib', file.path)),
      _generateOutput(file),
    );
  }

  @override
  Future<void> build(BuildStep buildStep) async {
    await _readExportsFromAssets(buildStep);
    await Future.wait(_files.map((file) => _write(buildStep, file)));
  }
}

extension on VersionConstraint {
  Version? get target => switch (this) {
        final Version version => version,
        final VersionRange range => range.min ?? range.max,
        _ => null,
      };
}

/// Convenience accessors for [BarrelFile] iterables.
extension on Iterable<BarrelFile> {
  void addExports(Iterable<Export> exports) {
    for (final file in this) {
      file.addExports(exports);
    }
  }

  List<String> get paths => [for (final file in this) file.path];
}
