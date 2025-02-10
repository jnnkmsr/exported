// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'barrel_file.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

BarrelFile _$BarrelFileFromJson(Map json) => $checkedCreate(
      'BarrelFile',
      json,
      ($checkedConvert) {
        final val = BarrelFile._sanitized(
          path: $checkedConvert('path', (v) => v as String?),
          tags: $checkedConvert('tags',
              (v) => (v as List<dynamic>?)?.map((e) => e as String).toSet()),
        );
        return val;
      },
    );
