// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'imovel_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_ImovelModel _$ImovelModelFromJson(Map<String, dynamic> json) => _ImovelModel(
  id: (json['id'] as num).toInt(),
  titulo: json['titulo'] as String,
  finalidade: json['finalidade'] as String,
  precoVenda: json['preco_venda'] as String?,
  precoAluguel: json['preco_aluguel'] as String?,
  bairro: json['bairro'] as String?,
  fotoCapa: json['foto_capa'] as String?,
  natureza: json['natureza'] as String?,
  quartos: (json['quartos'] as num?)?.toInt(),
  suites: (json['suites'] as num?)?.toInt(),
  vagas: (json['vagas'] as num?)?.toInt(),
  area: json['area'] as String?,
);

Map<String, dynamic> _$ImovelModelToJson(_ImovelModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'titulo': instance.titulo,
      'finalidade': instance.finalidade,
      'preco_venda': instance.precoVenda,
      'preco_aluguel': instance.precoAluguel,
      'bairro': instance.bairro,
      'foto_capa': instance.fotoCapa,
      'natureza': instance.natureza,
      'quartos': instance.quartos,
      'suites': instance.suites,
      'vagas': instance.vagas,
      'area': instance.area,
    };
