import 'package:exported/src/builder/barrel_file_writer.dart';
import 'package:exported/src/model/export.dart';
import 'package:test/test.dart';

void main() {
  group('BarrelFileWriter', () {
    late BarrelFileWriter sut;

    setUp(() => sut = BarrelFileWriter());

    group('.write()', () {
      test('writes a header line for an empty list of exports', () {
        expect(sut.write([]), '// GENERATED CODE - DO NOT MODIFY BY HAND\n');
      });

      test('writes formatted code with all export directives', () {
        final exports = [
          Export(
            uri: 'package:foo/src/a.dart',
            show: const {'Bar', 'Baz', 'Corge', 'Foo', 'Garply', 'Grault', 'Qux', 'Waldo'},
          ),
          Export(uri: 'package:foo/src/b.dart', show: const {'bar', 'foo'}),
          Export(uri: 'package:foo/src/c.dart'),
        ];
        const output = '// GENERATED CODE - DO NOT MODIFY BY HAND\n\n'
            "export 'package:foo/src/a.dart'\n"
            '    show Bar, Baz, Corge, Foo, Garply, Grault, Qux, Waldo;\n'
            "export 'package:foo/src/b.dart' show bar, foo;\n"
            "export 'package:foo/src/c.dart';\n";

        expect(sut.write(exports), output);
      });
    });
  });
}
