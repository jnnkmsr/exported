import 'package:build/build.dart';

extension BuildStepExtension on BuildStep {
  /// Whether the current [inputId] represents a Dart library.
  Future<bool> get isDartLibrary => resolver.isLibrary(inputId);
}
