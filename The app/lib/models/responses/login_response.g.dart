// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'login_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$$LoginResponseImplImpl _$$$LoginResponseImplImplFromJson(
        Map<String, dynamic> json) =>
    _$$LoginResponseImplImpl(
      token: json['token'] as String,
      refresh: json['refresh'] as String,
      userId: (json['userId'] as num).toInt(),
    );

Map<String, dynamic> _$$$LoginResponseImplImplToJson(
        _$$LoginResponseImplImpl instance) =>
    <String, dynamic>{
      'token': instance.token,
      'refresh': instance.refresh,
      'userId': instance.userId,
    };
