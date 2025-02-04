import 'dart:async';

import 'package:build/build.dart';

class BarreledBuilder extends Builder {
  @override
  // TODO: implement buildExtensions
  Map<String, List<String>> get buildExtensions => {
    r'$lib$': ['stub.dart'],
  };

  @override
  FutureOr<void> build(BuildStep buildStep) {
    // TODO: implement build
  }
}
