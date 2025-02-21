import 'package:exported/src/builder/exported_option_keys.dart' as keys;

/// Represents the URI of a Dart `export` directive.
extension type const ExportUri(String _) implements String {
  factory ExportUri.fromJson(Map<String, dynamic> json) => ExportUri(json[keys.uri] as String);

  factory ExportUri.fromInput(dynamic options) {
    if (options is Map) {
      options = options[keys.uri];
    }
    if (options is! String) {
      throw ArgumentError.value(options, keys.uri, 'Must be a string');
    }

    // TODO[ExportUri]: Validate/sanitize the URI

    return ExportUri(options);
  }

  Map<String, dynamic> toJson() => {keys.uri: this as String};
}
