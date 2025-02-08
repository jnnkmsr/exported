import 'package:barreled/src/model/barrel_export.dart';
import 'package:barreled/src/options/barrel_file_option.dart';
import 'package:barreled/src/options/barreled_builder_options.dart';
import 'package:path/path.dart' as p;

// TODO: Unit test `BarrelFile`.

/// Represents a barrel file with an editable list of exports.
class BarrelFile {
  /// Creates a [BarrelFile] with the given [name], [dir] abd [tags].
  BarrelFile({
    required this.name,
    required this.dir,
    this.tags,
  });

  /// Initializes a set of [BarrelFile]s from the given [options].
  ///
  /// Converts each [BarrelFileOption] to a [BarrelFile] and adds a
  /// [BarrelExport] for each [PackageExportOption] to all files that match the
  /// export's tags.
  static Set<BarrelFile> fromOptions(
    BarreledBuilderOptions options, {
    required String Function() defaultName,
  }) {
    return {
      for (final option in options.files)
        BarrelFile(
          name: option.name ?? defaultName(),
          dir: option.dir,
          tags: option.tags,
        ),
    };
  }

  /// The file name of this barrel file.
  final String name;

  /// The directory path of this barrel file.
  final String dir;

  /// The set of tags for selectively including exports in this barrel file.
  ///
  /// If `null` or empty, all exports are included.
  final Set<String>? tags;

  /// The full relative path to this barrel file.
  String get path => p.join(dir, name);

  /// Returns the exports in this file.
  Set<BarrelExport> get exports => _exportsByLibrary.values.toSet();
  late final Map<String, BarrelExport> _exportsByLibrary = {};

  /// Adds an [export] to this file if it matches the file's [tags].
  ///
  /// The export will be added if this file has no [tags] or if the export has
  /// at least on tag in common with this file's [tags].
  ///
  /// If an export with the same library already exists, it is merged with the
  /// new [export] by combining the `show` and `hide` filters.
  void addExport(BarrelExport export) {
    if (!_shouldAddExport(export)) return;
    _exportsByLibrary.update(
      export.library,
      (existing) => existing.merge(export),
      ifAbsent: () => export,
    );
  }

  /// Whether this file should include the given [export] based on its tags.
  ///
  /// Returns `true` if this file has no [tags] or if the export has at least
  /// one tag in common with this file's [tags].
  bool _shouldAddExport(BarrelExport export) {
    return tags == null || tags!.isEmpty || tags!.intersection(export.tags).isNotEmpty;
  }
}

extension BarrelFileIterableExtension on Iterable<BarrelFile> {
  /// Adds an [export] to all files that match the [export]'s tags.
  ///
  /// The export will be added to all file that have no `tags` or have at least
  /// one tag in common with the [export]'s `tags`.
  void addExport(BarrelExport export) {
    for (final file in this) {
      file.addExport(export);
    }
  }

  /// Returns the list of all [BarrelFile.name]s.
  List<String> get names => [for (final file in this) file.name];
}
