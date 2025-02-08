// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'barrel_export.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

BarrelExport _$BarrelExportFromJson(Map json) => BarrelExport(
      library: json['library'] as String,
      show: (json['show'] as List<dynamic>?)?.map((e) => e as String).toSet() ??
          const {},
      hide: (json['hide'] as List<dynamic>?)?.map((e) => e as String).toSet() ??
          const {},
      tags: (json['tags'] as List<dynamic>?)?.map((e) => e as String).toSet() ??
          const {},
    );

Map<String, dynamic> _$BarrelExportToJson(BarrelExport instance) =>
    <String, dynamic>{
      'library': instance.library,
      'show': instance.show.toList(),
      'hide': instance.hide.toList(),
      'tags': instance.tags.toList(),
    };
