import 'package:exported/src/model/export_uri.dart';
import 'package:exported/src/model/filter.dart';
import 'package:exported/src/model/tag.dart';

class Export {
  const Export._(
    this.uri,
    Filter? filter,
    Tag? tag,
  )   : _filter = filter ?? Filter.none,
        tag = tag ?? Tag.none;

  Export.fromJson(Map json)
      : uri = ExportUri.fromJson(json),
        _filter = Filter.fromJson(json),
        tag = Tag.fromJson(json);

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

  static Iterable<Export> element({
    required String uri,
    required String name,
    Iterable<String> tags = const [],
  }) =>
      _splitByTag(tags, (tag) => Export._(ExportUri(uri), Filter.show(name), tag));

  static Iterable<Export> library({
    required String uri,
    Iterable<String> tags = const [],
  }) {
    // final filter = name == null ? Filter.none : Filter.show(name);
    return _splitByTag(tags, (tag) => Export._(ExportUri(uri), Filter.none, tag));
  }

  static Iterable<Export> _splitByTag(
    Iterable<String> tags,
    Export Function(Tag tag) builder,
  ) =>
      Tags.parse(tags).map(builder);

  final ExportUri uri;
  final Tag tag;
  final Filter _filter;

  Export merge(Export other) {
    if (uri != other.uri) return this;
    return Export._(uri, _filter.merge(other._filter), tag);
  }

  Map toJson() => {...uri.toCache(), ...tag.toJson(), ..._filter.toJson()};
}
