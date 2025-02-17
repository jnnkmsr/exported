import 'package:exported/src/model/export_filter.dart';
import 'package:exported/src/model/export_uri.dart';
import 'package:exported/src/model/reader.dart';
import 'package:exported/src/model/tag.dart';
import 'package:source_gen/source_gen.dart';

class Export {
  const Export._(
    this.uri,
    Tags? tags,
    ExportFilter? filter,
  )   : tags = tags ?? Tags.none,
        _filter = filter ?? ExportFilter.none;

  Export.fromAnnotatedElement(
    Uri uri,
    AnnotatedElement annotatedElement, {
    Reader<ExportUri, Uri> uriReader = ExportUri.fromUri,
    Reader<Tags, ConstantReader> tagsReader = Tags.fromAnnotation,
    Reader<ExportFilter, AnnotatedElement> filterReader = ExportFilter.fromAnnotatedElement,
  })  : uri = uriReader(uri),
        tags = tagsReader(annotatedElement.annotation),
        _filter = filterReader(annotatedElement);

  Export.fromCache(
    Map json, {
    CacheReader<ExportUri> uri = ExportUri.fromCache,
    CacheReader<Tags> tags = Tags.fromCache,
    CacheReader<ExportFilter> filter = ExportFilter.fromCache,
  })  : uri = uri(json),
        tags = tags(json),
        _filter = filter(json);

  // factory Export.fromOptions(
  //   dynamic options, {
  //   ExportFromOptions uri = ExportUri.fromOptions,
  // }) =>
  //     switch (options) {
  //       String _ => Export._(uri(options)),
  //       Map _ => Export._(
  //           uri(options),
  //         ),
  //       _ => throw ArgumentError('Must be a single URI or key-value input: $options'),
  //     };

  final ExportUri uri;
  final Tags tags;
  final ExportFilter _filter;

  Export merge(Export other) {
    if (uri != other.uri) return this;
    return Export._(uri, tags, _filter.merge(other._filter));
  }

  Map<Tag, Export> splitByTag() =>
      {for (final tag in tags) tag: Export._(uri, Tags.single(tag), _filter)};

  Map toCache() => {...uri.toCache(), ...tags.toCache(), ..._filter.toCache()};
}
