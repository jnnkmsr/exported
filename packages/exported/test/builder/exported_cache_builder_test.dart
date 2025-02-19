import 'dart:convert';

import 'package:build_test/build_test.dart';
import 'package:exported/src/builder/cache_builder.dart';
import 'package:exported/src/model/export.dart';
import 'package:exported/src/model/export_cache.dart';
import 'package:meta/meta.dart';
import 'package:source_gen/source_gen.dart';
import 'package:test/test.dart';

void main() {
  group('CacheBuilder', () {
    late CacheBuilder sut;
    setUp(() => sut = CacheBuilder());

    const packageName = 'foo';
    String uri(String path) => 'package:$packageName/src/$path';
    String assetPath(String path) => '$packageName|lib/src/$path';

    @isTest
    void runTest(
      String message, {
      required Map<String, List<String>> libraries,
      Map<String, List<Export>>? outputs,
      Object? throws,
    }) =>
        test(message, () async {
          final test = testBuilder(
            sut,
            libraries.map((path, lines) => MapEntry(assetPath(path), lines.join('\n'))),
            outputs: outputs?.map(
              (path, exports) => MapEntry(
                assetPath(path),
                '${jsonEncode(ExportCache(exports).toJson())}\n',
              ),
            ),
            reader: await PackageAssetReader.currentIsolate(),
          );
          await (throws != null ? expectLater(test, throwsA(throws)) : test);
        });

    group('No annotated elements', () {
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
    });

    group('Valid annotated elements', () {
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
            ...Export.element(uri: uri('foo.dart'), name: 'Foo'),
            ...Export.element(uri: uri('foo.dart'), name: 'foo'),
          ],
          'bar.exported.json': [
            ...Export.element(uri: uri('bar.dart'), name: 'Bar'),
            ...Export.element(uri: uri('bar.dart'), name: 'bar'),
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
            ...Export.element(uri: uri('foo.dart'), name: 'Foo', tags: ['foo', 'bar']),
            ...Export.element(uri: uri('foo.dart'), name: 'foo', tags: ['foo']),
          ],
          'bar.exported.json': [
            ...Export.element(uri: uri('bar.dart'), name: 'Bar', tags: ['foo', 'bar']),
            ...Export.element(uri: uri('bar.dart'), name: 'bar', tags: ['foo']),
          ],
        },
      );

      runTest(
        'Generates JSON for Dart libraries with annotated library elements',
        libraries: {
          'foo.dart': [
            "import 'package:exported_annotation/exported_annotation.dart';",
            '@exported library',
          ],
          'bar.dart': [
            "import 'package:exported_annotation/exported_annotation.dart';",
            "@Exported(tags: {'foo', 'bar'}) library",
          ],
        },
        outputs: {
          'foo.exported.json': [
            ...Export.library(uri: uri('foo.dart')),
          ],
          'bar.exported.json': [
            ...Export.library(uri: uri('bar.dart'), tags: ['foo', 'bar']),
          ],
        },
      );
    });

    group('Invalid annotated elements', () {
      runTest(
        'Throws for annotated imports',
        libraries: {
          'foo.dart': [
            "import 'package:exported_annotation/exported_annotation.dart';",
            "@exported import 'bar.dart';",
          ],
        },
        throws: isA<InvalidGenerationSourceError>(),
      );

      runTest(
        'Throws for annotated exports',
        libraries: {
          'foo.dart': [
            "import 'package:exported_annotation/exported_annotation.dart';",
            "@exported export 'bar.dart';",
          ],
        },
        throws: isA<InvalidGenerationSourceError>(),
      );

      runTest(
        'Throws for annotated part elements',
        libraries: {
          'foo.dart': [
            "import 'package:exported_annotation/exported_annotation.dart';",
            "@exported part 'bar.dart';",
          ],
        },
        throws: isA<InvalidGenerationSourceError>(),
      );

      runTest(
        'Throws for annotated unnamed extension',
        libraries: {
          'foo.dart': [
            "import 'package:exported_annotation/exported_annotation.dart';",
            '@exported extension on String {}',
          ],
        },
        throws: isA<InvalidGenerationSourceError>(),
      );
    });
  });
}
