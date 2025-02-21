import 'package:exported/src/model/export_filter.dart';
import 'package:exported/src/model/export_uri.dart';
import 'package:meta/meta.dart';

@immutable
class Export {
  const Export._({
    required this.uri,
    required this.filter,
  });

  Export.element({
    required String uri,
    required String name,
  })  : uri = ExportUri(uri),
        filter = ExportFilter.showElement(name);

  Export.library({
    required String uri,
    Set<String>? show,
    Set<String>? hide,
  })  : uri = ExportUri(uri),
        filter = ExportFilter.fromInput(show: show, hide: hide);

  factory Export.fromInput(dynamic options) => switch (options) {
        String _ => Export._(
            uri: ExportUri.fromInput(options),
            filter: ExportFilter.none,
          ),
        Map _ => Export._(
            uri: ExportUri.fromInput(options),
            filter: ExportFilter.fromInput(options: options),
          ),
        _ => throw ArgumentError.value(options, 'options', 'Must be a string or map'),
      };

  Export.fromJson(Map<String, dynamic> json)
      : uri = ExportUri.fromJson(json),
        filter = ExportFilter.fromJson(json);

  final ExportUri uri;
  final ExportFilter filter;

  Export merge(Export other) =>
      (uri == other.uri) ? Export._(uri: uri, filter: filter.merge(other.filter)) : this;

  Map<String, dynamic> toJson() => {...uri.toJson(), ...filter.toJson()};

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Export &&
          runtimeType == other.runtimeType &&
          uri == other.uri &&
          filter == other.filter;

  @override
  int get hashCode => uri.hashCode ^ filter.hashCode;
}
