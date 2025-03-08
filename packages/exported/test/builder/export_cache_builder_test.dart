import 'dart:convert';

import 'package:build/build.dart';
import 'package:build_test/build_test.dart';
import 'package:dart_style/dart_style.dart';
import 'package:exported/builder.dart';
import 'package:exported/src/builder/export_cache_builder.dart';
import 'package:exported/src/model/exported_option_keys.dart' as keys;
import 'package:exported/src/model/tag.dart';
import 'package:source_gen/source_gen.dart';
import 'package:test/test.dart';

void main() {
  group('ExportCacheBuilder', () {
    Future<dynamic> expectOutput(
      Map<String, String> sources,
      Map<String, Map<String, Map<String, dynamic>>>? outputs,
    ) =>
        testCacheBuilder(sources, outputs);

    Future<dynamic> expectNoOutput(Map<String, String> sources) => testCacheBuilder(sources, null);

    Future<dynamic> expectThrows<T>(Map<String, String> sources) =>
        expectLater(testCacheBuilder(sources, null), throwsA(isA<T>()));

    group('Library-level annotations', () {
      test('Generates JSON for annotated library element', () async {
        await expectOutput({
          'foo': '''
            @exported
            library;
            import 'package:exported_annotation/exported_annotation.dart';
            class Foo {}
            void foo() {}
          ''',
          'bar': '''
            @exported
            library;
            import 'package:exported_annotation/exported_annotation.dart';
            class Bar {}
            void bar() {}
          ''',
        }, {
          'foo': {
            Tag.none: {keys.uri: libraryUri('foo')},
          },
          'bar': {
            Tag.none: {keys.uri: libraryUri('bar')},
          },
        });
      });

      test('Generates JSON for library-element annotations with show/hide filters', () async {
        await expectOutput({
          'foo': '''
            @Exported(show: {'Foo'})
            library;
            import 'package:exported_annotation/exported_annotation.dart';
            class Foo {}
            void foo() {}
          ''',
          'bar': '''
            @Exported(hide: {'bar'})
            library;
            import 'package:exported_annotation/exported_annotation.dart';
            class Bar {}
            void bar() {}
          ''',
        }, {
          'foo': {
            Tag.none: {
              keys.uri: libraryUri('foo'),
              keys.show: ['Foo'],
            },
          },
          'bar': {
            Tag.none: {
              keys.uri: libraryUri('bar'),
              keys.hide: ['bar'],
            },
          },
        });
      });

      test('Throws for an annotation with show and hide filters', () async {
        await expectThrows<ArgumentError>({
          'foo': '''
            @Exported(show: {'Foo'}, hide: {'foo'})
            library;
            import 'package:exported_annotation/exported_annotation.dart';
            class Foo {}
            void foo() {}
          ''',
        });
      });
    });

    group('Element-level annotations', () {
      test('Generates JSON for libraries with annotated elements', () async {
        await expectOutput({
          'foo': '''
            import 'package:exported_annotation/exported_annotation.dart';
            @exported
            class Foo {}
            void foo() {}
          ''',
          'bar': '''
            import 'package:exported_annotation/exported_annotation.dart';
            @exported
            class Bar {}
            @exported
            void bar() {}
          ''',
        }, {
          'foo': {
            Tag.none: {
              keys.uri: libraryUri('foo'),
              keys.show: ['Foo'],
            },
          },
          'bar': {
            // Function elements will be traversed first, thus the order.
            Tag.none: {
              keys.uri: libraryUri('bar'),
              keys.show: ['bar', 'Bar'],
            },
          },
        });
      });

      test('Merges library annotation with annotated elements', () async {
        await expectOutput({
          'foo': '''
            @exported
            library;
            import 'package:exported_annotation/exported_annotation.dart';
            @exported
            class Foo {}
            void foo() {}
          ''',
          'bar': '''
            @Exported(show: {'Bar'})
            library;
            import 'package:exported_annotation/exported_annotation.dart';
            class Bar {}
            @exported
            void bar() {}
          ''',
          'baz': '''
            @Exported(hide: {'baz'})
            library;
            import 'package:exported_annotation/exported_annotation.dart';
            class Baz {}
            @exported
            void baz() {}
          ''',
        }, {
          'foo': {
            Tag.none: {keys.uri: libraryUri('foo')},
          },
          'bar': {
            // Function elements will be traversed first, thus the order.
            Tag.none: {
              keys.uri: libraryUri('bar'),
              keys.show: ['bar', 'Bar'],
            },
          },
          'baz': {
            Tag.none: {keys.uri: libraryUri('baz')},
          },
        });
      });

      test('Throws for an annotated unnamed element', () async {
        await expectThrows<InvalidGenerationSourceError>({
          'foo': '''
            import 'package:exported_annotation/exported_annotation.dart';
            @exported
            extension on String {}
          ''',
        });
      });
    });

    group('Annotations with tags', () {
      test('Groups exports by single tag', () async {
        await expectOutput({
          'foo': '''
            @Exported(tags: {'foo', 'bar'})
            library;
            import 'package:exported_annotation/exported_annotation.dart';
            class Foo {}
            @exported
            void foo() {}
          ''',
        }, {
          'foo': {
            'foo': {keys.uri: libraryUri('foo')},
            'bar': {keys.uri: libraryUri('foo')},
            Tag.none: {
              keys.uri: libraryUri('foo'),
              keys.show: ['foo'],
            },
          },
        });
      });

      test('Merges exports by tag', () async {
        await expectOutput({
          'foo': '''
            @Exported(show: {'Foo'}, tags: {'foo'})
            library;
            import 'package:exported_annotation/exported_annotation.dart';
            @exported
            class Foo {}
            @exported
            void bar() {}
            @Exported(tags: {'foo'})
            const baz = 42;
          ''',
        }, {
          'foo': {
            'foo': {
              keys.uri: libraryUri('foo'),
              keys.show: ['baz', 'Foo'],
            },
            Tag.none: {
              keys.uri: libraryUri('foo'),
              keys.show: ['bar', 'Foo'],
            },
          },
        });
      });

      test('Sanitizes tag input', () async {
        await expectOutput({
          'foo': '''
            @Exported(tags: {'FOO', '  bar  ', '  Baz'})
            library;
            import 'package:exported_annotation/exported_annotation.dart';
          ''',
        }, {
          'foo': {
            'foo': {keys.uri: libraryUri('foo')},
            'bar': {keys.uri: libraryUri('foo')},
            'baz': {keys.uri: libraryUri('foo')},
          },
        });
      });
    });

    group('No annotations', () {
      test('Generates no output if there are no libraries', () async {
        await expectNoOutput({});
      });

      test('Generates no output for empty libraries', () async {
        await expectNoOutput({'foo': ''});
      });

      test('Generates no output for libraries without annotations', () async {
        await expectNoOutput({
          'foo': '''
            class Foo {}
            void foo() {}
          ''',
        });
      });
    });
  });
}

const packageName = 'foo';
String libraryUri(String library) => 'package:$packageName/src/$library.dart';
String packageAsset(String path) => '$packageName|$path';
String dartAsset(String library) => packageAsset('lib/src/$library.dart');
String jsonAsset(String library) => packageAsset('lib/src/$library${ExportCacheBuilder.jsonExtension}');

Future<dynamic> testCacheBuilder(
  Map<String, String> sources,
  Map<String, Map<String, Map<String, dynamic>>>? outputs,
) async {
  final dartFormatter = DartFormatter(languageVersion: DartFormatter.latestLanguageVersion);
  return testBuilder(
    exportCacheBuilder(BuilderOptions.empty),
    sources.map(
      (path, content) => MapEntry(
        dartAsset(path),
        dartFormatter.format(content),
      ),
    ),
    outputs: outputs?.map(
      (path, json) => MapEntry(
        jsonAsset(path),
        '${jsonEncode(json.map((tag, export) => MapEntry(tag, [export])))}\n',
      ),
    ),
    reader: await PackageAssetReader.currentIsolate(),
  );
}
