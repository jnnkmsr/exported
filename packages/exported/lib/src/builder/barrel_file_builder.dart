import 'dart:async';
import 'dart:convert';

import 'package:build/build.dart';
import 'package:dart_style/dart_style.dart';
import 'package:exported/src/builder/export_cache.dart';
import 'package:exported/src/builder/export_cache_builder.dart';
import 'package:exported/src/model/export.dart';
import 'package:exported/src/model/exported_options.dart';
import 'package:exported/src/util/pubspec_reader.dart';
import 'package:exported_annotation/exported_annotation.dart';
import 'package:file/file.dart';
import 'package:file/local.dart';
import 'package:file/memory.dart';
import 'package:glob/glob.dart';
import 'package:path/path.dart' as path;
import 'package:source_gen/source_gen.dart';

/// Reads intermediate JSON containing elements annotated with [Exported] and
/// generates the barrel files, taking into account the builder [_options].
class BarrelFileBuilder extends Builder {
  /// Creates an [BarrelFileBuilder], parsing and validating builder [options]
  /// into [ExportedOptions].
  ///
  /// Uses the [fileSystem] to read the package name from the `pubspec.yaml`,
  /// defaulting to [LocalFileSystem]. Provide a [MemoryFileSystem] in tests.
  BarrelFileBuilder(
    BuilderOptions options, [
    FileSystem? fileSystem,
  ]) : _options = ExportedOptions.fromInput(
          options.config,
          package: PubspecReader(fileSystem).name,
        );

  /// Barrel-file and exports options parsed from the builder options.
  final ExportedOptions _options;

  @override
  Map<String, List<String>> get buildExtensions => {
        r'$lib$': _options.barrelFiles.map((file) => file.path).toList(),
      };

  /// Reads all JSON [ExportCache] files written into the build cache by
  /// [ExportCacheBuilder] and merges them together with the exports from the builder
  /// [_options].
  Future<ExportCache> _readExportsFromJson(BuildStep buildStep) async {
    final cachesPerLibrary = await buildStep
        .findAssets(Glob('**${ExportCacheBuilder.jsonExtension}'))
        .asyncMap(buildStep.readAsString)
        .map(_readExportCacheJson)
        .toList();
    return ExportCache.merged(cachesPerLibrary);
  }

  /// Restores a single [ExportCache] from [json].
  ///
  /// Throws an [InvalidGenerationSourceError] if the JSON is invalid.
  ExportCache _readExportCacheJson(String json) {
    try {
      return ExportCache.fromJson(jsonDecode(json) as Map);
    } catch (e) {
      throw InvalidGenerationSourceError('Error reading JSON exports from cache: $e');
    }
  }

  @override
  Future<void> build(BuildStep buildStep) async {
    final cache = await _readExportsFromJson(buildStep)
      ..add(_options.exports);
    final package = buildStep.inputId.package;
    await Future.wait(
      _options.barrelFiles.map(
        (file) => buildStep.writeAsString(
          AssetId(package, path.join('lib', file.path)),
          _BarrelFileWriter().write(cache.matchingExports(file)),
        ),
      ),
    );
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
