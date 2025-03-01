import 'package:fast_immutable_collections/fast_immutable_collections.dart';
import 'package:meta/meta.dart';

/// Parses an map option [input] using the provided [parseMap] function.
///
/// An optional [parseString] function can be provided to parse single-string
/// input.
///
/// If [validKeys] is provided, the input map will be validated to contain only
/// keys from this set, throwing an [ArgumentError] if any key is invalid. The
/// [parentKey] is used for error-message context.
T parseInputMap<T>(
  dynamic input, {
  String? parentKey,
  Set<String>? validKeys,
  required T Function(Map) parseMap,
  T Function(String)? parseString,
}) =>
    switch (input) {
      String _ when parseString != null => parseString(input),
      Map _ => _parseInputMap(input, parentKey, validKeys, parseMap),
      _ => throw ArgumentError.value(input, parentKey, 'Invalid input type'),
    };

/// Helper function for [parseInputMap] for map [input].
T _parseInputMap<T>(Map input, String? parentKey, Set<String>? validKeys, T Function(Map) parse) {
  if (validKeys != null) {
    final invalidKeys = input.keys.toSet().difference(validKeys);
    if (invalidKeys.isNotEmpty) {
      throw ArgumentError.value(invalidKeys.first, parentKey, 'Invalid option');
    }
  }
  return parse(input);
}

/// An immutable list of options.
extension type const OptionList<E extends Object>._(IList<E> _) implements IList<E> {
  /// Creates an empty [OptionList].
  const OptionList.empty() : this._(const IListConst([]));

  /// Creates an [OptionList] from a single [element].
  OptionList.single(E element) : this._(IListConst([element]));

  /// Parses an [OptionList] from either [Iterable] or single-value [input],
  /// calling [elementFromInput] to restore each element.
  ///
  /// Duplicates and elements where [elementFromInput] returns `null` are
  /// removed.
  ///
  /// Returns an empty list if the [input] is `null`.
  factory OptionList.fromInput(
    dynamic input,
    E? Function(dynamic) elementFromInput,
  ) =>
      switch (input) {
        null => const OptionList.empty(),
        Iterable _ => input.map(elementFromInput).nonNulls.toSet().optionList,
        _ => OptionList.fromInput([input], elementFromInput),
      };
}

/// An immutable set of string options that is guaranteed to have at least one
/// element.
///
/// **Note:** Using the default constructor does not guarantee that the set is
/// non-empty.
extension type const StringOptionSet<E extends String>(ISet<E> _value) implements ISet<E> {
  /// Parses a [StringOptionSet] from either [Iterable] or single-value [input],
  /// calling [elementFromInput] to restore each element.
  ///
  /// Elements where [elementFromInput] returns `null` are removed.
  ///
  /// Returns `null` if the [input] is `null` or the parsed set would be empty.
  static StringOptionSet<E>? fromInput<E extends String>(
    dynamic input,
    E? Function(dynamic) elementFromInput,
  ) =>
      switch (input) {
        null => null,
        Iterable _ => input.map(elementFromInput).nonNulls.stringOptionSet,
        _ => fromInput({input}, elementFromInput),
      };

  /// Restores a [StringOptionSet] from an internal [json] representation, calling
  /// [elementFromJson] to restore each element.
  ///
  /// Returns `null` if [json] is `null` or an empty list.
  static StringOptionSet<E>? fromJson<E extends String>(
    dynamic json,
    E Function(dynamic) elementFromJson,
  ) =>
      (json as Iterable?)?.map(elementFromJson).stringOptionSet;

  @redeclare
  bool get isEmpty => false;

  @redeclare
  StringOptionSet<E> union(Iterable<E> other) => StringOptionSet(_value.union(other));

  @redeclare
  StringOptionSet<E>? intersection(Iterable<E> other) {
    final intersection = _value.intersection(other);
    return intersection.isEmpty ? null : StringOptionSet(intersection);
  }

  @redeclare
  StringOptionSet<E>? difference(Iterable<E> other) {
    final difference = _value.difference(other);
    return difference.isEmpty ? null : StringOptionSet(difference);
  }
}

extension OptionListIterableExtension<E extends Object> on Iterable<E> {
  /// Converts this [Iterable] into an [OptionList].
  OptionList<E> get optionList => OptionList._(toIList());
}

extension StringOptionSetIterableExtension<E extends String> on Iterable<E> {
  /// Converts this [Iterable] into a [StringOptionSet] or `null` if the resultant
  /// set would be empty.
  StringOptionSet<E>? get stringOptionSet {
    final value = toISet();
    return value.isEmpty ? null : StringOptionSet(value);
  }
}
