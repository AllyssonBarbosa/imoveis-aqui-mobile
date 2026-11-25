// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'acervo_por_corretor_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_LinhaAcervoCorretorModel _$LinhaAcervoCorretorModelFromJson(
  Map<String, dynamic> json,
) => _LinhaAcervoCorretorModel(
  corretorId: (json['corretor_id'] as num).toInt(),
  corretor: json['corretor'] as String,
  ativo: json['ativo'] as bool,
  total: (json['total'] as num).toInt(),
);

Map<String, dynamic> _$LinhaAcervoCorretorModelToJson(
  _LinhaAcervoCorretorModel instance,
) => <String, dynamic>{
  'corretor_id': instance.corretorId,
  'corretor': instance.corretor,
  'ativo': instance.ativo,
  'total': instance.total,
};

_AcervoPorCorretorModel _$AcervoPorCorretorModelFromJson(
  Map<String, dynamic> json,
) => _AcervoPorCorretorModel(
  linhas: (json['linhas'] as List<dynamic>)
      .map((e) => LinhaAcervoCorretorModel.fromJson(e as Map<String, dynamic>))
      .toList(),
  total: (json['total'] as num).toInt(),
);

Map<String, dynamic> _$AcervoPorCorretorModelToJson(
  _AcervoPorCorretorModel instance,
) => <String, dynamic>{'linhas': instance.linhas, 'total': instance.total};
