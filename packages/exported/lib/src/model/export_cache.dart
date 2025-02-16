import 'package:exported/src/model/export_new.dart';
import 'package:exported/src/model/export_uri.dart';
import 'package:exported/src/model/tag.dart';

class ExportCache {
  final Map<Tag, Map<ExportUri, Export>> _exportsByTag = {};

  void add(Export export) => _exportsByTag.putIfAbsent(export.tag, () => {}).update(
        export.uri,
        (existing) => existing.merge(export),
        ifAbsent: () => export,
      );
}
