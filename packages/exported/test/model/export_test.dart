import 'package:exported/src/model/export.dart';
import 'package:test/test.dart';

void main() {
  group('$Export', () {
    late Export sut;

    group('.fromJson()', () {
      test('Creates an $Export instance from a JSON map', () {
        const json = {
          Export.uriKey: 'library.dart',
          Export.showKey: ['Shown1', 'Shown2'],
          Export.hideKey: ['Hidden1', 'Hidden2'],
          Export.tagsKey: ['Tag1', 'Tag2'],
        };

        sut = Export.fromJson(json);

        expect(sut.uri, 'library.dart');
        expect(sut.show, {'Shown1', 'Shown2'});
        expect(sut.hide, {'Hidden1', 'Hidden2'});
        expect(sut.tags, {'Tag1', 'Tag2'});
      });

      test('Defaults show, hide, and tags to empty sets', () {
        const json = {
          Export.uriKey: 'library.dart',
        };

        sut = Export.fromJson(json);

        expect(sut.uri, 'library.dart');
        expect(sut.show, isEmpty);
        expect(sut.hide, isEmpty);
        expect(sut.tags, isEmpty);
      });
    });

    group('.toJson()', () {
      test('Converts a $Export to a JSON map', () {
        sut = const Export(
          uri: 'library.dart',
          show: {'Shown1', 'Shown2'},
          hide: {'Hidden1', 'Hidden2'},
          tags: {'Tag1', 'Tag2'},
        );

        final json = sut.toJson();

        expect(json, {
          Export.uriKey: 'library.dart',
          Export.showKey: ['Shown1', 'Shown2'],
          Export.hideKey: ['Hidden1', 'Hidden2'],
          Export.tagsKey: ['Tag1', 'Tag2'],
        });
      });

      test('Defaults show, hide, and tags to empty lists', () {
        sut = const Export(uri: 'library.dart');

        final json = sut.toJson();

        expect(json, {
          Export.uriKey: 'library.dart',
          Export.showKey: <String>[],
          Export.hideKey: <String>[],
          Export.tagsKey: <String>[],
        });
      });
    });

    group('.merge()', () {
      test('Merges the show and hide filters, but keeps tags', () {
        const a = Export(
          uri: 'library.dart',
          show: {'Shown1', 'Shown2'},
          hide: {'Hidden1', 'Hidden2'},
          tags: {'Tag1', 'Tag2'},
        );
        const b = Export(
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

      test('Throws an $ArgumentError if the URIs are different', () {
        const a = Export(uri: 'library_a.dart');
        const b = Export(uri: 'library_b.dart');

        expect(() => a.merge(b), throwsArgumentError);
      });
    });
  });
}
