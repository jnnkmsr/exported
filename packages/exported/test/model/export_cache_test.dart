import 'package:test/test.dart';

// TODO[ExportCache]: Unit test

void main() {
  group('ExportCache', () {});
}

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
//         final result = sut[Tags.none].single;
//         expect(result.uri, 'package:a/a.dart');
//       });
//     });
//   });
