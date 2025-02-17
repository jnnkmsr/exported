import 'package:analyzer/dart/constant/value.dart';
import 'package:analyzer/dart/element/element.dart';
import 'package:exported/src/builder/exported_option_keys.dart' as keys;
import 'package:mocktail/mocktail.dart';
import 'package:source_gen/source_gen.dart';

class FakeAnnotatedElement extends Fake implements AnnotatedElement {
  FakeAnnotatedElement({
    required String? elementName,
    Set<String>? tags,
  })  : element = _FakeElement(name: elementName),
        annotation = _FakeExportedReader(tags: tags);

  @override
  final Element element;

  @override
  final ConstantReader annotation;
}

class _FakeElement extends Fake implements Element {
  _FakeElement({required this.name});

  @override
  final String? name;
}

class _FakeExportedReader extends Mock implements ConstantReader {
  _FakeExportedReader({required Set<String>? tags}) {
    when(() => read(keys.tags)).thenReturn(_FakeTagsReader(tags));
  }
}

class _FakeTagsReader extends Fake implements ConstantReader {
  _FakeTagsReader(this.tags);

  final Set<String>? tags;

  @override
  bool get isNull => tags == null;

  @override
  bool get isSet => tags != null;

  @override
  Set<DartObject> get setValue => {for (final tag in tags!) _FakeStringDartObject(tag)};
}

class _FakeStringDartObject extends Fake implements DartObject {
  _FakeStringDartObject(this.value);

  final String value;

  @override
  String toStringValue() => value;
}
