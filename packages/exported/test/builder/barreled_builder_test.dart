import 'package:build/build.dart';
import 'package:build_test/build_test.dart';
import 'package:dart_style/dart_style.dart';
import 'package:exported/src/builder/exported_builder.dart';
import 'package:exported/src/model/exported_option_keys.dart' as keys;
import 'package:exported/src/model/exported_options.dart';
import 'package:exported/src/util/dart_writer.dart';
import 'package:exported/src/util/pubspec_reader.dart';
import 'package:meta/meta.dart';
import 'package:mocktail/mocktail.dart';
import 'package:pub_semver/pub_semver.dart';
import 'package:test/test.dart';

// TODO[ExportedBuilder]: Complete tests.

void main() {
  setUp(() {
    PubspecReader.$instance = FakePubspecReader();
  });

  @isTest
  void runTest(
    String description, {
    Map<String, String> jsonAssets = const {},
    Map<String, dynamic> options = const {},
    required Map<String, List<String>> output,
  }) {
    test(
      description,
      () async {
        return testBuilder(
          ExportedBuilder(options: ExportedOptions.fromOptions(BuilderOptions(options))),
          {
            // A `pubspec.yaml` file will always be present.
            '$packageName|pubspec.yaml': '',
            for (final MapEntry(key: path, value: content) in jsonAssets.entries)
              '$packageName|$path.exported.json': content,
          },
          outputs: {
            for (final MapEntry(key: path, value: lines) in output.entries)
              '$packageName|$path': dartOutput(lines),
          },
          reader: await PackageAssetReader.currentIsolate(),
        );
      },
    );
  }

  group('No annotations/export options', () {
    runTest(
      'Generates empty default file if no options are provided',
      output: {'lib/$packageName.dart': []},
    );

    runTest(
      'Generates empty files specified in options',
      options: {
        keys.barrelFiles: [
          {keys.path: 'foo.dart'},
          {keys.path: 'lib/foo/bar.dart'},
          {keys.path: 'foo/bar/baz.dart'},
        ],
      },
      output: {
        'lib/foo.dart': [],
        'lib/foo/bar.dart': [],
        'lib/foo/bar/baz.dart': [],
      },
    );
  });
}

class FakePubspecReader with Fake implements PubspecReader {
  @override
  String get name => packageName;

  @override
  VersionConstraint get sdkVersion => dartVersion;
}

const packageName = 'foo';
final dartVersion = Version(3, 6, 1);
final dartFormatter = DartFormatter(languageVersion: dartVersion);

String dartOutput(List<String> lines) {
  final buffer = StringBuffer()..writeln(DartWriter.header);
  for (final line in lines) {
    buffer.writeln(line);
  }
  return dartFormatter.format(buffer.toString());
}
