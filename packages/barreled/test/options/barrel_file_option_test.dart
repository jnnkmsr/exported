import 'package:barreled/src/options/barrel_file_option.dart';
import 'package:barreled/src/validation/barrel_file_path_sanitizer.dart';
import 'package:barreled/src/validation/tags_sanitizer.dart';
import 'package:mocktail/mocktail.dart';
import 'package:test/test.dart';

void main() {
  group('$BarrelFileOption', () {
    late BarrelFileOption sut;

    late MockBarrelFilePathSanitizer mockPathSanitizer;
    late MockTagsSanitizer mockTagsSanitizer;

    setUp(() {
      mockPathSanitizer = MockBarrelFilePathSanitizer();
      mockTagsSanitizer = MockTagsSanitizer();
      BarrelFileOption.pathSanitizer = mockPathSanitizer;
      BarrelFileOption.tagsSanitizer = mockTagsSanitizer;
    });

    group('.()', () {
      test('Sanitizes inputs', () {
        sut = BarrelFileOption(
          file: 'foo_bar.dart',
          dir: 'lib/baz',
          tags: const {'foo', 'bar'},
        );
        verify(
          () => mockPathSanitizer.sanitize(
            fileInput: 'foo_bar.dart',
            dirInput: 'lib/baz',
          ),
        ).called(1);
        verify(
          () => mockTagsSanitizer.sanitize({'foo', 'bar'}),
        ).called(1);
      });
    });

    group('.fromJson()', () {
      test('Creates a $BarrelFileOption from JSON', () {
        sut = BarrelFileOption.fromJson(const {
          BarrelFileOption.fileKey: 'foo_bar.dart',
          BarrelFileOption.dirKey: 'lib/baz',
          BarrelFileOption.tagsKey: ['foo', 'bar'],
        });
        expect(sut.file, 'foo_bar.dart');
        expect(sut.dir, 'lib/baz');
        expect(sut.tags, {'foo', 'bar'});
      });

      test('Sanitizes inputs', () {
        sut = BarrelFileOption.fromJson(const {
          BarrelFileOption.fileKey: 'foo_bar.dart',
          BarrelFileOption.dirKey: 'lib/baz',
          BarrelFileOption.tagsKey: ['foo', 'bar'],
        });
        verify(
          () => mockPathSanitizer.sanitize(
            fileInput: 'foo_bar.dart',
            dirInput: 'lib/baz',
          ),
        ).called(1);
        verify(
          () => mockTagsSanitizer.sanitize({'foo', 'bar'}),
        ).called(1);
      });
    });

    group('.==()', () {
      test('Compares two $BarrelFileOption instances by file', () {
        final a = BarrelFileOption(file: 'foo');
        final b = BarrelFileOption(file: 'foo');
        final c = BarrelFileOption(file: 'bar');

        expect(a, equals(b));
        expect(a, isNot(equals(c)));

        expect(a.hashCode, b.hashCode);
        expect(a.hashCode, isNot(c.hashCode));
      });

      test('Compares two $BarrelFileOption instances by dir', () {
        final a = BarrelFileOption(dir: 'foo');
        final b = BarrelFileOption(dir: 'foo');
        final c = BarrelFileOption(dir: 'bar');

        expect(a, equals(b));
        expect(a, isNot(equals(c)));

        expect(a.hashCode, b.hashCode);
        expect(a.hashCode, isNot(c.hashCode));
      });

      test('Compares two $BarrelFileOption instances by tags, ignoring order', () {
        final a = BarrelFileOption(tags: const {'foo', 'bar'});
        final b = BarrelFileOption(tags: const {'bar', 'foo'});
        final c = BarrelFileOption(tags: const {'foo', 'bar', 'baz'});

        expect(a, equals(b));
        expect(a, isNot(equals(c)));

        expect(a.hashCode, b.hashCode);
        expect(a.hashCode, isNot(c.hashCode));
      });
    });
  });
}

class MockBarrelFilePathSanitizer with Mock implements BarrelFilePathSanitizer {
  MockBarrelFilePathSanitizer() {
    when(
      () => sanitize(
        fileInput: any(named: 'fileInput'),
        dirInput: any(named: 'dirInput'),
      ),
    ).thenAnswer(
      (i) => (
        file: i.namedArguments[#fileInput] as String? ?? '',
        dir: i.namedArguments[#dirInput] as String? ?? '',
      ),
    );
  }
}

class MockTagsSanitizer with Mock implements TagsSanitizer {
  MockTagsSanitizer() {
    when(() => sanitize(any())).thenAnswer(
      (i) => i.positionalArguments.first as Set<String>? ?? {},
    );
  }
}
