// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'exported_options.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ExportedOptions _$ExportedOptionsFromJson(Map json) => $checkedCreate(
      'ExportedOptions',
      json,
      ($checkedConvert) {
        final val = ExportedOptions(
          files: $checkedConvert(
              'barrel_files',
              (v) => (v as List<dynamic>?)
                  ?.map((e) => BarrelFile.fromJson(e as Map))
                  .toList()),
          exports: $checkedConvert(
              'exports',
              (v) => (v as List<dynamic>?)
                  ?.map((e) => Export.fromJson(e as Map))
                  .toList()),
        );
        return val;
      },
      fieldKeyMap: const {'files': 'barrel_files'},
    );
