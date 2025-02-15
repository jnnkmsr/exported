import 'package:exported/src/builder/dart_writer.dart';
import 'package:test/test.dart';

void main() {
  late DartWriter sut;

  setUp(() {
    sut = DartWriter();
  });

  test('writes a header line if no lines have been added', () {
    expect(sut.write(), '// GENERATED CODE - DO NOT MODIFY BY HAND\n');
  });

  test('writes formatted lines of code', () {
    final writer = DartWriter();
    writer.addLine("export 'package:foo/src/a.dart'");
    writer.addLine('show Foo, Bar, Baz, Qux, Quux, Corge, Grault, Garply, Waldo');
    writer.addLine(';');
    writer.addLine("export 'package:foo/src/b.dart'");
    writer.addLine('show foo, bar');
    writer.addLine(';');
    writer.addLine("export 'package:foo/src/c.dart'");
    writer.addLine(';');
    final output = writer.write();
    expect(output, '''
// GENERATED CODE - DO NOT MODIFY BY HAND

export 'package:foo/src/a.dart'
    show Foo, Bar, Baz, Qux, Quux, Corge, Grault, Garply, Waldo;
export 'package:foo/src/b.dart' show foo, bar;
export 'package:foo/src/c.dart';
''');
  });
}
