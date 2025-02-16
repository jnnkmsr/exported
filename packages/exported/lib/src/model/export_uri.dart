import 'package:meta/meta.dart';

extension type const ExportUri._(String _) implements Object {
  @visibleForTesting
  const ExportUri(this._);

  factory ExportUri.parse(dynamic input) {
    return ExportUri._(input as String);
  }
}
