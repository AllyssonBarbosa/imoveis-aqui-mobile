// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'imovel_gestao_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_ImovelGestaoModel _$ImovelGestaoModelFromJson(Map<String, dynamic> json) =>
    _ImovelGestaoModel(
      id: (json['id'] as num).toInt(),
      codigo: json['codigo'] as String,
      titulo: json['titulo'] as String,
      finalidade: json['finalidade'] as String,
      precoVenda: json['preco_venda'] as String?,
      precoAluguel: json['preco_aluguel'] as String?,
      situacao: json['situacao'] as String?,
      situacaoDesde: json['situacao_desde'] as String,
      podeMudarSituacao: json['pode_mudar_situacao'] as bool,
    );

Map<String, dynamic> _$ImovelGestaoModelToJson(_ImovelGestaoModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'codigo': instance.codigo,
      'titulo': instance.titulo,
      'finalidade': instance.finalidade,
      'preco_venda': instance.precoVenda,
      'preco_aluguel': instance.precoAluguel,
      'situacao': instance.situacao,
      'situacao_desde': instance.situacaoDesde,
      'pode_mudar_situacao': instance.podeMudarSituacao,
    };
