import 'package:collection/collection.dart';

/// Compares twp sets of strings for element-wise equality, ignoring order.
bool setEquals(Set<String> a, Set<String> b) => _setEquality.equals(a, b);

/// Returns a `hashCode` for the given [set] of strings that is consistent with
/// [setEquals].
int setHash(Set<String> set) => _setEquality.hash(set);

const _setEquality = SetEquality<String>();
