// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'package_export_option.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PackageExportOption _$PackageExportOptionFromJson(Map json) =>
    PackageExportOption(
      package: json['package'] as String,
      show: (json['show'] as List<dynamic>?)?.map((e) => e as String).toSet() ??
          const {},
      hide: (json['hide'] as List<dynamic>?)?.map((e) => e as String).toSet() ??
          const {},
      tags: (json['tags'] as List<dynamic>?)?.map((e) => e as String).toSet() ??
          const {},
    );
