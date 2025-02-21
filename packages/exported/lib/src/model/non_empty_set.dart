import 'package:fast_immutable_collections/fast_immutable_collections.dart';
import 'package:meta/meta.dart';

/// An immutable set that is guaranteed to have at least one element.
extension type const NonEmptySet<E>.unsafe(ISet<E> _value) implements ISet<E> {
  /// Parses a [NonEmptySet] from either [Iterable] or single-value [input],
  /// calling [elementFromInput] to restore each element.
  ///
  /// Elements where [elementFromInput] returns `null` are ignored.
  ///
  /// Returns `null` if the [input] is `null` or the parsed set would be empty.
  static NonEmptySet<E>? fromInput<E extends Object>(
    dynamic input,
    E? Function(dynamic) elementFromInput,
  ) =>
      switch (input) {
        null => null,
        Iterable _ => input.map(elementFromInput).nonNulls.nonEmptySet,
        _ => fromInput({input}, elementFromInput),
      };

  /// Restores a [NonEmptySet] from an internal [json] representation, calling
  /// [elementFromJson] to restore each element.
  ///
  /// Returns `null` if [json] is `null` or an empty list.
  static NonEmptySet<E>? fromJson<E extends Object>(
    dynamic json,
    E Function(dynamic) elementFromJson,
  ) =>
      (json as Iterable?)?.map(elementFromJson).nonEmptySet;

  @redeclare
  bool get isEmpty => false;

  @redeclare
  NonEmptySet<E> union(Iterable<E> other) => NonEmptySet.unsafe(_value.union(other));

  @redeclare
  NonEmptySet<E>? intersection(Iterable<E> other) {
    final intersection = _value.intersection(other);
    return intersection.isEmpty ? null : NonEmptySet.unsafe(intersection);
  }

  @redeclare
  NonEmptySet<E>? difference(Iterable<E> other) {
    final difference = _value.difference(other);
    return difference.isEmpty ? null : NonEmptySet.unsafe(difference);
  }
}

extension NonEmptySetExtension<E> on Iterable<E> {
  /// Converts this [Iterable] into a [NonEmptySet] or `null` if the resultant
  /// set would be empty.
  NonEmptySet<E>? get nonEmptySet {
    final value = toISet();
    return value.isEmpty ? null : NonEmptySet.unsafe(value);
  }
}
