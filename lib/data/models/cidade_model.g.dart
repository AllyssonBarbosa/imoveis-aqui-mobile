// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'cidade_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_CidadeModel _$CidadeModelFromJson(Map<String, dynamic> json) => _CidadeModel(
  id: (json['id'] as num).toInt(),
  nome: json['nome'] as String,
  uf: json['uf'] as String,
);

Map<String, dynamic> _$CidadeModelToJson(_CidadeModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'nome': instance.nome,
      'uf': instance.uf,
    };
