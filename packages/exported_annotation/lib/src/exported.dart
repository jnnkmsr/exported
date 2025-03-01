import 'package:meta/meta_meta.dart';

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
  ///
  /// For libraries, the [show] and [hide] combinators can be specified to
  /// include or exclude specific elements from the export.
  const Exported({
    this.tags,
    this.show,
    this.hide,
  });

  /// The set of tags for selectively including the annotated element only in
  /// barrel files with matching tags.
  final Set<String>? tags;

  /// Optional set of `show` combinators. Has no effect if used on elements
  /// other than libraries.
  final Set<String>? show;

  /// Optional set of `hide` combinators. Has no effect if used on elements
  /// other than libraries.
  final Set<String>? hide;
}
