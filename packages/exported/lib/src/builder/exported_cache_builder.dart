import 'package:build/build.dart';
import 'package:exported/src/model/export_new.dart';
import 'package:exported/src/model/export_uri.dart';
import 'package:exported/src/model/exported_option_keys.dart' as keys;
import 'package:exported/src/model/tag.dart';
import 'package:source_gen/source_gen.dart';

class ExportedCacheBuilder implements Builder {
  @override
  Map<String, List<String>> get buildExtensions => {
        '.dart': ['.exported.json'],
      };

  final Map<Tag, Map<ExportUri, Export>> _exportsByTag = {};

  void addExport(Export export) {
    _exportsByTag.putIfAbsent(export.tag, () => {}).update(
          export.uri,
          (existing) => existing.merge(export),
          ifAbsent: () => export,
        );
  }

  Export export(AnnotatedElement annotatedElement) {
    final tagReader = annotatedElement.annotation.read(keys.tags);

    throw UnimplementedError();
  }

  @override
  Future<void> build(BuildStep buildStep) async {
    final libraryAsset = buildStep.inputId;
    final resolver = buildStep.resolver;
    if (!await resolver.isLibrary(libraryAsset)) return;

    final library = await resolver.libraryFor(libraryAsset);
  }

}
