import 'package:meta/meta_meta.dart';

/// Annotates a top-level dart element as a package export that will be included
/// in all generated barrel files.
const barreled = Barreled();

/// Annotates a top-level dart element as a package export that will be included
/// in one or more generated barrel files.
@Target({
  TargetKind.extension,
  TargetKind.function,
  TargetKind.topLevelVariable,
  TargetKind.type,
})
class Barreled {
  /// Creates a new [Barreled] annotation with an optional set of [tags] for
  /// selectively including exports in one or multiple barrel files.
  const Barreled({
    this.tags,
  });

  /// The set of tags for selectively exporting the annotated element from only
  /// the barrel files with matching tags.
  final Set<String>? tags;
}
