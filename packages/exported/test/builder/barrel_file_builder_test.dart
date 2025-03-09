// Copyright (c) 2025 Jannik Möser
// Use of this source code is governed by the BSD 3-Clause License.
// See the LICENSE file for full license information.

import 'dart:convert';

import 'package:build/build.dart';
import 'package:build_test/build_test.dart';
import 'package:dart_style/dart_style.dart';
import 'package:exported/builder.dart';
import 'package:exported/src/model/exported_option_keys.dart' as keys;
import 'package:exported/src/model/tag.dart';
import 'package:file/memory.dart';
import 'package:test/test.dart';

void main() {
  group('BarrelFileBuilder', () {
    group('Single barrel file', () {
      test('Generates a barrel file with annotated exports from JSON cache', () async {
        await testExportedBuilder(
          cachedExports: {
            'models/user.exported.json': {
              Tag.none: {keys.uri: libraryUri('models/user.dart')},
            },
            'models/order.exported.json': {
              Tag.none: {
                keys.uri: libraryUri('models/order.dart'),
                keys.show: ['Order', 'Payment'],
              },
            },
            'utils/validator.exported.json': {
              Tag.none: {
                keys.uri: libraryUri('utils/validator.dart'),
                keys.show: ['OrderValidator', 'PaymentValidator', 'UserValidator'],
              },
            },
          },
          expectedBarrelFiles: {
            '$packageName.dart': '''
              // GENERATED CODE - DO NOT MODIFY BY HAND
              
              export 'package:foo/src/models/order.dart' show Order, Payment;
              export 'package:foo/src/models/user.dart';
              export 'package:foo/src/utils/validator.dart' show OrderValidator, PaymentValidator, UserValidator;
            ''',
          },
        );
      });

      test('Generates a barrel file with exports from builder options', () async {
        await testExportedBuilder(
          options: {
            keys.exports: [
              'meta',
              'lib/src/utils/validator',
              {
                keys.uri: 'lib/src/models/order',
                keys.show: ['Order'],
              },
              {
                keys.uri: 'lib/src/models/user',
                keys.show: ['User'],
              }
            ],
          },
          cachedExports: {},
          expectedBarrelFiles: {
            '$packageName.dart': '''
              // GENERATED CODE - DO NOT MODIFY BY HAND
              
              export 'package:foo/src/models/order.dart' show Order;
              export 'package:foo/src/models/user.dart' show User;
              export 'package:foo/src/utils/validator.dart';
              export 'package:meta/meta.dart';
            ''',
          },
        );
      });

      test('Merges exports from builder options with cached exports', () async {
        await testExportedBuilder(
          options: {
            keys.exports: [
              'meta',
              'lib/src/utils/validator',
              {
                keys.uri: 'lib/src/models/order',
                keys.hide: ['Payment'],
              },
              {
                keys.uri: 'lib/src/models/user',
                keys.show: ['User', 'Profile'],
              }
            ],
          },
          cachedExports: {
            'models/user.exported.json': {
              Tag.none: {
                keys.uri: libraryUri('models/user.dart'),
                keys.show: ['User', 'Account'],
              },
            },
            'models/order.exported.json': {
              Tag.none: {
                keys.uri: libraryUri('models/order.dart'),
                keys.show: ['Order', 'Payment'],
              },
            },
            'utils/validator.exported.json': {
              Tag.none: {
                keys.uri: libraryUri('utils/validator.dart'),
                keys.show: ['OrderValidator', 'PaymentValidator', 'UserValidator'],
              },
            },
          },
          expectedBarrelFiles: {
            '$packageName.dart': '''
              // GENERATED CODE - DO NOT MODIFY BY HAND
              
              export 'package:foo/src/models/order.dart';
              export 'package:foo/src/models/user.dart' show Account, Profile, User;
              export 'package:foo/src/utils/validator.dart';
              export 'package:meta/meta.dart';
            ''',
          },
        );
      });

      test('Generates an empty barrel file if there are no exports', () async {
        await testExportedBuilder(
          cachedExports: {},
          expectedBarrelFiles: {
            '$packageName.dart': '''
              // GENERATED CODE - DO NOT MODIFY BY HAND
              
            ''',
          },
        );
      });
    });

    group('Multiple barrel files with tags', () {
      test('Generates barrel files containing exports with matching tags', () async {
        await testExportedBuilder(
          options: {
            keys.barrelFiles: [
              {keys.path: 'foo.dart'}, // No tags; should receive all exports.
              {
                keys.path: 'core.dart',
                keys.tags: ['core'],
              },
              {
                keys.path: 'models.dart',
                keys.tags: ['core', 'models'],
              },
              {
                keys.path: 'utils.dart',
                keys.tags: ['utils'],
              },
            ],
            keys.exports: [
              'meta', // No tags; should be in all files.
              {
                keys.uri: 'collections',
                keys.tags: ['core'],
              },
              {
                keys.uri: 'uuid',
                keys.tags: ['models', 'utils'],
              }
            ],
          },
          cachedExports: {
            'core/foo.exported.json': {
              'core': {keys.uri: libraryUri('core/foo.dart')},
            },
            'models/user.exported.json': {
              'models': {keys.uri: libraryUri('models/user.dart')},
            },
            'models/order.exported.json': {
              'models': {keys.uri: libraryUri('models/order.dart')},
            },
            'utils/validator.exported.json': {
              'utils': {keys.uri: libraryUri('utils/validator.dart')},
            },
          },
          expectedBarrelFiles: {
            'foo.dart': '''
              // GENERATED CODE - DO NOT MODIFY BY HAND
              
              export 'package:collections/collections.dart';
              export 'package:foo/src/core/foo.dart';
              export 'package:foo/src/models/order.dart';
              export 'package:foo/src/models/user.dart';
              export 'package:foo/src/utils/validator.dart';
              export 'package:meta/meta.dart';
              export 'package:uuid/uuid.dart';
            ''',
            'core.dart': '''
              // GENERATED CODE - DO NOT MODIFY BY HAND
              
              export 'package:collections/collections.dart';
              export 'package:foo/src/core/foo.dart';
              export 'package:meta/meta.dart';
            ''',
            'models.dart': '''
              // GENERATED CODE - DO NOT MODIFY BY HAND
              
              export 'package:collections/collections.dart';
              export 'package:foo/src/core/foo.dart';
              export 'package:foo/src/models/order.dart';
              export 'package:foo/src/models/user.dart';
              export 'package:meta/meta.dart';
              export 'package:uuid/uuid.dart';
            ''',
            'utils.dart': '''
              // GENERATED CODE - DO NOT MODIFY BY HAND
              
              export 'package:foo/src/utils/validator.dart';
              export 'package:meta/meta.dart';
              export 'package:uuid/uuid.dart';
            ''',
          },
        );
      });
    });
  });
}

const packageName = 'foo';
String libraryUri(String library) => 'package:$packageName/src/$library';
String packageAsset(String path) => '$packageName|lib/$path';

Future<dynamic> testExportedBuilder({
  Map<String, dynamic> options = const {},
  Map<String, Map<String, Map<String, dynamic>>> cachedExports = const {},
  Map<String, String>? expectedBarrelFiles,
  Object? throws,
}) async {
  final sourceAssets = {
    // Put one empty file to simulate a non-empty package.
    packageAsset('src/empty.dart'): '',
    ...cachedExports.map(
      (path, json) => MapEntry(
        packageAsset('src/$path'),
        '${jsonEncode(json.map((tag, export) => MapEntry(tag, [export])))}\n',
      ),
    ),
  };

  final dartFormatter = DartFormatter(languageVersion: DartFormatter.latestLanguageVersion);
  final outputs = expectedBarrelFiles?.map(
    (path, content) => MapEntry(
      packageAsset(path),
      dartFormatter.format(content),
    ),
  );

  final fileSystem = MemoryFileSystem();
  fileSystem.file('pubspec.yaml')
    ..createSync(recursive: true)
    ..writeAsStringSync(pubspecYaml);

  final test = testBuilder(
    barrelFileBuilder(BuilderOptions(options), fileSystem),
    sourceAssets,
    outputs: outputs,
    rootPackage: packageName,
    reader: await PackageAssetReader.currentIsolate(),
  );
  return throws == null ? test : expectLater(test, throwsA(throws));
}

const pubspecYaml = '''
name: $packageName
description: Test package for exported.
publish_to: none

environment:
  sdk: ^3.6.1
''';
