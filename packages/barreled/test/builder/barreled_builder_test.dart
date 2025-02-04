import 'package:barreled/src/builder/barreled_builder.dart';
import 'package:test/test.dart';

void main() {
  group('$BarreledBuilder', () {
    group('no barrel-file configuration', () {
      group('no annotations/package exports', () {
        test('generates empty file with package name', () {
          fail('Not implemented');
        });

        test('overwrites existing file', () {
          fail('Not implemented');
        });
      });

      group('only package exports', () {
        test('includes all package exports, sorted by name', () {
          fail('Not implemented');
        });

        test('ignores tags and includes all package exports', () {
          fail('Not implemented');
        });

        test('includes show filters, sorted by name', () {
          fail('Not implemented');
        });

        test('includes hide filters, sorted by name', () {
          fail('Not implemented');
        });

        test('includes only show filter when both show and hide are specified', () {
          fail('Not implemented');
        });

        // TODO: Split into multiple tests testing show/hide combinations.
        test('merges duplicate exports', () {
          fail('Not implemented');
        });
      });

      group('single library with annotations', () {
        test('generates empty barrel file when there are no annotations', () {
          fail('Not implemented');
        });

        test('includes all annotated elements, sorted by name', () {
          fail('Not implemented');
        });
      });

      group('multiple libraries with annotations', () {
        test('includes all annotated elements, sorted by name', () {
          fail('Not implemented');
        });
      });

      group('annotations and package exports', () {
        test('includes first package exports and then annotated elements', () {
          fail('Not implemented');
        });
      });
    });
  });
}
