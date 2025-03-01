import 'package:collection/collection.dart';
import 'package:exported/src/model/exported_option_keys.dart' as keys;
import 'package:exported/src/model/option_collections.dart';
import 'package:meta/meta.dart';

// TODO[ExportFilter]: split fromInput into show-/hide- and map-input methods
// TODO[ExportFilter]: unit test toDart()

/// Represents a `show`/`hide` filter in an `export` directive.
@immutable
sealed class ExportFilter {
  const ExportFilter._();

  /// Creates a `show` filter with a single combinator matching the given
  /// [elementName], without any input validation.
  factory ExportFilter.showSingle(String elementName) = _Show.element;

  /// Creates an [ExportFilter] from [show]/[hide] input or builder [options],
  /// validating and sanitizing input.
  ///
  /// Returns `none` if neither `show`/`hide` are provided or map keys are
  /// present, or the sanitized set combinators is empty.
  ///
  /// Throws an [ArgumentError] if non-null input is provided for both `show`
  /// and `hide`, or both map keys are present.
  ///
  /// **Input validation/sanitization:**
  ///
  /// - Input can either be a single combinator or an [Iterable] of combinator
  ///   strings.
  /// - Combinators are trimmed of whitespace.
  /// - Empty/blank strings and duplicates are removed.
  /// - Throws an [ArgumentError] if any combinator is not a valid public Dart
  ///   identifier (only letter/numbers/underscores, starting with a letter).
  factory ExportFilter.fromInput({dynamic show, dynamic hide, Map? options}) {
    if (options != null) {
      return fromInputMapOrString(
        options,
        fromMap: (_) => ExportFilter.fromInput(
          show: options[keys.show],
          hide: options[keys.hide],
        ),
      );
    }
    return switch ((show, hide)) {
      (null, null) => ExportFilter.none,
      (final _?, null) => _Show.fromInput(show) ?? ExportFilter.none,
      (null, final _?) => _Hide.fromInput(hide) ?? ExportFilter.none,
      (_?, _?) => throw ArgumentError.value(
          keys.hide,
          keys.exports,
          'Cannot provide both show and hide filters',
        ),
    };
  }

  /// Restores an [ExportFilter] from an internal [json] representation without
  /// any input validation.
  factory ExportFilter.fromJson(Map json) =>
      _Show.fromJson(json) ?? _Hide.fromJson(json) ?? ExportFilter.none;

  /// An empty filter comprising all non-private symbols of a library.
  static const ExportFilter none = _None();

  /// Converts this [ExportFilter] to JSON stored in the build cache.
  @nonVirtual
  Map toJson() => switch (this) {
        final _Show show => {keys.show: show.combinators},
        final _Hide hide => {keys.hide: hide.combinators},
        _None _ => const {},
      };

  /// Merges this [ExportFilter] with [other].
  ///
  /// - If either is [ExportFilter.none], the result will be `none` as well.
  /// - If both are `show` filters, the result will be a `show` filter combining
  ///   their combinators.
  /// - If both are `hide` filters, the result will be a `hide` filter with only
  ///   the combinators that are common to both, or `none` if there are none.
  /// - If one is a `show` and the other is a `hide` filter, the result will be
  ///   a `hide` filter without the combinators that are in the `show` filter,
  ///   or `none` if there are none left.
  ExportFilter merge(ExportFilter other);

  /// Converts this [ExportFilter] to a Dart string for use in an export
  /// directive.
  @nonVirtual
  String toDart() => switch (this) {
        final _Show show => ' show ${show.combinators.sorted().join(', ')}',
        final _Hide hide => ' hide ${hide.combinators.sorted().join(', ')}',
        _None _ => '',
      };

  @nonVirtual
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      switch (this) {
        final _Show show => other is _Show && other._combinators == show._combinators,
        final _Hide hide => other is _Hide && other._combinators == hide._combinators,
        _ => false,
      };

  @nonVirtual
  @override
  int get hashCode => Object.hash(
        runtimeType,
        switch (this) {
          final _Show show => show._combinators,
          final _Hide hide => hide._combinators,
          _None _ => 0,
        },
      );

  @nonVirtual
  @override
  String toString() => switch (this) {
        final _Show show => '$ExportFilter.show{${show._combinators}}',
        final _Hide hide => '$ExportFilter.hide{${hide._combinators}}',
        _None _ => '$ExportFilter.none',
      };
}

/// A `show` filter in an `export` directive.
final class _Show extends ExportFilter {
  const _Show._(this._combinators) : super._();

  factory _Show.element(String elementName) => _Show._({_Combinator(elementName)}.stringOptionSet!);

  static _Show? fromInput(dynamic input) {
    final combinators =
        StringOptionSet.fromInput(input, (e) => _Combinator.fromInput(e, keys.show));
    return combinators != null ? _Show._(combinators) : null;
  }

  static _Show? fromJson(Map json) {
    final combinators = StringOptionSet.fromJson(json[keys.show], _Combinator.fromJson);
    return combinators != null ? _Show._(combinators) : null;
  }

  List<String> get combinators => _combinators.toList();
  final StringOptionSet<_Combinator> _combinators;

  @override
  ExportFilter merge(ExportFilter other) => switch (other) {
        _Show _ => _Show._(_combinators.union(other._combinators)),
        _ => other.merge(this),
      };
}

/// A `hide` filter in an export directive.
final class _Hide extends ExportFilter {
  const _Hide._(this._combinators) : super._();

  static _Hide? fromInput(dynamic input) {
    final combinators =
        StringOptionSet.fromInput(input, (e) => _Combinator.fromInput(e, keys.hide));
    return combinators != null ? _Hide._(combinators) : null;
  }

  static _Hide? fromJson(Map json) {
    final combinators = StringOptionSet.fromJson(json[keys.hide], _Combinator.fromJson);
    return combinators != null ? _Hide._(combinators) : null;
  }

  List<String> get combinators => _combinators.toList();
  final StringOptionSet<_Combinator> _combinators;

  @override
  ExportFilter merge(ExportFilter other) {
    final combinators = switch (other) {
      _Show _ => _combinators.difference(other._combinators),
      _Hide _ => _combinators.intersection(other._combinators),
      _ => null,
    };
    return combinators != null ? _Hide._(combinators) : ExportFilter.none;
  }
}

/// An empty filter comprising all non-private symbols of a library.
final class _None extends ExportFilter {
  const _None() : super._();

  @override
  ExportFilter merge(ExportFilter other) => ExportFilter.none;
}

/// A combinator in an `export` directive's `show`/`hide` list.
extension type const _Combinator(String _) implements String {
  /// Restores a [_Combinator] from an internal [json] representation without
  /// any input validation.
  factory _Combinator.fromJson(dynamic json) => _Combinator(json as String);

  /// Creates a [_Combinator], validating and sanitizing the [input].
  ///
  /// - Returns `null` if the input is `null` or an empty/blank string.
  /// - Trims leading/trailing whitespace.
  /// - Throws an [ArgumentError] if the input is not a valid combinator string
  ///   (only letter/numbers/underscores, starting with a letter).
  static _Combinator? fromInput(dynamic input, String argName) {
    if (input == null) return null;
    if (input is! String) throw ArgumentError.value(input, argName, 'Must be a String');

    final value = input.trim();
    if (value.isEmpty) return null;
    if (!_validPattern.hasMatch(value)) {
      throw ArgumentError.value(value, argName, 'Must be a valid public Dart identifier');
    }
    return _Combinator(value);
  }

  static final _validPattern = RegExp(r'^[A-Za-z\$][A-Za-z0-9\$_]*$');
}

extension ExportFilterIterableExtension on Iterable<String> {
  @visibleForTesting
  ExportFilter get asShow => _Show._(map(_Combinator.new).stringOptionSet!);

  @visibleForTesting
  ExportFilter get asHide => _Hide._(map(_Combinator.new).stringOptionSet!);
}
