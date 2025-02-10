import 'package:barreled/src/builder/barreled_builder.dart';
import 'package:barreled/src/builder/dart_writer.dart';
import 'package:barreled/src/options/barrel_file_option.dart';
import 'package:barreled/src/options/barreled_options.dart';
import 'package:barreled/src/util/pubspec_reader.dart';
import 'package:build_test/build_test.dart';
import 'package:dart_style/dart_style.dart';
import 'package:meta/meta.dart';
import 'package:mocktail/mocktail.dart';
import 'package:pub_semver/pub_semver.dart';
import 'package:test/test.dart';

void main() {
  group('$BarreledBuilder', () {
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
            BarreledBuilder(options: BarreledOptions.fromJson(options)),
            {
              // A `pubspec.yaml` file will always be present.
              '$packageName|pubspec.yaml': '',
              for (final MapEntry(key: path, value: content) in jsonAssets.entries)
                '$packageName|$path': content,
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
          BarreledOptions.filesKey: [
            {BarrelFileOption.pathKey: 'foo.dart'},
            {BarrelFileOption.pathKey: 'lib/foo/bar.dart'},
            {BarrelFileOption.pathKey: 'foo/bar/baz.dart'},
          ],
        },
        output: {
          'lib/foo.dart': [],
          'lib/foo/bar.dart': [],
          'lib/foo/bar/baz.dart': [],
        },
      );
    });
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
