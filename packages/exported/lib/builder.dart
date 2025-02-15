import 'package:build/build.dart';
import 'package:exported/src/builder/exported_builder.dart';

/// Generates Dart barrel files from annotated elements and builder [options].
Builder exportedBuilder(BuilderOptions options) => ExportedBuilder(options);
