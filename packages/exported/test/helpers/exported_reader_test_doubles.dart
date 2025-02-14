import 'package:analyzer/dart/constant/value.dart';
import 'package:exported/src/model/exported_option_keys.dart' as keys;
import 'package:mocktail/mocktail.dart';
import 'package:source_gen/source_gen.dart';

class FakeExportedReader extends Mock implements ConstantReader {
  FakeExportedReader({required Set<String>? tags}) {
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
