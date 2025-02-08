import 'package:barreled/src/model/barrel_export.dart';
import 'package:barreled/src/options/barrel_file_option.dart';
import 'package:barreled/src/options/barreled_options.dart';
import 'package:barreled/src/options/export_option.dart';
import 'package:collection/collection.dart';
import 'package:path/path.dart' as p;

// TODO: Unit test sorting of `exports`.
// TODO: Unit test extension methods.

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
  /// [BarrelExport] for each [ExportOption] to all files that match the
  /// export's tags.
  static Set<BarrelFile> fromOptions(
    BarreledOptions options, {
    required String Function() defaultName,
  }) {
    final packageExports = options.exports.map(BarrelExport.fromPackageExportOption);
    return {
      for (final option in options.files)
        BarrelFile(
          name: option.file ?? defaultName(),
          dir: option.dir,
          tags: option.tags,
        )..addExports(packageExports),
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
  List<BarrelExport> get exports => _exports.sorted();
  late final Set<BarrelExport> _exports = {};
  late final Map<String, BarrelExport> _exportsByLibrary = {};

  /// Adds an [export] to this file if it matches the file's [tags].
  ///
  /// The export will be added if this file has no [tags] or if the export has
  /// at least on tag in common with this file's [tags].
  ///
  /// If an export with the same URI already exists, it is merged with the new
  /// new [export] by combining the `show` and `hide` filters.
  void addExport(BarrelExport export) {
    if (!_shouldAddExport(export)) return;
    _exportsByLibrary.update(
      export.uri,
      (existing) => existing.merge(export),
      ifAbsent: () {
        _exports.add(export);
        return export;
      },
    );
  }

  /// Adds all [exports] with matching tags to this file.
  /// - [exports] without tags are always be added.
  /// - [exports] with tags are added if they have at least one matching tag.
  ///
  /// If an export with the same URI already exists, it is merged with the new
  /// export by combining the `show` and `hide` filters.
  void addExports(Iterable<BarrelExport> exports) {
    for (final export in exports) {
      addExport(export);
    }
  }

  /// Whether this file should include the given [export] based on its tags.
  ///
  /// Returns `true` if this file has no [tags] or if the export has at least
  /// one tag in common with this file's [tags].
  bool _shouldAddExport(BarrelExport export) {
    return tags == null ||
        tags!.isEmpty ||
        export.tags.isEmpty ||
        tags!.intersection(export.tags).isNotEmpty;
  }
}

extension BarrelFileIterableExtension on Iterable<BarrelFile> {
  /// Adds the [exports] to all files with matching tags.
  /// - [exports] without tags will be added to all files.
  /// - [exports] with tags will be added to all files with at least one
  ///   matching tag and to all files without tags.
  void addExports(Iterable<BarrelExport> exports) {
    for (final file in this) {
      file.addExports(exports);
    }
  }

  /// Returns the list of all [BarrelFile.name]s.
  List<String> get names => [for (final file in this) file.name];
}
