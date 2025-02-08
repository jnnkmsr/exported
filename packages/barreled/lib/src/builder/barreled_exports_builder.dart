import 'dart:async';
import 'dart:convert';

import 'package:analyzer/dart/element/element.dart';
import 'package:barreled/src/builder/barreled_builder.dart';
import 'package:barreled/src/model/barrel_export.dart';
import 'package:barreled/src/util/build_extensions.dart';
import 'package:barreled_annotation/barreled_annotation.dart';
import 'package:build/build.dart';
import 'package:meta/meta.dart';
import 'package:source_gen/source_gen.dart';

// TODO: Builder test for `BarreledExportsBuilder`.

class BarreledExportsBuilder extends Builder {
  @override
  late final Map<String, List<String>> buildExtensions = {
    '.dart': [BarreledBuilder.jsonAssetExtension],
  };

  late final _generator = _BarreledExportsGenerator();

  @override
  Future<void> build(BuildStep buildStep) async {
    if (!await buildStep.isDartLibrary) return;

    final output = await _generator.generateForBuildStep(buildStep);
    if (output.isEmpty) return;

    await buildStep.writeAsString(
      buildStep.inputId.changeExtension(BarreledBuilder.jsonAssetExtension),
      sanitizeJson(output),
    );
  }

  /// Sanitizes the [json] output by replacing double newlines with commas and
  /// wrapping the result in square brackets to form a valid JSON array.
  @visibleForTesting
  static String sanitizeJson(String json) => '[${json.trim().replaceAll('\n\n', ',\n')}]';
}

class _BarreledExportsGenerator extends GeneratorForAnnotation<Barreled> {
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
      BarrelExport.fromAnnotatedElement(element, annotation, buildStep).toJson(),
    );
  }
}
