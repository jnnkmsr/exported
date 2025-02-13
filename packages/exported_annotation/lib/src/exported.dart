import 'package:meta/meta_meta.dart';

/// Annotates a top-level dart element as an export that will be included in
/// all generated barrel files.
const exported = Exported();

/// Annotates a top-level dart element as an export that will be included in
/// one or more generated barrel files.
// TODO: Add library support.
//       Requires manual checking that the element is not an `import`/`export`
//       or `part` directive.
@Target({
  TargetKind.extension,
  TargetKind.extensionType,
  TargetKind.function,
  TargetKind.getter, // TODO: Handle checking for top-level getter.
  TargetKind.setter, // TODO: Handle checking for top-level setter.
  TargetKind.topLevelVariable,
  TargetKind.type,
})
class Exported {
  /// Creates a new [Exported] annotation with an optional set of [tags] for
  /// selectively including the export in one or multiple barrel files.
  const Exported({
    this.tags,
  });

  /// The set of tags for selectively including the annotated element only in
  /// barrel files with matching tags.
  final Set<String>? tags;
}
