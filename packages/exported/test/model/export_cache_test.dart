// import 'package:exported/src/legacy_2/export.dart';
// import 'package:exported/src/legacy_2/export_cache.dart';
// import 'package:exported/src/legacy_2/filter.dart';
// import 'package:exported/src/legacy_2/tag.dart';
// import 'package:test/test.dart' hide Tags;
//
// void main() {
//   group('ExportCache', () {
//     late ExportCache sut;
//
//     setUp(() {
//       sut = ExportCache();
//     });
//
//     group('.add()', () {
//       test('Adds exports to cache, grouped by tag', () {
//         const a = LegacyExport(uri: 'package:a/a.dart');
//         const aFoo = LegacyExport(uri: 'package:a/a.dart', tag: 'foo');
//         const bFoo = LegacyExport(uri: 'package:b/b.dart', tag: 'foo');
//         const bBar = LegacyExport(uri: 'package:b/b.dart', tag: 'bar');
//         const cBar = LegacyExport(uri: 'package:c/c.dart', tag: 'bar');
//
//         sut.add({a, aFoo, bFoo, bBar, cBar});
//
//         expect(sut[Tags.none], {a});
//         expect(sut[Tags({'foo'})], {aFoo, bFoo});
//         expect(sut[Tags({'bar'})], {bBar, cBar});
//       });
//
//       test('Merges exports with the same URI and tag', () {
//         final foo = LegacyExport(uri: 'package:a/a.dart', filter: Show({'foo'}));
//         final bar = LegacyExport(uri: 'package:a/a.dart', filter: Show({'bar'}));
//
//         sut.add({foo, bar});
//
//         // TODO: Test show filter
//         final result = sut[Tags.none].single;
//         expect(result.uri, 'package:a/a.dart');
//       });
//     });
//   });
// }
