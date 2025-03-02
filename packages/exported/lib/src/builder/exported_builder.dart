import 'dart:async';
import 'dart:convert';

import 'package:build/build.dart';
import 'package:dart_style/dart_style.dart';
import 'package:exported/src/builder/cache_builder.dart';
import 'package:exported/src/model/export.dart';
import 'package:exported/src/model/export_cache.dart';
import 'package:exported/src/model/exported_options.dart';
import 'package:exported/src/util/pubspec_reader.dart';
import 'package:glob/glob.dart';
import 'package:path/path.dart' as path;

class ExportedBuilder extends Builder {
  /// Creates an [ExportedBuilder], parsing and validating builder [options]
  /// into [ExportedOptions].
  ///
  /// In tests, provide a fake [pubspecReader] to override the default instance
  /// for reading `pubspec.yaml` files.
  ExportedBuilder(
    BuilderOptions options, {
    PubspecReader? pubspecReader,
  }) : options = ExportedOptions.fromInput(options.config, pubspecReader);

  /// Barrel-file and exports options parsed from the builder options.
  final ExportedOptions options;

  @override
  Map<String, List<String>> get buildExtensions => {
        r'$lib$': options.barrelFiles.map((file) => file.path).toList(),
      };

  /// Reads all JSON [ExportCache] files written into the build cache by
  /// [CacheBuilder] and merges them together with the exports from the builder
  /// [options].
  Future<ExportCache> _readExportsFromJson(BuildStep buildStep) async {
    final cachesPerLibrary = await buildStep
        .findAssets(Glob('**${CacheBuilder.jsonExtension}'))
        .asyncMap(buildStep.readAsString)
        .map((json) => ExportCache.fromJson(jsonDecode(json) as Map))
        .toList();
    return ExportCache.merged(cachesPerLibrary);
  }

  @override
  Future<void> build(BuildStep buildStep) async {
    final cache = await _readExportsFromJson(buildStep)..add(options.exports);
    for (final file in options.barrelFiles) {
      await buildStep.writeAsString(
        AssetId(buildStep.inputId.package, path.join('lib', file.path)),
        _BarrelFileWriter().write(cache.matchingExports(file)),
      );
    }
  }
}

/// Helper class for writing the contents of a barrel file.
class _BarrelFileWriter {
  static const _header = '// GENERATED CODE - DO NOT MODIFY BY HAND';
  static final _formatter = DartFormatter(
    languageVersion: DartFormatter.latestLanguageVersion,
  );

  late final StringBuffer _buffer = StringBuffer()
    ..writeln(_header)
    ..writeln();

  /// Returns formatted Dart code with directives for all given [exports].
  ///
  /// Adds a header comment of the form:
  /// ```dart
  /// // GENERATED CODE - DO NOT MODIFY BY HAND
  /// ```
  String write(Iterable<Export> exports) {
    for (final export in exports) {
      _buffer.writeln(export.toDart());
    }
    return _formatter.format(_buffer.toString());
  }
}
