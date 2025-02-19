import 'package:build/build.dart';
import 'package:exported/src/builder/cache_builder.dart';
import 'package:exported/src/builder/exported_builder.dart';
import 'package:exported_annotation/exported_annotation.dart';

/// Reads intermediate JSON containing elements annotated with [Exported] and
/// generates the barrel files, taking into account the builder [options].
///
/// Needs [cacheBuilder] to be run first to generate the intermediate JSON into
/// the build cache.
Builder exportedBuilder(BuilderOptions options) => ExportedBuilder(options);

/// Collects elements annotated with [Exported] and stores them as JSON into
/// the build cache.
///
/// This allows [exportedBuilder] to run without using a [Resolver], which
/// would invalidate output on any change of the target package or any of its
/// transitive imports.
Builder cacheBuilder(BuilderOptions _) => CacheBuilder();
