import 'package:collection/collection.dart';
import 'package:exported/src/model/barrel_file.dart';
import 'package:exported/src/model/export.dart';
import 'package:exported/src/util/dart_writer.dart';

/// Generates the contents of a [BarrelFile].
class BarrelFileGenerator {
  /// Creates a [BarrelFileGenerator] for the given [file] and [exports].
  ///
  /// Adds [exports] with matching tags to the file.
  /// - [exports] without tags are always be added.
  /// - [exports] with tags are added if they have at least one matching tag.
  ///
  /// If duplicate exports with the same URI are added, they are merged by
  /// combining `show` and `hide` filters.
  BarrelFileGenerator({
    required BarrelFile file,
    required Iterable<Export> exports,
  }) : _file = file {
    _exportsByUri = {};
    for (final export in exports) {
      if (!_file.shouldInclude(export)) continue;
      _exportsByUri.update(
        export.uri,
        (existing) => existing.merge(export),
        ifAbsent: () => export,
      );
    }
  }

  final BarrelFile _file;
  late final Map<String, Export> _exportsByUri;

  /// Generates the Dart contents of the [BarrelFile], containing sorted
  /// `export` directives for all added [Export]s.
  String generate() {
    final exports = _exportsByUri.values.sorted();
    final writer = DartWriter();
    for (final export in exports) {
      writer.addLine(export.toDart());
    }
    return writer.write();
  }
}
