// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'setpoint_rule.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$SetpointRangesImpl _$$SetpointRangesImplFromJson(Map<String, dynamic> json) =>
    _$SetpointRangesImpl(
      rangeOk: _$recordConvert(
        json['rangeOk'],
        ($jsonValue) => (
          ($jsonValue[r'$1'] as num).toDouble(),
          ($jsonValue[r'$2'] as num).toDouble(),
        ),
      ),
      rangeAbnormal: _$recordConvert(
        json['rangeAbnormal'],
        ($jsonValue) => (
          ($jsonValue[r'$1'] as num).toDouble(),
          ($jsonValue[r'$2'] as num).toDouble(),
        ),
      ),
      rangeCritical: _$recordConvert(
        json['rangeCritical'],
        ($jsonValue) => (
          ($jsonValue[r'$1'] as num).toDouble(),
          ($jsonValue[r'$2'] as num).toDouble(),
        ),
      ),
    );

Map<String, dynamic> _$$SetpointRangesImplToJson(
        _$SetpointRangesImpl instance) =>
    <String, dynamic>{
      'rangeOk': <String, dynamic>{
        r'$1': instance.rangeOk.$1,
        r'$2': instance.rangeOk.$2,
      },
      'rangeAbnormal': <String, dynamic>{
        r'$1': instance.rangeAbnormal.$1,
        r'$2': instance.rangeAbnormal.$2,
      },
      'rangeCritical': <String, dynamic>{
        r'$1': instance.rangeCritical.$1,
        r'$2': instance.rangeCritical.$2,
      },
    };

$Rec _$recordConvert<$Rec>(
  Object? value,
  $Rec Function(Map) convert,
) =>
    convert(value as Map<String, dynamic>);
