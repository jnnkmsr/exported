import 'package:exported/src/model/export_filter.dart';
import 'package:exported/src/model/export_uri.dart';
import 'package:exported/src/model/exported_option_keys.dart' as keys;
import 'package:exported/src/model/option_collections.dart';
import 'package:meta/meta.dart';

/// Represents an export directive to be written into a generated barrel file.
///
/// Created either from an annotated named element by [Export.element] an
/// annotated library by [Export.library], or by [Export.fromInput] parsing
/// `exports` builder options.
///
/// The [uri] specifies the full `package:` or `dart:` URI of the exported
/// library, and [filter] specifies `show` or `hide` combinators.
@immutable
class Export {
  const Export._(
    this.uri, [
    this.filter = ExportFilter.none,
  ]);

  /// Creates an [Export] for an annotated named element.
  ///
  /// The [uri] should be obtained from the parenting library and is not
  /// validated. The [name] should be the name of the annotated element.
  ///
  /// The resulting [Export] will have a [filter] with a single `show`
  /// combinator for the [name].
  Export.element({
    required String uri,
    required String name,
  }) : this._(ExportUri(uri), ExportFilter.showSingle(name));

  /// Creates an [Export] for an annotated library.
  ///
  /// The [uri] should be obtained from the library element and is not
  /// validated.
  ///
  /// Optional [show] or [hide] sets can be provided to create a [filter]. If
  /// not provided, the resulting [Export] will have no filter, exporting the
  /// entire library.
  Export.library({
    required String uri,
    Set<String>? show,
    Set<String>? hide,
  }) : this._(ExportUri(uri), ExportFilter.fromInput(show: show, hide: hide));

  /// Creates a list of [Export]s from the `exports` builder options [input].
  ///
  /// Input may either be a single element or a list of elements, each of which
  /// can be a string or a map. String input is parsed as a URI, with [filter]
  /// defaulting to [ExportFilter.none]. Map input may contain `uri`, `show`,
  /// and `hide` keys.
  ///
  /// If the input is empty or null, an empty list is returned. Exports without
  /// a `uri` key will throw an [ArgumentError].
  ///
  /// Duplicate exports with matching [uri] will be kept and merged later when
  /// writing them to the builder cache or the generated barrel file.
  ///
  /// See [ExportUri.fromInput] and [ExportFilter.fromInput] for input
  /// validation and sanitization of [uri] and [filter].
  static OptionList<Export> fromInput(dynamic input) => OptionList.fromInput(
        input,
        (element) => parseInputMap(
          input,
          parentKey: keys.barrelFiles,
          validKeys: const {keys.uri, keys.show, keys.hide, keys.tags},
          parseMap: (input) => Export._(
            ExportUri.fromInput(input),
            ExportFilter.fromInput(options: input),
          ),
          parseString: (input) => Export._(ExportUri.fromInput(input)),
        ),
      );

  /// Restores an [Export] from internal [json] without any validation.
  Export.fromJson(Map json) : this._(ExportUri.fromJson(json), ExportFilter.fromJson(json));

  /// Specifies the full `package:` or `dart:` URI of the exported library.
  final ExportUri uri;

  /// Optional `show` or `hide` combinators for the export directive. Defaults
  /// to [ExportFilter.none], exporting the entire library.
  final ExportFilter filter;

  /// Returns an [Export] with a merged [filter] if the [uri] matches, or
  /// returns this instance unchanged.
  ///
  /// See [ExportFilter.merge] for merging behavior.
  Export merge(Export other) =>
      (uri == other.uri) ? Export._(uri, filter.merge(other.filter)) : this;

  /// Converts this [Export] to JSON for storage in the build cache.
  Map toJson() => {...uri.toJson(), ...filter.toJson()};

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Export &&
          runtimeType == other.runtimeType &&
          uri == other.uri &&
          filter == other.filter;

  @override
  int get hashCode => Object.hash(runtimeType, uri, filter);

  @override
  String toString() => '$Export{uri: $uri, filter: $filter}';
}
