// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'exported_options.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ExportedOptions _$ExportedOptionsFromJson(Map json) => ExportedOptions(
      files: (json['barrel_files'] as List<dynamic>?)
          ?.map((e) => BarrelFileOption.fromJson(e as Map))
          .toList(),
      exports: (json['exports'] as List<dynamic>?)
          ?.map((e) => ExportOption.fromJson(e as Map))
          .toList(),
    );
