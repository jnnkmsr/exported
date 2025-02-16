import 'package:exported/src/model/export_filter.dart';
import 'package:exported/src/model/export_uri.dart';
import 'package:exported/src/model/parser.dart';
import 'package:exported/src/model/tag.dart';

class Export {
  const Export._({
    required this.uri,
    this.show = Show.empty,
    this.hide = Hide.empty,
    this.tag = Tag.none,
  });

  factory Export.parse(dynamic input) => switch (input) {
        String _ => Export._(uri: parser.uri(input)),
        Map _ => Export._parseJson(input),
        _ => throw ArgumentError('Must be a single URI or key-value input: $input'),
      };

  factory Export._parseJson(Map json) {
    final hide = parser.hide(json);
    return Export._(
      uri: parser.uri(json),
      show: hide.isEmpty ? parser.show(json) : Show.empty,
      hide: hide,
      tag: parser.tag(json),
    );
  }

  Export merge(Export other) {
    // [x]               |               ->
    // [x]               | show foo, baz ->
    // [x]               | hide foo, baz ->
    //
    // [x] show foo, bar | show foo, baz -> show foo, bar, baz
    // [ ] show foo, bar | hide foo, baz -> hide baz
    //
    // [ ] hide foo, bar | hide foo, baz -> hide foo
    if (uri != other.uri ||
        tag != other.tag ||
        (show.isEmpty && hide.isEmpty || other.show.isEmpty && other.hide.isEmpty)) {
      return this;
    }

    final hasShow = hide.isEmpty && other.hide.isEmpty;
    final showUnion = show.union(other.show);
    final mergedShow = (show.isNotEmpty && other.show.isNotEmpty) ? showUnion : Show.empty;

    return Export._(
      uri: uri,
      show: show.merge(other.show, other.hide),
      hide: hide.merge(other.show, other.hide),
      tag: tag,
    );
  }

  final ExportUri uri;
  final Show show;
  final Hide hide;
  final Tag tag;
}
