import 'package:build_test/build_test.dart';
import 'package:exported/src/builder/exported_cache_builder.dart';
import 'package:meta/meta.dart';
import 'package:test/test.dart';

void main() {
  group('ExportedCacheBuilder', () {
    late ExportedCacheBuilder sut;

    setUp(() {
      sut = ExportedCacheBuilder();
    });

    @isTest
    void runTest(
      String message, {
      required Map<String, String> libraries,
      required Map<String, String>? outputs,
    }) {
      const packageName = 'foo';
      test(
        message,
        () async => testBuilder(
          sut,
          libraries.map((path, content) => MapEntry('$packageName|lib/src/$path', content)),
          outputs: outputs?.map((path, content) => MapEntry('$packageName|lib/src/$path', content)),
          reader: await PackageAssetReader.currentIsolate(),
        ),
      );
    }

    runTest(
      'Generates no output if no Dart libraries are present',
      libraries: {},
      outputs: null,
    );

    runTest(
      'Generates no output if Dart libraries are empty',
      libraries: {
        'foo.dart': '',
        'bar.dart': '',
      },
      outputs: null,
    );

    runTest(
      'Generates no output if Dart libraries have no annotated elements',
      libraries: {
        'foo.dart': 'class Foo {}',
        'bar.dart': 'class Bar {}',
      },
      outputs: null,
    );
  });
}
