// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'contato_recebido_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_ContatoRecebidoModel _$ContatoRecebidoModelFromJson(
  Map<String, dynamic> json,
) => _ContatoRecebidoModel(
  id: (json['id'] as num).toInt(),
  imovelCodigo: json['imovel_codigo'] as String,
  imovelTitulo: json['imovel_titulo'] as String,
  canal: json['canal'] as String,
  criadoEm: json['criado_em'] as String,
  retorno: json['retorno'] as String,
  retornoEm: json['retorno_em'] as String?,
);

Map<String, dynamic> _$ContatoRecebidoModelToJson(
  _ContatoRecebidoModel instance,
) => <String, dynamic>{
  'id': instance.id,
  'imovel_codigo': instance.imovelCodigo,
  'imovel_titulo': instance.imovelTitulo,
  'canal': instance.canal,
  'criado_em': instance.criadoEm,
  'retorno': instance.retorno,
  'retorno_em': instance.retornoEm,
};
