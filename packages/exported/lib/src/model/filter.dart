import 'package:exported/src/builder/exported_option_keys.dart' as keys;

sealed class Filter {
  factory Filter.fromJson(Map json) => _Show.fromJson(json) ?? _Hide.fromJson(json) ?? none;

  factory Filter.show(String symbol) = _Show.single;

  static const Filter none = _None();

  Filter merge(Filter other);

  Map toJson();
}

final class _Show implements Filter {
  const _Show._(this._symbols);

  _Show.single(String symbol) : _symbols = {_Symbol(symbol)};

  static _Show? fromJson(Map json) {
    final symbols = _Symbol.fromJson(json[keys.show]);
    return symbols == null ? null : _Show._(symbols);
  }

  // static _Show? fromOptions(dynamic elements) {
  //   final symbols = _Symbols.fromOptions(elements);
  //   if (symbols == null) return null;
  //   return _Show._(symbols);
  // }

  final Set<_Symbol> _symbols;

  @override
  Filter merge(Filter other) =>
      other is _Show ? _Show._(_symbols.union(other._symbols)) : other.merge(this);

  @override
  Map toJson() => {keys.hide: _symbols.toList()};
}

final class _Hide implements Filter {
  const _Hide._(this._elements);

  static _Hide? fromJson(Map json) {
    final symbols = _Symbol.fromJson(json[keys.show]);
    return symbols == null ? null : _Hide._(symbols);
  }

  // static _Hide? fromOptions(dynamic elements) {
  //   final symbols = _Symbols.fromOptions(elements);
  //   if (symbols == null) return null;
  //   return _Hide._(symbols);
  // }

  final Set<_Symbol> _elements;

  @override
  Filter merge(Filter other) => switch (other) {
        _Hide _ => _Hide._(_elements.intersection(other._elements)),
        _Show _ => _Hide._(_elements.difference(other._symbols)),
        _None _ => other.merge(this),
      };

  @override
  Map toJson() => {keys.hide: _elements.toList()};
}

final class _None implements Filter {
  const _None();

  @override
  Filter merge(Filter other) => this;

  @override
  Map<String, dynamic> toJson() => const {};
}

extension type const _Symbol(String _) implements String {
  static Set<_Symbol>? fromJson(dynamic json) {
    final value = (json as List?)?.cast<String>().map(_Symbol.new).toSet();
    return value == null || value.isEmpty ? null : value;
  }

  // TODO[_Symbol]: Input validation
  // static _Symbol? fromOptions(dynamic input) => _Symbol(input as String);


// static _Symbols? fromOptions(dynamic input) => switch (input) {
//       null => null,
//       Iterable _ => _Symbols._fromIterable(input.map(_Symbol.parse).nonNulls),
//       _ => _Symbols.fromOptions([input])!,
//     };
//
// static _Symbols? _fromIterable(Iterable<_Symbol> input) {
//   final value = input.toSet();
//   return value.isEmpty ? null : _Symbols(value.toSet());
// }
}

// [x]               |               ->
// [x]               | show foo, baz ->
// [x]               | hide foo, baz ->
//
// [x] show foo, bar | show foo, baz -> show foo, bar, baz
// [ ] show foo, bar | hide foo, baz -> hide baz
//
// [ ] hide foo, bar | hide foo, baz -> hide foo

// factory ExportFilter({
//   Set<String> show = const {},
//   Set<String> hide = const {},
// }) {
//   if (show.isEmpty && hide.isEmpty) return const _None();
//   if (hide.isNotEmpty) {
//     final symbols = _Symbols.parse(hide);
//     if (symbols != null) return _Hide._(symbols);
//   }
//   if (show.isNotEmpty) {
//     final symbols = _Symbols.parse(show);
//     if (symbols != null) return _Show._(symbols);
//   }
//   return const _None();
// }
// factory ExportFilter.showSingle(String element) => _Show._(_Symbols._({_Symbol._(element)}));
