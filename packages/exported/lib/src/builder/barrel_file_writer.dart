import 'package:dart_style/dart_style.dart';
import 'package:exported/src/model/export.dart';

/// Helper class for writing the contents of a barrel file.
class BarrelFileWriter {
  static const _header = '// GENERATED CODE - DO NOT MODIFY BY HAND';
  static final _formatter = DartFormatter(
    languageVersion: DartFormatter.latestLanguageVersion,
  );

  late final StringBuffer _buffer = StringBuffer()
    ..writeln(_header)
    ..writeln();

  /// Returns formatted Dart code with directives for all given [exports].
  ///
  /// Adds a header comment of the form:
  /// ```dart
  /// // GENERATED CODE - DO NOT MODIFY BY HAND
  /// ```
  String write(Iterable<Export> exports) {
    for (final export in exports) {
      _buffer.writeln(export.toDart());
    }
    return _formatter.format(_buffer.toString());
  }
}
