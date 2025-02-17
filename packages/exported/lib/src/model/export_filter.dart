import 'package:source_gen/source_gen.dart';

typedef ExportFilterFromJson = ExportFilter Function(dynamic input);

sealed class ExportFilter {
  factory ExportFilter.fromCache(dynamic json) {
    throw UnimplementedError();
  }

  factory ExportFilter.fromAnnotatedElement(AnnotatedElement element) {
    throw UnimplementedError();
  }

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

  static const ExportFilter none = _None();

  // [x]               |               ->
  // [x]               | show foo, baz ->
  // [x]               | hide foo, baz ->
  //
  // [x] show foo, bar | show foo, baz -> show foo, bar, baz
  // [ ] show foo, bar | hide foo, baz -> hide baz
  //
  // [ ] hide foo, bar | hide foo, baz -> hide foo
  ExportFilter merge(ExportFilter other);

  Map<String, dynamic> toCache();
}

final class _None implements ExportFilter {
  const _None();

  @override
  ExportFilter merge(ExportFilter other) => this;

  @override
  Map<String, dynamic> toCache() => const {};
}

final class _Show implements ExportFilter {
  // factory _Show(Set<String> elements) {
  //   throw UnimplementedError();
  //   // assert(elements.isNotEmpty, 'Show must have at least one element');
  //   // return _Show._(elements.map(_DartIdentifier.new).toSet());
  // }
  const _Show._(this._elements);

  static _Show? parse(dynamic elements) {
    final symbols = _Symbols.parse(elements);
    if (symbols == null) return null;
    return _Show._(symbols);
  }

  final _Symbols _elements;

  @override
  ExportFilter merge(ExportFilter other) =>
      other is _Show ? _Show._(_elements.union(other._elements) as _Symbols) : other.merge(this);

  @override
  Map<String, dynamic> toCache() {
    // TODO: implement toJson
    throw UnimplementedError();
  }
}

final class _Hide implements ExportFilter {
  const _Hide._(this._elements);

  static _Hide? parse(dynamic elements) {
    final symbols = _Symbols.parse(elements);
    if (symbols == null) return null;
    return _Hide._(symbols);
  }

  final _Symbols _elements;

  @override
  ExportFilter merge(ExportFilter other) => switch (other) {
        _Hide _ => _Hide._(_elements.intersection(other._elements) as _Symbols),
        _Show _ => _Hide._(_elements.difference(other._elements) as _Symbols),
        _None _ => other.merge(this),
      };

  @override
  Map<String, dynamic> toCache() {
    // TODO: implement toJson
    throw UnimplementedError();
  }
}

extension type const _Symbols._(Set<_Symbol> _) implements Set<_Symbol> {
  static _Symbols? parse(dynamic input) {
    if (input == null) return null;
    final symbols = switch (input) {
      Iterable _ => _Symbols._(input.map(_Symbol.parse).nonNulls.toSet()),
      _ => _Symbols.parse([input])!,
    };
    return symbols.isEmpty ? null : symbols;
  }
}

extension type const _Symbol._(String _) implements Object {
  static _Symbol? parse(dynamic input) => _Symbol._(input as String);
}
