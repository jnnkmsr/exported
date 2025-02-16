import 'package:exported/src/model/export_filter.dart';
import 'package:exported/src/model/export_uri.dart';
import 'package:exported/src/model/tag.dart';
import 'package:meta/meta.dart';

Parser get parser => Parser.instance;

typedef ExportUriParser = ExportUri Function(dynamic input);
typedef HideParser = Hide Function(dynamic input);
typedef ShowParser = Show Function(dynamic input);
typedef TagParser = Tag Function(dynamic input);

class Parser {
  const Parser._();

  @visibleForTesting
  static Parser instance = const Parser._();

  ExportUriParser get uri => ExportUri.parse;
  HideParser get hide => Hide.parse;
  ShowParser get show => Show.parse;
  TagParser get tag => Tag.parse;
}
