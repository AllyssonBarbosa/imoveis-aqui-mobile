// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'mudanca_situacao_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_MudancaSituacaoModel _$MudancaSituacaoModelFromJson(
  Map<String, dynamic> json,
) => _MudancaSituacaoModel(
  id: (json['id'] as num).toInt(),
  situacaoAnterior: json['situacao_anterior'] as String?,
  situacaoNova: json['situacao_nova'] as String?,
  alteradoPor: json['alterado_por'] as String?,
  alteradoEm: json['alterado_em'] as String,
  observacao: json['observacao'] as String? ?? '',
);

Map<String, dynamic> _$MudancaSituacaoModelToJson(
  _MudancaSituacaoModel instance,
) => <String, dynamic>{
  'id': instance.id,
  'situacao_anterior': instance.situacaoAnterior,
  'situacao_nova': instance.situacaoNova,
  'alterado_por': instance.alteradoPor,
  'alterado_em': instance.alteradoEm,
  'observacao': instance.observacao,
};
