import 'package:collection/collection.dart';
import 'package:exported/src/model/exported_option_keys.dart' as keys;
import 'package:exported/src/model/parser_helpers.dart';
import 'package:meta/meta.dart';

extension type const Show._(Set<ExportFilterName> _) implements ExportFilter {
  @visibleForTesting
  factory Show(Set<String> names) => Show._(names.map(ExportFilterName._).toSet());

  factory Show.parse(dynamic input) =>
      ExportFilter.parse(input, keys.show, Show._, () => Show.empty);

  static const Show empty = Show._({});

  @redeclare
  Show union(Show other) => Show._(value.union(other.value));

  Show merge(Show otherShow, Hide otherHide) =>
      isEmpty || otherShow.isEmpty ? Show.empty : Show._(value.union(otherShow.value));
}

extension type const Hide._(Set<ExportFilterName> _) implements ExportFilter {
  @visibleForTesting
  factory Hide(Set<String> names) => Hide._(names.map(ExportFilterName._).toSet());

  factory Hide.parse(dynamic input) =>
      ExportFilter.parse(input, keys.hide, Hide._, () => Hide.empty);

  static const Hide empty = Hide._({});

  Hide merge(Show otherShow, Hide otherHide) => otherShow.isEmpty
      ? Hide._(value.intersection(otherHide.value))
      : Hide._(value.difference(otherShow.value));
}

extension type const ExportFilter._(
    @protected Set<ExportFilterName> value) implements Set<ExportFilterName> {
  /// Parses the [input] into a non-empty set of element names of type [T], or
  /// `null` if the parsed result is empty.
  static T parse<T extends ExportFilter>(
    dynamic input,
    String key,
    T Function(Set<ExportFilterName>) builder,
    T Function() emptyBuilder,
  ) {
    return parseSet(input, key, builder, ExportFilterName.parse, emptyBuilder);
  }

  List<String> get names => value.map((name) => name as String).sorted();
}

@protected
extension type const ExportFilterName._(String _) implements Object {
  static ExportFilterName? parse(dynamic input) {
    if (input == null) return null;
    if (input is! String) {
      throw ArgumentError('Must be strings');
    }
    final value = input.trim();
    if (value.isEmpty) return null;

    if (!_validPattern.hasMatch(value)) {
      throw ArgumentError('"$value" is not a valid name of a public Dart');
    }
    return ExportFilterName._(value);
  }

  static final _validPattern = RegExp(r'^[a-zA-Z][a-zA-Z0-9_]*$');
}
