import 'package:exported/src/util/pubspec_reader.dart';
import 'package:mocktail/mocktail.dart';

class FakePubspecReader with Fake implements PubspecReader {
  FakePubspecReader({
    String? name,
  }) {
    if (name != null) this.name = name;
  }

  @override
  late final String name;
}
