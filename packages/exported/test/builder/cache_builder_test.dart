import 'dart:convert';

import 'package:build_test/build_test.dart';
import 'package:exported/src/builder/cache_builder.dart';
import 'package:exported/src/model/export.dart';
import 'package:exported/src/model/tag.dart';
import 'package:meta/meta.dart';
import 'package:source_gen/source_gen.dart';
import 'package:test/test.dart';

void main() {
  group('CacheBuilder', () {
    const packageName = 'foo';
    String packageUri(String path) => 'package:$packageName/src/$path';
    String packageAsset(String path) => '$packageName|lib/src/$path';

    @isTest
    void runTest(
      String message, {
      required Map<String, List<String>> source,
      Map<String, Map<String, List<Export>>>? output,
      Object? throws,
    }) {
      final sourceAssets =
          source.map((path, lines) => MapEntry(packageAsset(path), lines.join('\n')));
      final outputAssets = output?.map((path, exportsByTag) {
        final json = exportsByTag.map(
          (tag, exports) => MapEntry(
            tag,
            exports.map((export) => export.toJson()).toList(),
          ),
        );
        return MapEntry(
          packageAsset(path),
          '${jsonEncode(json)}\n',
        );
      });

      test(message, () async {
        final test = testBuilder(
          CacheBuilder(),
          sourceAssets,
          outputs: outputAssets,
          reader: await PackageAssetReader.currentIsolate(),
        );
        await (throws != null ? expectLater(test, throwsA(throws)) : test);
      });
    }

    group('No annotated elements', () {
      runTest(
        'Generates no output if no Dart libraries are present',
        source: {},
        output: {},
      );

      runTest(
        'Generates no output if Dart libraries are empty',
        source: {
          'foo.dart': [''],
          'bar.dart': [''],
        },
        output: {},
      );

      runTest(
        'Generates no output if Dart libraries have no annotated elements',
        source: {
          'foo.dart': [
            'class Foo {}',
            'void foo() {}',
          ],
          'bar.dart': [
            'class Bar {}',
            'void bar() {}',
          ],
        },
        output: {},
      );
    });

    group('Valid annotated elements', () {
      runTest(
        'Generates JSON for Dart libraries with annotated exports',
        source: {
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
        output: {
          'foo.exported.json': {
            Tag.none: [
              Export.library(uri: packageUri('foo.dart'), show: const {'foo', 'Foo'}),
            ],
          },
          'bar.exported.json': {
            Tag.none: [
              Export.library(uri: packageUri('bar.dart'), show: const {'bar', 'Bar'}),
            ],
          },
        },
      );

      runTest(
        'Generates JSON for Dart libraries with annotated exports with tags',
        source: {
          'foo.dart': [
            "import 'package:exported_annotation/exported_annotation.dart';",
            "@Exported(tags: {'foo', 'bar'}) class Foo {}",
            "@Exported(tags: {'foo'}) void foo() {}",
            '@exported const FOO = 42;',
          ],
          'bar.dart': [
            "import 'package:exported_annotation/exported_annotation.dart';",
            "@Exported(tags: {'foo', 'bar'}) class Bar {}",
            "@Exported(tags: {'foo'}) void bar() {}",
            '@exported const BAR = 42;',
          ],
        },
        output: {
          'foo.exported.json': {
            'foo': [
              Export.library(uri: packageUri('foo.dart'), show: const {'foo', 'Foo'}),
            ],
            'bar': [
              Export.library(uri: packageUri('foo.dart'), show: const {'Foo'}),
            ],
            Tag.none: [
              Export.library(uri: packageUri('foo.dart'), show: const {'FOO'}),
            ],
          },
          'bar.exported.json': {
            'foo': [
              Export.library(uri: packageUri('bar.dart'), show: const {'bar', 'Bar'}),
            ],
            'bar': [
              Export.library(uri: packageUri('bar.dart'), show: const {'Bar'}),
            ],
            Tag.none: [
              Export.library(uri: packageUri('bar.dart'), show: const {'BAR'}),
            ],
          },
        },
      );

      runTest(
        'Generates JSON for Dart libraries with annotated library elements',
        source: {
          'foo.dart': [
            "import 'package:exported_annotation/exported_annotation.dart';",
            '@exported library;',
          ],
          'bar.dart': [
            "import 'package:exported_annotation/exported_annotation.dart';",
            "@Exported(show: {'foo'}) library;",
            "@Exported(tags: {'foo'}) void foo() {}",
            "@Exported(tags: {'bar'}) void bar() {}",
            '@exported void baz() {}',
          ],
        },
        output: {
          'foo.exported.json': {
            Tag.none: [
              Export.library(uri: packageUri('foo.dart')),
            ],
          },
          'bar.exported.json': {
            Tag.none: [
              Export.library(uri: packageUri('bar.dart'), show: const {'baz', 'foo'}),
            ],
            'foo': [
              Export.library(uri: packageUri('bar.dart'), show: const {'foo'}),
            ],
            'bar': [
              Export.library(uri: packageUri('bar.dart'), show: const {'bar'}),
            ],
          },
        },
      );
    });

    group('Invalid annotated elements', () {
      runTest(
        'Throws for annotated imports',
        source: {
          'foo.dart': [
            "import 'package:exported_annotation/exported_annotation.dart';",
            "@exported import 'bar.dart';",
          ],
        },
        throws: isA<InvalidGenerationSourceError>(),
      );

      runTest(
        'Throws for annotated exports',
        source: {
          'foo.dart': [
            "import 'package:exported_annotation/exported_annotation.dart';",
            "@exported export 'bar.dart';",
          ],
        },
        throws: isA<InvalidGenerationSourceError>(),
      );

      runTest(
        'Throws for annotated part elements',
        source: {
          'foo.dart': [
            "import 'package:exported_annotation/exported_annotation.dart';",
            "@exported part 'bar.dart';",
          ],
        },
        throws: isA<InvalidGenerationSourceError>(),
      );

      runTest(
        'Throws for annotated unnamed extension',
        source: {
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
