import 'package:pub_semver/pub_semver.dart';

// TODO: Unit test

extension VersionHelpers on VersionConstraint {
  Version? get target {
    return switch (this) {
      final Version version => version,
      final VersionRange range => range.min ?? range.max,
      _ => null,
    };
  }
}
