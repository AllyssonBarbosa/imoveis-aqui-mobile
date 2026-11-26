// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'foto_imovel_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_FotoImovelModel _$FotoImovelModelFromJson(Map<String, dynamic> json) =>
    _FotoImovelModel(
      id: (json['id'] as num).toInt(),
      imagem: json['imagem'] as String,
      ordem: (json['ordem'] as num).toInt(),
      capa: json['capa'] as bool,
    );

Map<String, dynamic> _$FotoImovelModelToJson(_FotoImovelModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'imagem': instance.imagem,
      'ordem': instance.ordem,
      'capa': instance.capa,
    };
