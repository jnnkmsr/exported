import 'package:dart_style/dart_style.dart';
import 'package:meta/meta.dart';
import 'package:pub_semver/pub_semver.dart';

/// Helper class for writing generated Dart source code.
///
/// Collects lines of code through [addLine] and writes them formatted using
/// [DartFormatter].
///
/// Adds a header comment of the form:
/// ```dart
/// // GENERATED CODE - DO NOT MODIFY BY HAND
/// ```
class DartWriter {
  DartWriter({this.languageVersion});

  /// The language version to use when formatting the code.
  ///
  /// Defaults to [DartFormatter.latestLanguageVersion].
  final Version? languageVersion;

  /// The header comment to include at the top of the generated file.
  @visibleForTesting
  static const header = '// GENERATED CODE - DO NOT MODIFY BY HAND';

  late final _buffer = StringBuffer()
    ..writeln(header)
    ..writeln();

  late final _formatter = DartFormatter(
    languageVersion: languageVersion ?? DartFormatter.latestLanguageVersion,
  );

  /// Adds a line of code.
  void addLine(String line) => _buffer.writeln(line);

  /// Writes the formatted code including the header comment and all lines that
  /// have been added through [addLine].
  String write() => _formatter.format(_buffer.toString());
}
