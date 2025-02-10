import 'package:exported/src/options/barrel_file_option.dart';
import 'package:exported/src/options/exported_option_keys.dart' as keys;
import 'package:exported/src/validation/file_path_sanitizer.dart';
import 'package:exported/src/validation/tags_sanitizer.dart';
import 'package:mocktail/mocktail.dart';
import 'package:test/test.dart';

void main() {
  group('$BarrelFileOption', () {
    late BarrelFileOption sut;

    late MockFilePathSanitizer mockPathSanitizer;
    late MockTagsSanitizer mockTagsSanitizer;

    setUp(() {
      mockPathSanitizer = MockFilePathSanitizer();
      mockTagsSanitizer = MockTagsSanitizer();
      BarrelFileOption.pathSanitizer = mockPathSanitizer;
      BarrelFileOption.tagsSanitizer = mockTagsSanitizer;
    });

    group('.()', () {
      test('Sanitizes inputs', () {
        sut = BarrelFileOption(
          path: 'foo_bar.dart',
          tags: const {'foo', 'bar'},
        );
        verify(() => mockPathSanitizer.sanitize('foo_bar.dart')).called(1);
        verify(() => mockTagsSanitizer.sanitize({'foo', 'bar'})).called(1);
      });
    });

    group('.fromJson()', () {
      test('Creates a $BarrelFileOption from JSON', () {
        sut = BarrelFileOption.fromJson(const {
          keys.path: 'foo_bar.dart',
          keys.tags: ['foo', 'bar'],
        });
        expect(sut.path, 'foo_bar.dart');
        expect(sut.tags, {'foo', 'bar'});
      });

      test('Sanitizes inputs', () {
        sut = BarrelFileOption.fromJson(const {
          keys.path: 'foo_bar.dart',
          keys.tags: ['foo', 'bar'],
        });
        verify(() => mockPathSanitizer.sanitize('foo_bar.dart')).called(1);
        verify(() => mockTagsSanitizer.sanitize({'foo', 'bar'})).called(1);
      });
    });

    group('.==()', () {
      test('Compares two $BarrelFileOption instances by file', () {
        final a = BarrelFileOption(path: 'foo');
        final b = BarrelFileOption(path: 'foo');
        final c = BarrelFileOption(path: 'bar');

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

class MockFilePathSanitizer with Mock implements FilePathSanitizer {
  MockFilePathSanitizer() {
    when(() => sanitize(any())).thenAnswer(
      (i) => i.positionalArguments.first as String? ?? '',
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
