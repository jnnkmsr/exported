/// Helper function to parse [input] that is either [String] or [Iterable],
/// or a [Map] entry with the given [key].
///
/// If the resultant set is empty, [emptyBuilder] is called to create an
/// empty set. This can be used to ensure the same instance is returned for
/// empty sets.
///
/// See [ShowHide] and [Tags] for examples of usage.
SetT parseSet<SetT extends Object, ElementT extends Object>(
  dynamic input,
  String key,
  SetT Function(Set<ElementT>) setBuilder,
  ElementT? Function(dynamic input) elementBuilder,
  SetT Function() emptyBuilder,
) {
  SetT parseIterable(
    Iterable input,
    SetT Function(Set<ElementT>) builder,
    SetT Function() emptyBuilder,
  ) {
    final values = input.map(elementBuilder).nonNulls.toSet();
    if (values.isEmpty) return emptyBuilder();
    return builder(values);
  }

  try {
    return switch (input) {
      null => emptyBuilder(),
      Map _ => parseSet(input[key], key, setBuilder, elementBuilder, emptyBuilder),
      Iterable _ => parseIterable(input, setBuilder, emptyBuilder),
      _ => parseSet([input], key, setBuilder, elementBuilder, emptyBuilder),
    };
  } on ArgumentError catch (e) {
    throw ArgumentError.value(input, key, e.message);
  }
}
