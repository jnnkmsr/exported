// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'export_option.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ExportOption _$ExportOptionFromJson(Map json) => ExportOption(
      uri: json['uri'] as String,
      show: (json['show'] as List<dynamic>?)?.map((e) => e as String).toSet(),
      hide: (json['hide'] as List<dynamic>?)?.map((e) => e as String).toSet(),
      tags: (json['tags'] as List<dynamic>?)?.map((e) => e as String).toSet(),
    );
