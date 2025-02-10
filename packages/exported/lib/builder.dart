import 'package:build/build.dart';
import 'package:exported/src/builder/exported_assets_builder.dart';
import 'package:exported/src/builder/exported_builder.dart';
import 'package:exported/src/options/exported_options.dart';
import 'package:exported_annotation/exported_annotation.dart';

/// Generates Dart barrel files from [exported] elements and specified build
/// options.
///
/// Needs previous execution of [exportedAssetsBuilder] to generate the
/// intermediate JSON files into the build cache.
Builder exportedBuilder(BuilderOptions options) {
  return ExportedBuilder(
    options: ExportedOptions.fromOptions(options),
  );
}

/// Generates intermediate JSON files with barrel-file exports into the build
/// cache.
Builder exportedAssetsBuilder(BuilderOptions _) => ExportedAssetsBuilder();
