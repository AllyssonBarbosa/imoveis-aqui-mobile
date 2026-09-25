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
  descricao: json['descricao'] as String,
  bairro: json['bairro'] as String,
  cidade: CidadeModel.fromJson(json['cidade'] as Map<String, dynamic>),
  fotoCapa: json['foto_capa'] as String?,
  caracteristicas: (json['caracteristicas'] as List<dynamic>)
      .map((e) => e as String)
      .toList(),
  criadoEm: json['criado_em'] as String,
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
      'descricao': instance.descricao,
      'bairro': instance.bairro,
      'cidade': instance.cidade,
      'foto_capa': instance.fotoCapa,
      'caracteristicas': instance.caracteristicas,
      'criado_em': instance.criadoEm,
      'natureza': instance.natureza,
      'quartos': instance.quartos,
      'suites': instance.suites,
      'vagas': instance.vagas,
      'area': instance.area,
    };
