// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'mudancas_recentes_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_MudancaRecenteModel _$MudancaRecenteModelFromJson(Map<String, dynamic> json) =>
    _MudancaRecenteModel(
      id: (json['id'] as num).toInt(),
      imovelId: (json['imovel_id'] as num).toInt(),
      imovelCodigo: json['imovel_codigo'] as String,
      imovelTitulo: json['imovel_titulo'] as String,
      situacaoAnterior: json['situacao_anterior'] as String,
      situacaoNova: json['situacao_nova'] as String,
      alteradoPor: json['alterado_por'] as String,
      alteradoEm: json['alterado_em'] as String,
      observacao: json['observacao'] as String? ?? '',
    );

Map<String, dynamic> _$MudancaRecenteModelToJson(
  _MudancaRecenteModel instance,
) => <String, dynamic>{
  'id': instance.id,
  'imovel_id': instance.imovelId,
  'imovel_codigo': instance.imovelCodigo,
  'imovel_titulo': instance.imovelTitulo,
  'situacao_anterior': instance.situacaoAnterior,
  'situacao_nova': instance.situacaoNova,
  'alterado_por': instance.alteradoPor,
  'alterado_em': instance.alteradoEm,
  'observacao': instance.observacao,
};

_MudancasRecentesModel _$MudancasRecentesModelFromJson(
  Map<String, dynamic> json,
) => _MudancasRecentesModel(
  dias: (json['dias'] as num).toInt(),
  mudancas: (json['mudancas'] as List<dynamic>)
      .map((e) => MudancaRecenteModel.fromJson(e as Map<String, dynamic>))
      .toList(),
);

Map<String, dynamic> _$MudancasRecentesModelToJson(
  _MudancasRecentesModel instance,
) => <String, dynamic>{'dias': instance.dias, 'mudancas': instance.mudancas};
