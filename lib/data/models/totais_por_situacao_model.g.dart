// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'totais_por_situacao_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_TotaisPorSituacaoModel _$TotaisPorSituacaoModelFromJson(
  Map<String, dynamic> json,
) => _TotaisPorSituacaoModel(
  totais: Map<String, int>.from(json['totais'] as Map),
  total: (json['total'] as num).toInt(),
);

Map<String, dynamic> _$TotaisPorSituacaoModelToJson(
  _TotaisPorSituacaoModel instance,
) => <String, dynamic>{'totais': instance.totais, 'total': instance.total};
