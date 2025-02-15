import 'package:analyzer/dart/element/element.dart';
import 'package:build/build.dart';
import 'package:exported/src/builder/barrel_file_generator.dart';
import 'package:exported/src/model/barrel_file.dart';
import 'package:exported/src/model/export.dart';
import 'package:exported/src/model/exported_options.dart';
import 'package:exported_annotation/exported_annotation.dart';
import 'package:glob/glob.dart';
import 'package:path/path.dart' as p;
import 'package:source_gen/source_gen.dart';

// TODO: Remove PubspecReader and read from BuildStep instead

/// Generates Dart barrel files from annotated elements and builder options.
class ExportedBuilder implements Builder {
  /// Creates a builder instance with the provided [options].
  ExportedBuilder(BuilderOptions options) {
    final exportedOptions = ExportedOptions.fromOptions(options);
    _barrelFiles = exportedOptions.barrelFiles;
    _exports = exportedOptions.exports;
  }

  late final List<BarrelFile> _barrelFiles;
  late final List<Export> _exports;

  @override
  Map<String, List<String>> get buildExtensions =>
      {r'$lib$': _barrelFiles.map((file) => file.path).toList()};

  @override
  Future<void> build(BuildStep buildStep) async {
    /// Collects all exports from a single library asset.
    Future<void> processLibrary(AssetId assetId) => buildStep.resolver
        .libraryFor(assetId)
        .then((element) => _exports.addAll(_libraryExports(assetId, element)));

    /// Writes the given [file] with all collected exports.
    Future<void> writeFile(BarrelFile file) => buildStep.writeAsString(
          AssetId(buildStep.inputId.package, p.join('lib', file.path)),
          BarrelFileGenerator(file: file, exports: _exports).generate(),
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
