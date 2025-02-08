// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'barreled_options.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

BarreledOptions _$BarreledOptionsFromJson(Map json) => BarreledOptions(
      files: (json['files'] as List<dynamic>?)
          ?.map((e) => BarrelFileOption.fromJson(e as Map))
          .toList(),
      exports: (json['exports'] as List<dynamic>?)
          ?.map((e) => ExportOption.fromJson(e as Map))
          .toList(),
    );
