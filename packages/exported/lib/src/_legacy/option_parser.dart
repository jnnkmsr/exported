import 'package:meta/meta.dart';

/// Base [OptionParser] for string [String] inputs.
abstract class StringOptionParser extends OptionParser<String> {
  const StringOptionParser(super.inputName);

  @override
  String? typeCheckMessage(dynamic input) => 'Expected a string';
}

/// Base [OptionParser] for string [Set] inputs.
abstract class StringSetOptionParser extends OptionParser<Set<String>> {
  const StringSetOptionParser(super.inputName);

  @override
  Set<String> fromJson(dynamic json) => (json as List?)?.cast<String>().toSet() ?? {};

  @override
  String? typeCheckMessage(dynamic input) => 'Expected a list of strings';
}

/// Base [OptionParser] for [Set] input types.
abstract class SetOptionParser<ElementType>
    extends IterableOptionParser<ElementType, Set<ElementType>> {
  const SetOptionParser(super.inputName);

  @override
  Set<ElementType> iterableFrom(Iterable<ElementType>? elements) => elements?.toSet() ?? {};
}

/// Base [OptionParser] for [List] input types.
abstract class ListOptionParser<ElementType>
    extends IterableOptionParser<ElementType, List<ElementType>> {
  const ListOptionParser(super.inputName);

  @override
  List<ElementType> iterableFrom(Iterable<ElementType>? elements) => elements?.toList() ?? [];
}

/// Base [OptionParser] for [Iterable] input types.
abstract class IterableOptionParser<ElementType, IterableType extends Iterable<ElementType>>
    extends OptionParser<IterableType> {
  const IterableOptionParser(super.inputName);

  @override
  @nonVirtual
  IterableType fromJson(dynamic json) => iterableFrom((json as List?)?.map(elementFromJson));

  /// Called by [fromJson] to convert the [Iterable] of converted JSON elements
  /// to the desired [IterableType].
  @visibleForOverriding
  IterableType iterableFrom(Iterable<ElementType>? elements);

  /// Called by [fromJson] to converts [Iterable] elements to [ElementType].
  ///
  /// Defaults to a simple cast. Override to provide custom conversion.
  @visibleForOverriding
  ElementType elementFromJson(dynamic json) => json as ElementType;

  @override
  @nonVirtual
  String? typeCheckMessage(dynamic input) => 'Expected a list of $ElementType';
}

/// Base class for all option parsers providing a common [parse] interface and
/// a method to throw an [ArgumentError] with a message that includes the input
/// name and value.
abstract class OptionParser<InputType> {
  const OptionParser(this.inputName);

  /// The name of the input that is sanitized. Used in error messages.
  final String inputName;

  /// Validates the [input] and returns the sanitized value.
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

  /// Converts JSON input to [InputType].
  ///
  /// Defaults to a simple cast. Override to provide custom conversion.
  @visibleForOverriding
  InputType? fromJson(dynamic json) => json as InputType?;

  /// Throws an [ArgumentError] that surrounds the [message] with the
  /// [inputName] and [value].
  /// ```plaintext
  /// Invalid argument ($inputName): [$message:] $value
  /// ```
  @mustCallSuper
  Never throwArgumentError(dynamic value, [String? message]) =>
      throw ArgumentError.value(value, inputName, message);

  /// Error message for when JSON type conversion fails.
  @visibleForOverriding
  String? typeCheckMessage(dynamic input) => null;
}
