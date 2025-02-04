import 'dart:async';

import 'package:build/build.dart';

class BarreledExportsBuilder extends Builder {
  @override
  // TODO: implement buildExtensions
  Map<String, List<String>> get buildExtensions => {
        '.dart': ['.barreled.json'],
      };

  @override
  FutureOr<void> build(BuildStep buildStep) {
    // TODO: implement build
  }
}
