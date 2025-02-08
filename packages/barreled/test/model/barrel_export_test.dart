import 'package:barreled/src/model/barrel_export.dart';
import 'package:test/test.dart';

void main() {
  group('$BarrelExport', () {
    late BarrelExport sut;

    group('.fromJson()', () {
      test('Creates a $BarrelExport from a JSON map', () {
        const json = {
          BarrelExport.uriKey: 'library.dart',
          BarrelExport.showKey: ['Shown1', 'Shown2'],
          BarrelExport.hideKey: ['Hidden1', 'Hidden2'],
          BarrelExport.tagsKey: ['Tag1', 'Tag2'],
        };

        sut = BarrelExport.fromJson(json);

        expect(sut.uri, 'library.dart');
        expect(sut.show, {'Shown1', 'Shown2'});
        expect(sut.hide, {'Hidden1', 'Hidden2'});
        expect(sut.tags, {'Tag1', 'Tag2'});
      });

      test('Defaults show, hide, and tags to empty sets', () {
        const json = {
          BarrelExport.uriKey: 'library.dart',
        };

        sut = BarrelExport.fromJson(json);

        expect(sut.uri, 'library.dart');
        expect(sut.show, isEmpty);
        expect(sut.hide, isEmpty);
        expect(sut.tags, isEmpty);
      });
    });

    group('.toJson()', () {
      test('Converts a $BarrelExport to a JSON map', () {
        sut = const BarrelExport(
          uri: 'library.dart',
          show: {'Shown1', 'Shown2'},
          hide: {'Hidden1', 'Hidden2'},
          tags: {'Tag1', 'Tag2'},
        );

        final json = sut.toJson();

        expect(json, {
          BarrelExport.uriKey: 'library.dart',
          BarrelExport.showKey: ['Shown1', 'Shown2'],
          BarrelExport.hideKey: ['Hidden1', 'Hidden2'],
          BarrelExport.tagsKey: ['Tag1', 'Tag2'],
        });
      });

      test('Defaults show, hide, and tags to empty lists', () {
        sut = const BarrelExport(uri: 'library.dart');

        final json = sut.toJson();

        expect(json, {
          BarrelExport.uriKey: 'library.dart',
          BarrelExport.showKey: <String>[],
          BarrelExport.hideKey: <String>[],
          BarrelExport.tagsKey: <String>[],
        });
      });
    });

    group('.merge()', () {
      test('Merges the show and hide filters, but keeps tags', () {
        const a = BarrelExport(
          uri: 'library.dart',
          show: {'Shown1', 'Shown2'},
          hide: {'Hidden1', 'Hidden2'},
          tags: {'Tag1', 'Tag2'},
        );
        const b = BarrelExport(
          uri: 'library.dart',
          show: {'Shown2', 'Shown3'},
          hide: {'Hidden2', 'Hidden3'},
          tags: {'Tag2', 'Tag3'},
        );

        final merged = a.merge(b);

        expect(merged.uri, 'library.dart');
        expect(merged.show, {'Shown1', 'Shown2', 'Shown3'});
        expect(merged.hide, {'Hidden1', 'Hidden2', 'Hidden3'});
        expect(merged.tags, {'Tag1', 'Tag2'});
      });

      test('Throws an ArgumentError if the URIs are different', () {
        const a = BarrelExport(uri: 'library_a.dart');
        const b = BarrelExport(uri: 'library_b.dart');

        expect(() => a.merge(b), throwsArgumentError);
      });
    });
  });
}
