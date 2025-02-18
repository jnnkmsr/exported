import 'dart:convert';

import 'package:build_test/build_test.dart';
import 'package:exported/src/builder/exported_cache_builder.dart';
import 'package:exported/src/model/export.dart';
import 'package:exported/src/model/export_cache.dart';
import 'package:meta/meta.dart';
import 'package:test/test.dart';

void main() {
  group('ExportedCacheBuilder', () {
    late ExportedCacheBuilder sut;
    setUp(() => sut = ExportedCacheBuilder());

    const packageName = 'foo';
    String uri(String path) => 'package:$packageName/src/$path';
    String assetPath(String path) => '$packageName|lib/src/$path';

    @isTest
    void runTest(
      String message, {
      required Map<String, List<String>> libraries,
      required Map<String, List<Export>>? outputs,
    }) =>
        test(message, () async {
          await testBuilder(
            sut,
            libraries.map((path, lines) => MapEntry(assetPath(path), lines.join('\n'))),
            outputs: outputs?.map(
              (path, exports) => MapEntry(
                assetPath(path),
                jsonEncode(ExportCache(exports).toJson()),
              ),
            ),
            reader: await PackageAssetReader.currentIsolate(),
          );
        });

    runTest(
      'Generates no output if no Dart libraries are present',
      libraries: {},
      outputs: {},
    );

    runTest(
      'Generates no output if Dart libraries are empty',
      libraries: {
        'foo.dart': [''],
        'bar.dart': [''],
      },
      outputs: {},
    );

    runTest(
      'Generates no output if Dart libraries have no annotated elements',
      libraries: {
        'foo.dart': [
          'class Foo {}',
          'void foo() {}',
        ],
        'bar.dart': [
          'class Bar {}',
          'void bar() {}',
        ],
      },
      outputs: {},
    );

    runTest(
      'Generates JSON for Dart libraries with annotated elements',
      libraries: {
        'foo.dart': [
          "import 'package:exported_annotation/exported_annotation.dart';",
          '@exported class Foo {}',
          '@exported void foo() {}',
        ],
        'bar.dart': [
          "import 'package:exported_annotation/exported_annotation.dart';",
          '@exported class Bar {}',
          '@exported void bar() {}',
        ],
        'baz.dart': [],
      },
      outputs: {
        'foo.exported.json': [
          ...Export.fromAnnotation(uri: uri('foo.dart'), element: 'Foo'),
          ...Export.fromAnnotation(uri: uri('foo.dart'), element: 'foo'),
        ],
        'bar.exported.json': [
          ...Export.fromAnnotation(uri: uri('bar.dart'), element: 'Bar'),
          ...Export.fromAnnotation(uri: uri('bar.dart'), element: 'bar'),
        ],
      },
    );

    runTest(
      'Generates JSON for Dart libraries with annotated elements with tags',
      libraries: {
        'foo.dart': [
          "import 'package:exported_annotation/exported_annotation.dart';",
          "@Exported(tags: {'foo', 'bar'}) class Foo {}",
          "@Exported(tags: {'foo'}) void foo() {}",
        ],
        'bar.dart': [
          "import 'package:exported_annotation/exported_annotation.dart';",
          "@Exported(tags: {'foo', 'bar'}) class Bar {}",
          "@Exported(tags: {'foo'}) void bar() {}",
        ],
      },
      outputs: {
        'foo.exported.json': [
          ...Export.fromAnnotation(uri: uri('foo.dart'), element: 'Foo', tags: ['foo', 'bar']),
          ...Export.fromAnnotation(uri: uri('foo.dart'), element: 'foo', tags: ['foo']),
        ],
        'bar.exported.json': [
          ...Export.fromAnnotation(uri: uri('bar.dart'), element: 'Bar', tags: ['foo', 'bar']),
          ...Export.fromAnnotation(uri: uri('bar.dart'), element: 'bar', tags: ['foo']),
        ],
      },
    );
  });
}
