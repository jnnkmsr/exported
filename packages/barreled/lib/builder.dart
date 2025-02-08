import 'package:barreled/src/builder/barreled_builder.dart';
import 'package:barreled/src/builder/barreled_exports_builder.dart';
import 'package:barreled/src/options/barreled_builder_options.dart';
import 'package:build/build.dart';

/// Generates Dart barrel files from package elements and specified build
/// options.
///
/// Needs previous execution of [barreledExportsBuilder] to generate the
/// intermediate JSON files into the build cache.
Builder barreledBuilder(BuilderOptions options) {
  return BarreledBuilder(
    options: BarreledBuilderOptions.fromOptions(options),
  );
}

/// Generates intermediate JSON files with barrel-file exports into the build
/// cache.
Builder barreledExportsBuilder(BuilderOptions _) {
  return BarreledExportsBuilder(
    partId: _partId,
  );
}

const _partId = 'barreled';
