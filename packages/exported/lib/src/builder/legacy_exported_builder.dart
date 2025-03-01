import 'package:analyzer/dart/element/element.dart';
import 'package:build/build.dart';
import 'package:exported/src/builder/legacy_barrel_file_writer.dart';
import 'package:exported/src/model_legacy/barrel_file.dart';
import 'package:exported/src/model_legacy/export.dart';
import 'package:exported/src/model_legacy/exported_options.dart';
import 'package:exported_annotation/exported_annotation.dart';
import 'package:glob/glob.dart';
import 'package:meta/meta.dart';
import 'package:path/path.dart' as p;
import 'package:source_gen/source_gen.dart';

/// Generates Dart barrel files from annotated elements and builder options.
@Deprecated('Use ExportedBuilder instead.')
class LegacyExportedBuilder implements Builder {
  /// Creates a builder instance with the provided [options].
  @Deprecated('Use ExportedBuilder instead.')
  LegacyExportedBuilder(BuilderOptions options) {
    final exportedOptions = ExportedOptions.fromOptions(options);
    _barrelFiles = exportedOptions.barrelFiles;
    _exports = exportedOptions.exports;
  }

  late final List<BarrelFile> _barrelFiles;
  late final List<Export> _exports;

  @override
  Map<String, List<String>> get buildExtensions =>
      {r'$lib$': _barrelFiles.map((file) => file.path).toList()};

  @visibleForTesting
  static LegacyBarrelFileWriter writer = LegacyBarrelFileWriter();

  @override
  Future<void> build(BuildStep buildStep) async {
    /// Collects all exports from a single library asset.
    Future<void> processLibrary(AssetId assetId) => buildStep.resolver
        .libraryFor(assetId)
        .then((element) => _exports.addAll(_libraryExports(assetId, element)));

    /// Writes the given [file] with all collected exports.
    Future<void> writeFile(BarrelFile file) => buildStep.writeAsString(
          AssetId(buildStep.inputId.package, p.join('lib', file.path)),
          writer.write(file.buildExports(_exports)),
        );

    final assets = buildStep.findAssets(Glob('lib/**.dart'));
    await for (final assetId in assets) {
      if (!await buildStep.resolver.isLibrary(assetId)) continue;
      await processLibrary(assetId);
    }
    await Future.wait(_barrelFiles.map(writeFile));
  }

  /// Reads [Export]s from annotated elements from a single library asset.
  static Iterable<Export> _libraryExports(AssetId assetId, LibraryElement element) {
    Export export(AnnotatedElement element) => Export.fromAnnotatedElement(assetId, element);
    return LibraryReader(element)
        .annotatedWith(const TypeChecker.fromRuntime(Exported))
        .map(export);
  }
}
