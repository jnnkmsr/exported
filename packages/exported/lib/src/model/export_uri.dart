import 'package:exported/src/builder/exported_option_keys.dart' as keys;

typedef ExportFromJson = ExportUri Function(Map json);
typedef ExportFromOptions = ExportUri Function(dynamic options);

extension type const ExportUri(String _value) implements Object {
  factory ExportUri.fromJson(Map json) => ExportUri(json[keys.uri] as String);

  // TODO[ExportUri]: Implement fromOptions
  factory ExportUri.fromOptions(dynamic options) {
    return ExportUri(options as String);
  }

  Map toCache() => {keys.uri: _value};
}
