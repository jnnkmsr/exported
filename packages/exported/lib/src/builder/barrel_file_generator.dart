import 'package:collection/collection.dart';
import 'package:exported/src/model/barrel_file.dart';
import 'package:exported/src/model/export.dart';
import 'package:exported/src/options/exported_options.dart';
import 'package:exported/src/util/dart_writer.dart';
import 'package:meta/meta.dart';
import 'package:pub_semver/pub_semver.dart';

/// Generates the contents of a [BarrelFile].
class BarrelFileGenerator {
  /// Creates a [BarrelFileGenerator] for the given [file], optionally adding
  /// [initialExports] by calling [addExports].
  @visibleForTesting
  BarrelFileGenerator({
    required this.file,
    Iterable<Export> initialExports = const {},
  }) {
    addExports(initialExports);
  }

  /// Initializes a set of [BarrelFileGenerator]s from the given [options].
  ///
  /// Converts each [BarrelFile] to a [BarrelFileGenerator] and adds a
  /// [Export] for each [Export] to all files that match the
  /// export's tags.
  static Set<BarrelFileGenerator> fromOptions(ExportedOptions options) {
    return {
      for (final option in options.files)
        BarrelFileGenerator(
          file: option,
          initialExports: options.exports,
        ),
    };
  }

  /// The [BarrelFile] to generate.
  final BarrelFile file;

  /// Returns the exports in this file.
  List<Export> get exports => _exportsByUri.values.sorted();
  late final Map<String, Export> _exportsByUri = {};

  /// Adds all [exports] with matching tags to this file.
  /// - [exports] without tags are always be added.
  /// - [exports] with tags are added if they have at least one matching tag.
  ///
  /// If an export with the same URI already exists, it is merged with the new
  /// export by combining the `show` and `hide` filters.
  void addExports(Iterable<Export> exports) {
    for (final export in exports) {
      if (!file.shouldInclude(export)) continue;
      _exportsByUri.update(
        export.uri,
        (existing) => existing.merge(export),
        ifAbsent: () => export,
      );
    }
  }

  String generate(Version? dartVersion) {
    final writer = DartWriter(languageVersion: dartVersion);
    for (final export in exports) {
      writer.addLine(export.toDart());
    }
    return writer.write();
  }
}
