import 'package:analyzer/dart/element/element.dart';
import 'package:mocktail/mocktail.dart';

class FakeElement extends Fake implements Element {
  FakeElement({required this.name});

  @override
  final String? name;
}
