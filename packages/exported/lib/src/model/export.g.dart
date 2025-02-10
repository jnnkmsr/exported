// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'export.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Export _$ExportFromJson(Map json) => $checkedCreate(
      'Export',
      json,
      ($checkedConvert) {
        final val = Export._sanitized(
          uri: $checkedConvert('uri', (v) => v as String),
          show: $checkedConvert('show',
              (v) => (v as List<dynamic>?)?.map((e) => e as String).toSet()),
          hide: $checkedConvert('hide',
              (v) => (v as List<dynamic>?)?.map((e) => e as String).toSet()),
          tags: $checkedConvert('tags',
              (v) => (v as List<dynamic>?)?.map((e) => e as String).toSet()),
        );
        return val;
      },
    );

Map<String, dynamic> _$ExportToJson(Export instance) => <String, dynamic>{
      'uri': instance.uri,
      'show': instance.show.toList(),
      'hide': instance.hide.toList(),
      'tags': instance.tags.toList(),
    };
