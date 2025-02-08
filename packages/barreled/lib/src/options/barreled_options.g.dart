// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'barreled_options.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

BarreledOptions _$BarreledOptionsFromJson(Map json) => BarreledOptions(
      files: (json['barrel_files'] as List<dynamic>?)
          ?.map((e) => BarrelFileOption.fromJson(e as Map))
          .toList(),
    );
