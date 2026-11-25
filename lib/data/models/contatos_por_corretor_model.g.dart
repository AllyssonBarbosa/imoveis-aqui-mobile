// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'contatos_por_corretor_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_LinhaContatosCorretorModel _$LinhaContatosCorretorModelFromJson(
  Map<String, dynamic> json,
) => _LinhaContatosCorretorModel(
  corretorId: (json['corretor_id'] as num?)?.toInt(),
  corretor: json['corretor'] as String?,
  ativo: json['ativo'] as bool?,
  total: (json['total'] as num).toInt(),
  pendentes: (json['pendentes'] as num).toInt(),
);

Map<String, dynamic> _$LinhaContatosCorretorModelToJson(
  _LinhaContatosCorretorModel instance,
) => <String, dynamic>{
  'corretor_id': instance.corretorId,
  'corretor': instance.corretor,
  'ativo': instance.ativo,
  'total': instance.total,
  'pendentes': instance.pendentes,
};

_ContatosPorCorretorModel _$ContatosPorCorretorModelFromJson(
  Map<String, dynamic> json,
) => _ContatosPorCorretorModel(
  linhas: (json['linhas'] as List<dynamic>)
      .map(
        (e) => LinhaContatosCorretorModel.fromJson(e as Map<String, dynamic>),
      )
      .toList(),
  total: (json['total'] as num).toInt(),
  pendentes: (json['pendentes'] as num).toInt(),
);

Map<String, dynamic> _$ContatosPorCorretorModelToJson(
  _ContatosPorCorretorModel instance,
) => <String, dynamic>{
  'linhas': instance.linhas,
  'total': instance.total,
  'pendentes': instance.pendentes,
};
