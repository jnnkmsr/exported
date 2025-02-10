// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'export.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Export _$ExportFromJson(Map json) => Export(
      uri: json['library'] as String,
      show: (json['show'] as List<dynamic>?)?.map((e) => e as String).toSet() ??
          const {},
      hide: (json['hide'] as List<dynamic>?)?.map((e) => e as String).toSet() ??
          const {},
      tags: (json['tags'] as List<dynamic>?)?.map((e) => e as String).toSet() ??
          const {},
    );

Map<String, dynamic> _$ExportToJson(Export instance) => <String, dynamic>{
      'library': instance.uri,
      'show': instance.show.toList(),
      'hide': instance.hide.toList(),
      'tags': instance.tags.toList(),
    };
