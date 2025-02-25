import 'package:exported/src/builder/exported_option_keys.dart' as keys;

// TODO[BarrelFilePath]: Input validation/sanitization
// TODO[BarrelFilePath]: Unit tests
// TODO[BarrelFilePath]: Documentation

/// Represents the URI of a Dart `export` directive.
extension type const BarrelFilePath(String _) implements String {
  factory BarrelFilePath.fromJson(Map<String, dynamic> json) => BarrelFilePath(json[keys.path] as String);

  factory BarrelFilePath.fromInput(dynamic input) {
    if (input is Map) {
      input = input[keys.uri];
    }
    if (input is! String) {
      throw ArgumentError.value(input, keys.path, 'Must be a string');
    }

    // Input validation/sanitization

    return BarrelFilePath(input);
  }

  Map<String, dynamic> toJson() => {keys.path: this as String};
}
