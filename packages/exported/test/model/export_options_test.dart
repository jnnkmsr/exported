// Copyright (c) 2025 Jannik Möser
// Use of this source code is governed by the BSD 3-Clause License.
// See the LICENSE file for full license information.

import 'package:exported/src/model/barrel_file.dart';
import 'package:exported/src/model/export.dart';
import 'package:exported/src/model/exported_options.dart';
import 'package:test/test.dart';

void main() {
  group('ExportedOptions', () {
    group('.fromInput()', () {
      test('Parses `barrel_files` and `exports` options', () {
        const barrelFiles = [
          {
            'path': 'foo.dart',
            'tags': ['foo', 'bar'],
          },
          'bar.dart',
        ];
        const exports = [
          {
            'uri': 'foo',
            'tags': ['foo', 'bar'],
          },
          'bar',
        ];
        expect(
          ExportedOptions.fromInput(
            const {
              'barrel_files': barrelFiles,
              'exports': exports,
            },
            package: 'foo',
          ),
          ExportedOptions(
            BarrelFile.fromInput(barrelFiles, package: 'foo'),
            Export.fromInput(exports, package: 'foo'),
          ),
        );
      });
    });
  });
}
