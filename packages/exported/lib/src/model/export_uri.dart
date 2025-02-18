import 'package:exported/src/builder/exported_option_keys.dart' as keys;

typedef ExportFromJson = ExportUri Function(Map json);
typedef ExportFromOptions = ExportUri Function(dynamic options);

extension type const ExportUri(String _value) implements Object {
  factory ExportUri.fromCache(Map json) => ExportUri(json[keys.uri] as String);

  factory ExportUri.fromOptions(dynamic options) {
    // TODO: implement fromJson
    return ExportUri(options as String);
  }

  Map<String, dynamic> toCache() => {keys.uri: _value};
}
