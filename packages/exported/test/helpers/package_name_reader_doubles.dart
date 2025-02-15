import 'package:exported/src/validation/package_name_reader.dart';
import 'package:mocktail/mocktail.dart';

class FakePackageNameReader with Fake implements PackageNameReader {
  FakePackageNameReader({String? name}) {
    if (name != null) this.name = name;
  }

  @override
  late final String name;
}
