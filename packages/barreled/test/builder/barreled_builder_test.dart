import 'package:barreled/src/builder/barreled_builder.dart';
import 'package:barreled/src/builder/dart_writer.dart';
import 'package:barreled/src/util/pubspec_reader.dart';
import 'package:build_test/build_test.dart';
import 'package:dart_style/dart_style.dart';
import 'package:meta/meta.dart';
import 'package:mocktail/mocktail.dart';
import 'package:pub_semver/pub_semver.dart';
import 'package:test/test.dart';

void main() {
  group('$BarreledBuilder', () {
    late BarreledBuilder sut;

    setUp(() {
      PubspecReader.$instance = FakePubspecReader();
      sut = BarreledBuilder();
    });

    @isTest
    void runTest(
      String description, {
      required Map<String, String> jsonAssets,
      required Map<String, List<String>> output,
    }) {
      test(
        description,
        () async => testBuilder(
          sut,
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
        ),
      );
    }

    group('No annotations/export options', () {
      runTest(
        'Generates empty default barrel file if no options are provided',
        jsonAssets: {},
        output: {'lib/$packageName.dart': []},
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
