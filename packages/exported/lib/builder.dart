import 'package:build/build.dart';
import 'package:exported/src/builder/barrel_file_builder.dart';
import 'package:exported/src/builder/export_cache_builder.dart';
import 'package:exported_annotation/exported_annotation.dart';
import 'package:file/file.dart';
import 'package:file/local.dart';
import 'package:file/memory.dart';

/// Collects elements annotated with [Exported] and stores them as JSON into
/// the build cache.
///
/// This allows [barrelFileBuilder] to run without using a [Resolver], which
/// would invalidate output on any change of the target package or any of its
/// transitive imports.
Builder exportCacheBuilder(BuilderOptions _) => ExportCacheBuilder();

/// Reads intermediate JSON containing elements annotated with [Exported] and
/// generates the barrel files, taking into account the builder [options].
///
/// Needs [exportCacheBuilder] to be run first to generate the intermediate
/// JSON into the build cache.
///
/// Uses the [fileSystem] to read the package name from the `pubspec.yaml`,
/// defaulting to [LocalFileSystem]. Provide a [MemoryFileSystem] in tests.
Builder barrelFileBuilder(BuilderOptions options, [FileSystem? fileSystem]) =>
    BarrelFileBuilder(options, fileSystem);
