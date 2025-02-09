import 'package:barreled/src/model/barrel_export.dart';
import 'package:barreled/src/options/barrel_file_option.dart';
import 'package:barreled/src/options/barreled_options.dart';
import 'package:barreled/src/options/export_option.dart';
import 'package:collection/collection.dart';
import 'package:path/path.dart' as p;

/// Represents a barrel file with an editable list of exports.
class BarrelFile {
  /// Creates a [BarrelFile] with the given [name], [dir] abd [tags].
  BarrelFile({
    required this.name,
    required this.dir,
    Set<String>? tags,
  }) : tags = tags ?? const {};

  /// Initializes a set of [BarrelFile]s from the given [options].
  ///
  /// Converts each [BarrelFileOption] to a [BarrelFile] and adds a
  /// [BarrelExport] for each [ExportOption] to all files that match the
  /// export's tags.
  static Set<BarrelFile> fromOptions(BarreledOptions options) {
    final packageExports = options.exports.map(BarrelExport.fromPackageExportOption);
    return {
      for (final option in options.files)
        BarrelFile(
          name: option.file,
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
  /// If empty, all exports are included.
  final Set<String> tags;

  /// The full relative path to this barrel file.
  String get path => p.join(dir, name);

  /// Returns the exports in this file.
  List<BarrelExport> get exports => _exports.sorted();
  late final Set<BarrelExport> _exports = {};
  late final Map<String, BarrelExport> _exportsByLibrary = {};

  /// Adds all [exports] with matching tags to this file.
  /// - [exports] without tags are always be added.
  /// - [exports] with tags are added if they have at least one matching tag.
  ///
  /// If an export with the same URI already exists, it is merged with the new
  /// export by combining the `show` and `hide` filters.
  void addExports(Iterable<BarrelExport> exports) {
    for (final export in exports) {
      if (!_shouldAddExport(export)) continue;
      final updated =_exportsByLibrary.update(
        export.uri,
        (existing) {
          _exports.remove(existing);
          return existing.merge(export);
        },
        ifAbsent: () => export,
      );
      _exports.add(updated);
    }
  }

  /// Whether this file should include the given [export] based on its tags.
  ///
  /// Returns `true` if this file has no [tags] or if the export has at least
  /// one tag in common with this file's [tags].
  bool _shouldAddExport(BarrelExport export) =>
      tags.isEmpty || export.tags.isEmpty || tags.intersection(export.tags).isNotEmpty;
}
