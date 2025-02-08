import 'package:barreled/src/model/barrel_export.dart';
import 'package:test/test.dart';

void main() {
  group('$BarrelExport', () {
    late BarrelExport sut;

    group('.fromJson()', () {
      test('Creates a $BarrelExport from a JSON map', () {
        const json = {
          'library': 'library.dart',
          'show': ['Shown1', 'Shown2'],
          'hide': ['Hidden1', 'Hidden2'],
          'tags': ['Tag1', 'Tag2'],
        };

        sut = BarrelExport.fromJson(json);

        expect(sut.library, 'library.dart');
        expect(sut.show, {'Shown1', 'Shown2'});
        expect(sut.hide, {'Hidden1', 'Hidden2'});
        expect(sut.tags, {'Tag1', 'Tag2'});
      });

      test('Defaults show, hide, and tags to empty sets', () {
        const json = {
          'library': 'library.dart',
        };

        sut = BarrelExport.fromJson(json);

        expect(sut.library, 'library.dart');
        expect(sut.show, isEmpty);
        expect(sut.hide, isEmpty);
        expect(sut.tags, isEmpty);
      });
    });

    group('.toJson()', () {
      test('Converts a $BarrelExport to a JSON map', () {
        sut = const BarrelExport(
          library: 'library.dart',
          show: {'Shown1', 'Shown2'},
          hide: {'Hidden1', 'Hidden2'},
          tags: {'Tag1', 'Tag2'},
        );

        final json = sut.toJson();

        expect(json, {
          'library': 'library.dart',
          'show': ['Shown1', 'Shown2'],
          'hide': ['Hidden1', 'Hidden2'],
          'tags': ['Tag1', 'Tag2'],
        });
      });

      test('Defaults show, hide, and tags to empty lists', () {
        sut = const BarrelExport(library: 'library.dart');

        final json = sut.toJson();

        expect(json, {
          'library': 'library.dart',
          'show': <String>[],
          'hide': <String>[],
          'tags': <String>[],
        });
      });
    });

    group('.merge()', () {
      test('Merges the show and hide filters, but keeps tags', () {
        const a = BarrelExport(
          library: 'library.dart',
          show: {'Shown1', 'Shown2'},
          hide: {'Hidden1', 'Hidden2'},
          tags: {'Tag1', 'Tag2'},
        );
        const b = BarrelExport(
          library: 'library.dart',
          show: {'Shown2', 'Shown3'},
          hide: {'Hidden2', 'Hidden3'},
          tags: {'Tag2', 'Tag3'},
        );

        final merged = a.merge(b);

        expect(merged.library, 'library.dart');
        expect(merged.show, {'Shown1', 'Shown2', 'Shown3'});
        expect(merged.hide, {'Hidden1', 'Hidden2', 'Hidden3'});
        expect(merged.tags, {'Tag1', 'Tag2'});
      });

      test('Throws an ArgumentError if the URIs are different', () {
        const a = BarrelExport(library: 'library_a.dart');
        const b = BarrelExport(library: 'library_b.dart');

        expect(() => a.merge(b), throwsArgumentError);
      });
    });
  });
}
