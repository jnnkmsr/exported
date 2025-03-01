import 'package:exported/src/util/pubspec_reader.dart';
import 'package:mocktail/mocktail.dart';

class FakePubspecReader with Fake implements PubspecReader {
  FakePubspecReader({this.name = ''});

  @override
  final String name;
}
