import 'dart:async';
import 'dart:convert';

import 'package:analyzer/dart/element/element.dart';
import 'package:build/build.dart';
import 'package:exported/src/builder/exported_builder.dart';
import 'package:exported/src/model/export.dart';
import 'package:exported_annotation/exported_annotation.dart';
import 'package:meta/meta.dart';
import 'package:source_gen/source_gen.dart';

// TODO: Builder test for `BarreledExportsBuilder`.

class ExportedAssetsBuilder extends Builder {
  @override
  late final Map<String, List<String>> buildExtensions = {
    '.dart': [ExportedBuilder.jsonAssetExtension],
  };

  late final _generator = _BarreledExportsGenerator();

  @override
  Future<void> build(BuildStep buildStep) async {
    if (!await buildStep.isDartLibrary) return;

    final output = await _generator.generateForBuildStep(buildStep);
    if (output.isEmpty) return;

    await buildStep.writeAsString(
      buildStep.inputId.changeExtension(ExportedBuilder.jsonAssetExtension),
      sanitizeJson(output),
    );
  }

  /// Sanitizes the [json] output by replacing double newlines with commas and
  /// wrapping the result in square brackets to form a valid JSON array.
  @visibleForTesting
  static String sanitizeJson(String json) => '[${json.trim().replaceAll('\n\n', ',\n')}]';
}

class _BarreledExportsGenerator extends GeneratorForAnnotation<Exported> {
  static const _jsonEncoder = JsonEncoder.withIndent('  ');

  Future<String> generateForBuildStep(BuildStep buildStep) async {
    return generate(LibraryReader(await buildStep.inputLibrary), buildStep);
  }

  @override
  String generateForAnnotatedElement(
    Element element,
    ConstantReader annotation,
    BuildStep buildStep,
  ) {
    return _jsonEncoder.convert(
      Export.fromAnnotatedElement(element, annotation, buildStep).toJson(),
    );
  }
}

extension on BuildStep {
  /// Whether the current [inputId] represents a Dart library.
  Future<bool> get isDartLibrary => resolver.isLibrary(inputId);
}
