import 'package:meta/meta_meta.dart';

// TODO[Exported]: Add show/hide for library exports.

/// Annotates a top-level dart element as an export that will be included in
/// all generated barrel files.
const exported = Exported();

/// Annotates a top-level dart element as an export that will be included in
/// one or more generated barrel files.
@Target({
  TargetKind.extension,
  TargetKind.extensionType,
  TargetKind.function,
  TargetKind.getter,
  TargetKind.library,
  TargetKind.setter,
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
