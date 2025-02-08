// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'barreled_builder_options.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

BarreledBuilderOptions _$BarreledBuilderOptionsFromJson(Map json) =>
    BarreledBuilderOptions(
      files: (json['barrel_files'] as List<dynamic>?)
          ?.map((e) => BarrelFileOption.fromJson(e as Map))
          .toList(),
    );
