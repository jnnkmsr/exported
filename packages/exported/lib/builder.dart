import 'package:build/build.dart';
import 'package:exported/src/builder/exported_assets_builder.dart';
import 'package:exported/src/builder/exported_builder.dart';
import 'package:exported/src/model/exported_options.dart';
import 'package:exported_annotation/exported_annotation.dart';

/// Generates Dart barrel files by processing JSON data written into the build
/// cache by [exportedAssetsBuilder].
///
/// Takes additional `build.yaml` configuration [options].
Builder exportedBuilder(BuilderOptions options) =>
    ExportedBuilder(options: ExportedOptions.fromOptions(options));

/// Collects elements annotated with [exported] and converts them into JSON
/// assets written into the build cache for [exportedBuilder] to process.
Builder exportedAssetsBuilder(BuilderOptions _) => ExportedAssetsBuilder();
