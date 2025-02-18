import 'package:exported/src/model/export_filter.dart';
import 'package:exported/src/model/export_uri.dart';
import 'package:exported/src/model/tag.dart';

class Export {
  const Export._(
    this.uri,
    ExportFilter? filter,
    Tags? tags,
  )   : _filter = filter ?? ExportFilter.none,
        tags = tags ?? Tags.none;

  Export.fromAnnotation(
    String uri,
    String element,
    Iterable<String> tags,
  )   : uri = ExportUri(uri),
        _filter = ExportFilter.showElement(element),
        tags = Tags.parse(tags);

  Export.fromCache(Map json)
      : uri = ExportUri.fromCache(json),
        _filter = ExportFilter.fromCache(json),
        tags = Tags.fromCache(json);

  final ExportUri uri;
  final Tags tags;
  final ExportFilter _filter;

  Export merge(Export other) {
    if (uri != other.uri) return this;
    return Export._(uri, _filter.merge(other._filter), tags);
  }

  Map<Tag, Export> splitByTag() =>
      {for (final tag in tags) tag: Export._(uri, _filter, Tags.single(tag))};

  Map toCache() => {...uri.toCache(), ...tags.toCache(), ..._filter.toCache()};
}

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
