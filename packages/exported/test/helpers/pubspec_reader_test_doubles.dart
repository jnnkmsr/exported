import 'package:exported/src/util/pubspec_reader.dart';
import 'package:mocktail/mocktail.dart';
import 'package:pub_semver/pub_semver.dart';

class FakePubspecReader with Fake implements PubspecReader {
  FakePubspecReader({
    String? name,
    VersionConstraint? sdkVersion,
  }) {
    if (name != null) this.name = name;
    if (sdkVersion != null) this.sdkVersion = sdkVersion;
  }

  @override
  late final String name;

  @override
  late final VersionConstraint sdkVersion;
}
