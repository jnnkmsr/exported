import 'package:meta/meta.dart';

abstract class StringParser extends InputParser<String> {
  const StringParser(super.inputName);

  @override
  String? typeCheckMessage(dynamic input) => 'Expected a string';
}

abstract class StringSetParser extends InputParser<Set<String>> {
  const StringSetParser(super.inputName);

  @override
  Set<String> fromJson(dynamic json) => (json as List?)?.cast<String>().toSet() ?? {};

  @override
  String? typeCheckMessage(dynamic input) => 'Expected a list of strings';
}

abstract class SetParser<ElementType> extends IterableParser<ElementType, Set<ElementType>> {
  const SetParser(super.inputName);

  @override
  Set<ElementType> iterableFrom(Iterable<ElementType>? elements) => elements?.toSet() ?? {};
}

abstract class ListParser<ElementType> extends IterableParser<ElementType, List<ElementType>> {
  const ListParser(super.inputName);

  @override
  List<ElementType> iterableFrom(Iterable<ElementType>? elements) => elements?.toList() ?? [];
}

abstract class IterableParser<ElementType, IterableType extends Iterable<ElementType>>
    extends InputParser<IterableType> {
  const IterableParser(super.inputName);

  @override
  @nonVirtual
  IterableType fromJson(dynamic json) => iterableFrom((json as List?)?.map(elementFromJson));

  @visibleForOverriding
  ElementType elementFromJson(dynamic json) => json as ElementType;

  @visibleForOverriding
  IterableType iterableFrom(Iterable<ElementType>? elements);

  @override
  @nonVirtual
  String? typeCheckMessage(dynamic input) => 'Expected a list of $ElementType';
}

/// Base class for sanitizers providing a common [parse] interface and a
/// method to throw an [ArgumentError] with a message that includes the input
/// name and value.
abstract class InputParser<InputType> {
  /// Creates a new [InputParser] for the given [inputName].
  const InputParser(this.inputName);

  /// The name of the input that is sanitized. Used in error messages.
  final String inputName;

  /// Sanitizes the given [input] and returns the sanitized value.
  InputType parse([InputType? input]);

  /// Converts the JSON input to [InputType] and [parse]s the result.
  @nonVirtual
  InputType parseJson(dynamic json) {
    try {
      return parse(fromJson(json));
    } on TypeError catch (_) {
      throwArgumentError(json, typeCheckMessage(json));
    }
  }

  /// Converts the JSON input to the [InputType].
  ///
  /// Defaults to a simple cast. Override to provide custom conversion.
  @visibleForOverriding
  InputType? fromJson(dynamic json) => json as InputType?;

  /// Helper method to throw an [ArgumentError] with a message that includes the
  /// input name and value
  @mustCallSuper
  Never throwArgumentError(dynamic input, [String? message]) =>
      throw ArgumentError.value(input, inputName, message);

  @visibleForOverriding
  String? typeCheckMessage(dynamic input) => null;
}
