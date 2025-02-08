import 'package:dart_style/dart_style.dart';
import 'package:pub_semver/pub_semver.dart';

// TODO: Unit test DartWriter

class DartWriter {
  DartWriter({
    Version? languageVersion,
  }) : _languageVersion = languageVersion;

  final Version? _languageVersion;

  late final _buffer = StringBuffer()
    ..writeln(_headerLine)
    ..writeln();

  late final _formatter = DartFormatter(
    languageVersion: _languageVersion ?? DartFormatter.latestLanguageVersion,
  );

  void addLine(String line) => _buffer.writeln(line);

  String write() => _formatter.format(_buffer.toString());
}

const _headerLine = '// GENERATED CODE - DO NOT MODIFY BY HAND';
